--!strict
local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared.GameConfig)
local Map = require(script.Parent.Map)
local Furniture = {}
local function root(player: Player): BasePart?
	return if player.Character
		then player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		else nil
end

function Furniture.new(world: any, gameState: any): any
	local self: any =
		{ World = world, Game = gameState, Items = {}, Carrying = {}, Connections = {} }
	setmetatable(self, { __index = Furniture })
	self.WallRay = RaycastParams.new()
	self.WallRay.FilterType, self.WallRay.FilterDescendantsInstances =
		Enum.RaycastFilterType.Include, { world.Blockers }
	self.FloorRay = RaycastParams.new()
	self.FloorRay.FilterType, self.FloorRay.FilterDescendantsInstances =
		Enum.RaycastFilterType.Include, { world.Floors }
	self.Overlap = OverlapParams.new()
	self.Overlap.FilterType, self.Overlap.FilterDescendantsInstances =
		Enum.RaycastFilterType.Include, { world.Blockers }
	return self
end

function Furniture.reset(self: any)
	for _, connection in self.Connections do
		connection:Disconnect()
	end
	for player in self.Carrying do
		player:SetAttribute("Carrying", nil)
		player:SetAttribute("LargeCarry", nil)
	end
	self.Connections, self.Carrying = {}, {}
	self.Items = Map.furniture(self.World)
	for _, item in self.Items do
		for slot, prompt in item.Prompts do
			table.insert(
				self.Connections,
				prompt.Triggered:Connect(function(player: Player)
					self:pickup(player, item, slot)
				end)
			)
		end
		local steady = Instance.new("ProximityPrompt")
		steady.ActionText, steady.ObjectText, steady.KeyboardKeyCode, steady.MaxActivationDistance, steady.Parent =
			"Steady / secure for 30s", item.Name, Enum.KeyCode.Q, 7, item.Root
		table.insert(
			self.Connections,
			steady.Triggered:Connect(function(player: Player)
				local hrp = root(player)
				if
					not self.Game:canAct(player)
					or not hrp
					or (hrp.Position - item.Root.Position).Magnitude > 8
					or item.Delivered
					or workspace:Raycast(
						hrp.Position,
						item.Root.Position - hrp.Position,
						self.WallRay
					)
				then
					return
				end
				if item.CalmUntil > os.clock() + 20 then
					return
				end
				item.CalmUntil = os.clock() + 30
				local drawer = item.Model:FindFirstChild("LooseDrawer")
				if drawer then
					drawer.CFrame = item.Root.CFrame * CFrame.new(0, 0.3, -0.65)
				end
				self.Game:notify(
					player,
					"Secured for 30 seconds. " .. (item.Hint or "Move carefully.")
				)
			end)
		)
	end
end

function Furniture.pickup(self: any, player: Player, item: any, slot: number?)
	if not self.Game:canAct(player) or self.Carrying[player] or item.Delivered then
		return
	end
	local hrp = root(player)
	if not hrp or (hrp.Position - item.Root.Position).Magnitude > Config.PickupDistance then
		return
	end
	if workspace:Raycast(hrp.Position, item.Root.Position - hrp.Position, self.WallRay) then
		return
	end
	local grabSlot = slot or 1
	local handle = item.Handles[grabSlot] or item.Root
	if item.Slots[grabSlot] or (hrp.Position - handle.Position).Magnitude > 6 then
		return
	end
	local maximum = if item.Large and self.Game:crewCount() > 1 then 2 else 1
	if #item.Carriers >= maximum then
		return
	end
	-- No yielding between validation and the claim.
	item.Slots[grabSlot] = player
	table.insert(item.Carriers, player)
	self.Carrying[player] = item
	player:SetAttribute("Carrying", item.Name)
	player:SetAttribute("LargeCarry", item.Large)
	self:prompts(item)
	if maximum == 2 and #item.Carriers == 1 then
		self.Game:notify(player, "Large load: a second mover must join. Stay close together.")
	end
end

