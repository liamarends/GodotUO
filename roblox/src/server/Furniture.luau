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
	end
	self.Connections, self.Carrying = {}, {}
	self.Items = Map.furniture(self.World)
	for _, item in self.Items do
		table.insert(
			self.Connections,
			item.Prompt.Triggered:Connect(function(player: Player)
				self:pickup(player, item)
			end)
		)
	end
end

function Furniture.pickup(self: any, player: Player, item: any)
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
	local maximum = if item.Large and self.Game:crewCount() > 1 then 2 else 1
	if #item.Carriers >= maximum then
		return
	end
	-- No yielding between validation and the claim.
	table.insert(item.Carriers, player)
	self.Carrying[player] = item
	player:SetAttribute("Carrying", item.Name)
	player:SetAttribute("LargeCarry", item.Large)
	item.Prompt.Enabled = #item.Carriers < maximum
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
	item.Prompt.Enabled = not item.Delivered
	if makeNoise and self.Game.Phase == "Playing" and os.clock() >= item.BumpAt then
		item.BumpAt = os.clock() + Config.CollisionCooldown
		self.Game:addNoise(Config.Noise.Drop, "Furniture", item.Root.Position)
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
	local angle = item.Angle + math.rad(Config.RotateDegrees) * direction
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
		local floorHit = workspace:Raycast(
			Vector3.new(target.X, hrp.Position.Y + 3, target.Z),
			Vector3.new(0, -12, 0),
			self.FloorRay
		)
		if not floorHit then
			continue
		end
		target = Vector3.new(target.X, floorHit.Position.Y + item.Size.Y / 2 + 0.3, target.Z)
		local delta = target - item.Root.Position
		local speed = if item.Large and self.Game:crewCount() == 1
			then Config.SoloDragSpeed
			else Config.FurnitureSpeed
		local move = if delta.Magnitude > 0.01
			then delta.Unit * math.min(delta.Magnitude, speed * dt)
			else Vector3.zero
		local nextCF = CFrame.new(item.Root.Position + move) * CFrame.Angles(0, item.Angle, 0)
		local blocked = #workspace:GetPartBoundsInBox(nextCF, item.Size * 0.94, self.Overlap) > 0
		if not blocked and move.Magnitude > 0.01 then
			blocked = workspace:Blockcast(item.Root.CFrame, item.Size * 0.94, move, self.WallRay)
				~= nil
		end
		if blocked then
			self:bump(item)
		else
			item.Model:PivotTo(nextCF)
		end
		if Map.inTruck(self.World, item.Root.Position, math.max(item.Size.X, item.Size.Z) / 2) then
			item.Delivered = true -- Set before credit/release, once per round/object.
			local carriers = table.clone(item.Carriers)
			for _, p in carriers do
				self:release(p, false)
			end
			item.Prompt.Enabled = false
			item.Model:PivotTo(CFrame.new(1000, -100, item.Id * 10))
			self.Game:delivered(item, carriers)
		end
	end
end
return Furniture