function Furniture.release(self: any, player: Player, makeNoise: boolean)
	local item = self.Carrying[player]
	if not item then
		return
	end
	self.Carrying[player] = nil
	player:SetAttribute("Carrying", nil)
	player:SetAttribute("LargeCarry", nil)
	local index = table.find(item.Carriers, player)
	if index then
		table.remove(item.Carriers, index)
	end
	item.LiftVotes[player] = nil
	for slot, mover in item.Slots do
		if mover == player then
			item.Slots[slot] = nil
		end
	end
	self:prompts(item)
	if makeNoise and self.Game.Phase == "Playing" and os.clock() >= item.BumpAt then
		item.BumpAt = os.clock() + Config.CollisionCooldown
		self.Game:addNoise(
			(if player:GetAttribute("SprintIntent") then Config.Noise.Drop else 3),
			"Furniture",
			item.Root.Position
		)
	end
	-- Place on the nearest supported floor. Never fling a shared physics assembly.
	if #item.Carriers == 0 and not item.Delivered then
		local hit = workspace:Raycast(
			item.Root.Position + Vector3.new(0, 1, 0),
			Vector3.new(0, -50, 0),
			self.FloorRay
		)
		if hit then
			item.Model:PivotTo(
				CFrame.new(
					item.Root.Position.X,
					hit.Position.Y + item.Size.Y / 2,
					item.Root.Position.Z
				) * CFrame.Angles(0, item.Angle, 0)
			)
		end
	end
end

function Furniture.rotate(self: any, player: Player, direction: any)
	local item = self.Carrying[player]
	if not item or item.Carriers[1] ~= player or not self.Game:canAct(player) then
		return
	end
	if direction ~= 1 and direction ~= -1 then
		return
	end
	local now = os.clock()
	if now < (item.RotateAt or 0) then
		return
	end
	item.RotateAt = now + 0.18
	local angle = item.Angle + math.rad(Config.RotateDegrees) * direction
	for step = 1, 3 do
		local interim = CFrame.new(item.Root.Position)
			* CFrame.Angles(
				0,
				item.Angle + math.rad(Config.RotateDegrees) * direction * step / 3,
				0
			)
		if #workspace:GetPartBoundsInBox(interim, item.Size * 0.94, self.Overlap) > 0 then
			self:bump(item)
			return
		end
	end
	if
		Config.Stage >= 2
		and item.Complication == "Drawer"
		and now - item.TurnAt < 0.9
		and now > item.CalmUntil
	then
		self.Game:addNoise(7, "Drawer", item.Root.Position)
		local drawer = item.Model:FindFirstChild("LooseDrawer")
		if drawer then
			drawer.CFrame = item.Root.CFrame * CFrame.new(0, 0.3, -1.4)
		end
		self.Game.House:cue(
			"Knock",
			"Drawer slid open! Pause between turns or steady it.",
			item.Root.Position
		)
	end
	item.TurnAt = now
	local cf = CFrame.new(item.Root.Position) * CFrame.Angles(0, angle, 0)
	if #workspace:GetPartBoundsInBox(cf, item.Size * 0.94, self.Overlap) == 0 then
		item.Angle = angle
		item.Model:PivotTo(cf)
	else
		self:bump(item)
	end
end

function Furniture.bump(self: any, item: any)
	if os.clock() < item.BumpAt then
		return
	end
	item.BumpAt = os.clock() + Config.CollisionCooldown
	self.Game:addNoise(Config.Noise.Bump, "Furniture", item.Root.Position)
end

function Furniture.prompts(self: any, item: any)
	for slot, prompt in item.Prompts do
		prompt.Enabled = not item.Delivered
			and item.Slots[slot] == nil
			and (#item.Carriers < (if item.Large and self.Game:crewCount() > 1 then 2 else 1))
	end
end
function Furniture.lift(self: any, player: Player)
	local item = self.Carrying[player]
	if not item or not self.Game:canAct(player) then
		return
	end
	local stats = self.Game.Participants[player]
	if item.Large and self.Game:crewCount() == 1 and stats.Equipment == "Dolly" then
		self.Game:notify(player, "The dolly stays on the floor. Exchange it at the truck to lift.")
		return
	end
	item.LiftVotes[player] = not item.LiftVotes[player]
	self.Game:notify(
		player,
		if item.LiftVotes[player]
			then "Lift ready. Both carriers must agree."
			else "Lowering the load."
	)
end
function Furniture.recover(self: any, player: Player)
	local item = self.Carrying[player]
	if not item or not self.Game:canAct(player) or os.clock() < (item.RecoverAt or 0) then
		return
	end
	local cf = item.LastSafe
	if
		(cf.Position - item.Root.Position).Magnitude > 12
		or #workspace:GetPartBoundsInBox(cf, item.Size * 0.94, self.Overlap) > 0
	then
		self.Game:notify(player, "No nearby clear recovery position. Put down and turn.")
		return
	end
	item.RecoverAt = os.clock() + 12
	for _, carrier in table.clone(item.Carriers) do
		self:release(carrier, false)
	end
	item.Model:PivotTo(cf)
	local _, angle = cf:ToOrientation()
	item.Angle = angle
	self.Game:addNoise(4, "Recovery", cf.Position)
	self.Game:notify(player, "Load returned to its last nearby clear position.")
end
function Furniture.complication(self: any, item: any)
	if
		Config.Stage < 2
		or not item.Complication
		or os.clock() - self.Game.RoundStarted < Config.ComplicationDelay
	then
		return
	end
	local now = os.clock()
	if now < item.EffectAt or now < item.CalmUntil then
		return
	end
	if item.Complication == "Rocker" and #item.Carriers == 0 then
		item.EffectAt = now + 8
		item.Model:PivotTo(
			CFrame.new(item.Root.Position)
				* CFrame.Angles(0, item.Angle, math.rad(if item.Rock then -5 else 5))
		)
		item.Rock = not item.Rock
		self.Game:addNoise(3, "Rocker", item.Root.Position)
		self.Game.House:cue(
			"Creak",
			"Rocker: steady it before leaving it alone.",
			item.Root.Position
		)
	elseif
		item.Complication == "Homesick"
		and #item.Carriers == 0
		and (item.Root.Position - item.Spawn.Position).Magnitude > 4
	then
		item.EffectAt = now + 10
		if
			not self.Game.House:watched(item.Root.Position)
			and not self.Game.House:watched(item.Spawn.Position)
			and #workspace:GetPartBoundsInBox(item.Spawn, item.Size, self.Overlap) == 0
		then
			item.Model:PivotTo(item.Spawn)
			item.Angle = 0
			self.Game.House:cue(
				"Knock",
				"The armchair went home. Watch it or secure it next time.",
				item.Spawn.Position
			)
		end
	elseif item.Complication == "Mirror" and #item.Carriers > 0 then
		item.EffectAt = now + 3
		local glass = item.Model:FindFirstChild("MemoryGlass")
		local threat = self.Game.Monster.Hunting
			and (self.Game.Monster.Root.Position - item.Root.Position).Magnitude < 35
		if glass then
			glass.Color = if threat
				then Color3.fromRGB(255, 178, 69)
				else Color3.fromRGB(113, 151, 173)
		end
		if threat then
			self.Game.House:cue(
				"Creak",
				"Mirror: a folded silhouette moves behind the glass.",
				item.Root.Position
			)
		end
	end
end
function Furniture.step(self: any, dt: number)
	if self.Game.Phase ~= "Playing" then
		return
	end
	for _, item in self.Items do
		if item.Delivered then
			continue
		end
		for i = #item.Carriers, 1, -1 do
			local player = item.Carriers[i]
			local hrp = root(player)
			if
				player.Parent ~= Players
				or not self.Game:canAct(player)
				or not hrp
				or (hrp.Position - item.Root.Position).Magnitude > Config.CarryReach
			then
				self:release(player, false)
			end
		end
		self:prompts(item)
		self:complication(item)
		local leader = item.Carriers[1]
		local required = if item.Large and self.Game:crewCount() > 1 then 2 else 1
		if not leader or #item.Carriers < required then
			continue
		end
		local hrp = root(leader)
		if not hrp then
			continue
		end
		if required == 2 then
			local partnerRoot = root(item.Carriers[2])
			if
				not partnerRoot
				or (hrp.Position - partnerRoot.Position).Magnitude > Config.PartnerSeparation
			then
				continue
			end
		end
		local target = hrp.Position + hrp.CFrame.LookVector * 5
		if required == 2 then
			local sum = Vector3.zero
			for slot, carrier in item.Slots do
				local rr = root(carrier)
				if rr then
					sum += rr.Position - CFrame.Angles(0, item.Angle, 0):VectorToWorldSpace(
						Vector3.new((if slot == 1 then -1 else 1) * (item.Size.X / 2 + 2), 0, 0)
					)
				end
			end
			target = sum / 2
		end
		if required == 2 then
			local aligned = true
			for slot, mover in item.Slots do
				local rr = root(mover)
				if rr then
					local localPos = item.Root.CFrame:PointToObjectSpace(rr.Position)
					if localPos.X * (if slot == 1 then -1 else 1) < 1 then
						aligned = false
					end
				end
			end
			if not aligned then
				if os.clock() > (item.AlignAt or 0) then
					item.AlignAt = os.clock() + 4
					self.Game:notify(
						leader,
						"Hold: stand at opposite orange handles before moving."
					)
				end
				continue
			end
		end
		local lifted = true
		for _, carrier in item.Carriers do
			if not item.LiftVotes[carrier] then
				lifted = false
			end
		end
		local floorHit = workspace:Raycast(
			Vector3.new(target.X, hrp.Position.Y + 3, target.Z),
			Vector3.new(0, -12, 0),
			self.FloorRay
		)
		if not floorHit then
			continue
		end
		target = Vector3.new(
			target.X,
			floorHit.Position.Y + item.Size.Y / 2 + 0.3 + (if lifted then Config.LiftHeight else 0),
			target.Z
		)
		local delta = target - item.Root.Position
		local speed = if item.Large and self.Game:crewCount() == 1
			then (if self.Game.Participants[leader].Equipment == "Dolly"
				then Config.SoloDragSpeed + 2
				else Config.SoloDragSpeed)
			else Config.FurnitureSpeed
		local move = if delta.Magnitude > 0.01
			then delta.Unit * math.min(delta.Magnitude, speed * dt)
			else Vector3.zero
		local tilt = math.clamp(delta.Y * 0.07, -0.15, 0.15)
		if
			Config.Stage >= 2
			and item.Complication == "Music"
			and math.abs(tilt) > 0.08
			and lifted
			and os.clock() > item.CalmUntil
			and os.clock() > item.EffectAt
		then
			item.EffectAt = os.clock() + 6
			self.Game:addNoise(9, "Music box", item.Root.Position)
			self.Game.House:cue(
				"Music",
				"Music box: lower it on stairs or steady it.",
				item.Root.Position
			)
		end
		local nextCF = CFrame.new(item.Root.Position + move)
			* CFrame.Angles(0, item.Angle, 0)
			* CFrame.Angles(tilt, 0, 0)
		local blocked = #workspace:GetPartBoundsInBox(nextCF, item.Size * 0.94, self.Overlap) > 0
		if not blocked and move.Magnitude > 0.01 then
			blocked = workspace:Blockcast(item.Root.CFrame, item.Size * 0.94, move, self.WallRay)
				~= nil
		end
		if blocked then
			self:bump(item)
		else
			if
				os.clock() - item.SafeAt > 2
				and (item.Root.Position - item.LastSafe.Position).Magnitude > 2
			then
				item.LastSafe, item.SafeAt = item.Root.CFrame, os.clock()
			end
			item.Model:PivotTo(nextCF)
			item.Model:SetAttribute("Lifted", lifted)
			item.Model:SetAttribute("CarryTilt", tilt)
		end
		if Map.inTruck(self.World, item.Root.Position, math.max(item.Size.X, item.Size.Z) / 2) then
			item.Delivered = true -- Set before credit/release, once per round/object.
			local carriers = table.clone(item.Carriers)
			for _, p in carriers do
				self:release(p, false)
			end
			self:prompts(item)
			item.Model:PivotTo(CFrame.new(1000, -100, item.Id * 10))
			self.Game:delivered(item, carriers)
		end
	end
end
return Furniture
