--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local PhysicsService = game:GetService("PhysicsService")
local Shared = game:GetService("ReplicatedStorage").Shared
local Config, Rules = require(Shared.GameConfig), require(Shared.Rules)
local Map = require(script.Parent.Map)
local Furniture = require(script.Parent.Furniture)
local Monster = require(script.Parent.Monster)
local Inventory = require(script.Parent.Inventory)
local Cosmetics = require(script.Parent.Cosmetics)
local Game = {}

local function root(player: Player): BasePart?
	return if player.Character
		then player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		else nil
end
local function humanoid(player: Player): Humanoid?
	return if player.Character then player.Character:FindFirstChildOfClass("Humanoid") else nil
end

function Game.new(world: any, action: RemoteEvent, event: RemoteEvent): any
	local self: any = {
		World = world,
		Event = event,
		Phase = "Lobby",
		Participants = {},
		StartCount = 1,
		Noise = 0,
		Delivered = 0,
		Required = 4,
		Deadline = 0,
		Selected = nil,
		Boost = nil,
		RoundId = "",
		LastAmbience = 0,
		LastContract = 0,
		Result = "",
		Rates = {},
		Jobs = {},
		HideCooldown = {},
	}
	setmetatable(self, { __index = Game })
	self.Inventory = Inventory.new(function(player: Player, message: string)
		self:notify(player, message)
	end)
	self.Inventory.Changed = function(player: Player)
		Cosmetics.apply(player, self.Inventory:snapshot(player))
		self:personal(player)
	end
	self.Furniture = Furniture.new(world, self)
	self.Furniture:reset()
	self.Monster = Monster.new(world, self)
	self.Inventory:installReceiptHandler()
	pcall(function()
		PhysicsService:RegisterCollisionGroup("Movers")
	end)
	PhysicsService:CollisionGroupSetCollidable("Movers", "Movers", false)
	Players.CharacterAutoLoads = false
	Players.PlayerAdded:Connect(function(player)
		self:join(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self:leave(player)
	end)
	for _, player in Players:GetPlayers() do
		self:join(player)
	end
	for _, spot in world.Hides do
		spot.Prompt.Triggered:Connect(function(player: Player)
			self:hide(player, spot)
		end)
	end
	action.OnServerEvent:Connect(function(player: Player, verb: any, value: any, extra: any)
		self:action(player, verb, value, extra)
	end)
	local elapsed, broadcast = 0, 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		broadcast += dt
		if elapsed >= 0.1 then
			self:step(math.min(elapsed, 0.3))
			elapsed = 0
		end
		if broadcast >= 0.5 then
			self:broadcast()
			broadcast = 0
		end
	end)
	game:BindToClose(function()
		local endAt = os.clock() + 25
		while (self.Inventory.Pending > 0 or next(self.Jobs) ~= nil) and os.clock() < endAt do
			task.wait(0.2)
		end
	end)
	return self
end

function Game.notify(self: any, player: Player, message: string)
	if player.Parent == Players then
		self.Event:FireClient(player, "Message", message)
	end
end
function Game.announce(self: any, message: string, kind: string?)
	self.Event:FireAllClients(kind or "Message", message)
end
function Game.canAct(self: any, player: Player): boolean
	local stats = self.Participants[player]
	local hrp = root(player)
	return self.Phase == "Playing"
		and stats ~= nil
		and not stats.Downed
		and not stats.Hidden
		and hrp ~= nil
		and (hrp.Position - stats.LastPos).Magnitude <= Config.CarryReach
end
function Game.crewCount(self: any): number
	local count = 0
	for _ in self.Participants do
		count += 1
	end
	return count
end

function Game.canShop(self: any, player: Player): boolean
	local hrp = root(player)
	return Config.Stage == 3
		and (self.Phase == "Lobby" or self.Phase == "Countdown" or self.Phase == "Results")
		and hrp ~= nil
		and (hrp.Position - self.World.Spawn.Position).Magnitude < 35
end

function Game.personal(self: any, player: Player)
	local stats = self.Participants[player]
	self.Event:FireClient(player, "Personal", {
		Inventory = self.Inventory:snapshot(player),
		CanShop = self:canShop(player),
		Participant = stats ~= nil,
		Downed = stats ~= nil and stats.Downed,
		Hidden = stats ~= nil and stats.Hidden ~= nil,
		Recovery = if stats and stats.RecoverAt
			then math.max(0, math.ceil(stats.RecoverAt - os.clock()))
			else 0,
		Carry = player:GetAttribute("Carrying"),
		Large = player:GetAttribute("LargeCarry"),
		ActiveSeconds = if stats then math.floor(stats.Active) else 0,
		CarrySeconds = if stats then math.floor(stats.Carry) else 0,
		Contributed = stats ~= nil
			and (
				stats.Deliveries > 0
				or stats.Rescues > 0
				or stats.Carry >= Config.ParticipationCarrySeconds
			),
	})
end

function Game.broadcast(self: any)
	local checklist = {}
	for _, item in self.Furniture.Items do
		table.insert(
			checklist,
			{ Name = item.Name, Delivered = item.Delivered, Large = item.Large }
		)
	end
	local supplier = self.Boost or self.Selected
	local onTruck, crew = 0, 0
	for player, stats in self.Participants do
		crew += 1
		local hrp = root(player)
		if hrp and not stats.Downed and Map.inTruck(self.World, hrp.Position) then
			onTruck += 1
		end
	end
	self.Event:FireAllClients("State", {
		Phase = self.Phase,
		Time = math.max(0, math.ceil(self.Deadline - os.clock())),
		Noise = math.floor(self.Noise),
		Delivered = self.Delivered,
		Required = self.Required,
		Hunting = self.Monster.Hunting,
		Result = self.Result,
		HuntTime = math.max(0, math.ceil(self.Monster.EndAt - os.clock())),
		Checklist = checklist,
		Boost = if supplier
			then {
				Key = supplier.Key,
				Name = supplier.Name,
				UserId = supplier.UserId,
				Active = self.Boost ~= nil,
			}
			else nil,
		OnTruck = onTruck,
		Crew = crew,
		Stage = Config.Stage,
	})
	for _, player in Players:GetPlayers() do
		self:personal(player)
	end
end

function Game.character(self: any, player: Player, char: Model)
	local hrp = char:WaitForChild("HumanoidRootPart", 10) :: BasePart?
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then
		return
	end
	for _, part in char:GetDescendants() do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Movers"
		end
	end
	char.DescendantAdded:Connect(function(part)
		if part:IsA("BasePart") then
			part.CollisionGroup = "Movers"
		end
	end)
	hum.WalkSpeed, hum.JumpPower, hum.JumpHeight = Config.WalkSpeed, 0, 0
	local stats = self.Participants[player]
	if stats and self.Phase == "Playing" then
		char:PivotTo(CFrame.new(stats.LastPos or self.World.Spawn.Position))
		if stats.Downed then
			hrp.Anchored = true
			self:rescuePrompt(player)
		end
	else
		char:PivotTo(self.World.Spawn * CFrame.new(math.random(-3, 3), 0, math.random(-3, 3)))
	end
	Cosmetics.apply(player, self.Inventory:snapshot(player))
	hum.Died:Connect(function()
		if self.Phase == "Playing" and self.Participants[player] then
			self:down(player)
		end
		task.delay(2, function()
			if player.Parent == Players then
				pcall(function()
					player:LoadCharacterAsync()
				end)
			end
		end)
	end)
end

function Game.join(self: any, player: Player)
	player:SetAttribute("Flashlight", true)
	player.CharacterAdded:Connect(function(char)
		self:character(player, char)
	end)
	task.spawn(function()
		self.Inventory:load(player)
	end)
	task.spawn(function()
		pcall(function()
			player:LoadCharacterAsync()
		end)
	end)
	if self.Phase == "Playing" or self.Phase == "Starting" then
		self:notify(player, "A move is underway. You join the next round for free.")
	end
end

function Game.leave(self: any, player: Player)
	self.Furniture:release(player, false)
	local stats = self.Participants[player]
	if stats and stats.Hidden then
		stats.Hidden.Occupant = nil
	end
	self.Participants[player] = nil
	if self:crewCount() == 1 then
		for _, remaining in self.Participants do
			if remaining.Downed and not remaining.RecoverAt and remaining.Recoveries > 0 then
				remaining.Recoveries -= 1
				remaining.RecoverAt = os.clock() + Config.SoloRecoverySeconds
			end
		end
	end
	if self.Selected and self.Selected.UserId == player.UserId then
		self.Selected = nil
	end
	self.Rates[player], self.HideCooldown[player] = nil, nil
	-- Already queued write-through rewards/receipts finish even after a disconnect.
	self.Inventory.Owned[player.UserId] = nil
end

function Game.queueSave(self: any, id: string, operation: () -> boolean)
	self.Jobs[id] = true
	task.spawn(function()
		local delaySeconds = 2
		while not operation() do
			task.wait(delaySeconds)
			delaySeconds = math.min(30, delaySeconds * 2)
		end
		self.Jobs[id] = nil
	end)
end

function Game.start(self: any)
	if self.Phase ~= "Lobby" then
		return
	end
	self.Phase, self.Deadline = "Countdown", os.clock() + Config.CountdownSeconds
	self:announce("Clock in! Select one optional team boost before the van leaves.")
end

function Game.beginRound(self: any)
	if self.Phase ~= "Countdown" then
		return
	end
	self.Phase = "Starting" -- Locks boost selection before any yielding save.
	local candidates = {}
	for _, player in Players:GetPlayers() do
		if
			root(player)
			and humanoid(player)
			and (humanoid(player) :: Humanoid).Health > 0
			and #candidates < Config.MaxPlayers
		then
			table.insert(candidates, player)
		end
	end
	if #candidates == 0 then
		self.Phase, self.Selected = "Lobby", nil
		return
	end
	self.RoundId = HttpService:GenerateGUID(false)
	self.Furniture:reset()
	self.Monster:reset()
	self.Noise, self.Delivered, self.Boost, self.Result = 0, 0, nil, ""
	self.Participants = {}
	for index, player in candidates do
		local hrp = root(player)
		if hrp then
			player.Character:PivotTo(self.World.Spawn * CFrame.new((index - 1) * 3, 0, 0))
			self.Participants[player] = {
				Active = 0,
				Carry = 0,
				Deliveries = 0,
				Rescues = 0,
				Downed = false,
				Hidden = nil,
				Recoveries = Config.SoloRecoveries,
				LastPos = hrp.Position,
				LastStep = 0,
				Sprint = false,
				ImmuneUntil = 0,
			}
		end
	end
	self.StartCount = #candidates
	self.Required = Config.DeliveryTargets[self.StartCount]
	local selected = self.Selected
	if selected and table.find(candidates, Players:GetPlayerByUserId(selected.UserId)) then
		local activated = false
		for _ = 1, 3 do
			if self.Inventory:consume(selected.UserId, self.RoundId, selected.Key) then
				activated = true
				break
			end
			task.wait(1)
		end
		if activated then
			self.Boost = selected
		else
			self:announce(
				"Boost could not be confirmed. Starting without it; any uncertain charge will be refunded."
			)
			local id = self.RoundId
			self:queueSave("refund" .. id, function()
				return self.Inventory:refund(selected.UserId, id, selected.Key)
			end)
		end
	end
	self.Selected = nil
	if next(self.Participants) == nil then
		if self.Boost then
			local boost, id = self.Boost, self.RoundId
			self:queueSave("refund" .. id, function()
				return self.Inventory:refund(boost.UserId, id, boost.Key)
			end)
		end
		self.Phase, self.Boost = "Lobby", nil
		return
	end
	-- No yield between successful activation and gameplay start.
	self.Phase, self.Deadline = "Playing", os.clock() + Config.RoundSeconds
	if self.Boost then
		local boost, id = self.Boost, self.RoundId
		self:queueSave("activate" .. id, function()
			return self.Inventory:confirm(boost.UserId, id)
		end)
	end
	self:announce(
		"Load any "
			.. self.Required
			.. " labeled items. Then get EVERY remaining mover into the truck!"
	)
end

function Game.finish(self: any, won: boolean, reason: string)
	if self.Phase ~= "Playing" then
		return
	end
	self.Phase, self.Deadline, self.Result = "Results", os.clock() + Config.ResultsSeconds, reason
	self.Monster:reset()
	for player, stats in self.Participants do
		self.Furniture:release(player, false)
		if stats.Hidden then
			stats.Hidden.Occupant = nil
			stats.Hidden = nil
		end
		local hrp = root(player)
		if hrp then
			hrp.Anchored = false
			player.Character:PivotTo(self.World.Spawn)
		end
		local prompt = hrp and hrp:FindFirstChild("Rescue")
		if prompt then
			prompt:Destroy()
		end
		stats.Downed = false
		local qualifies = Rules.meaningful(
			stats.Active,
			stats.Carry,
			stats.Deliveries,
			stats.Rescues,
			Config.ParticipationSeconds,
			Config.ParticipationCarrySeconds
		)
		if qualifies and Config.Stage == 3 then
			local uid, id = player.UserId, self.RoundId
			self:queueSave("attempt" .. id .. uid, function()
				return self.Inventory:complete(uid, id, true)
			end)
			self:notify(
				player,
				"Attempt qualifies for free-use progress. Reward saves automatically; outages are retried."
			)
		else
			self:notify(
				player,
				"Free-use progress needs 45 moving seconds plus 12 carrying seconds, a delivery, or a rescue."
			)
		end
	end
	self:announce((if won then "JOB COMPLETE! " else "SHIFT OVER. ") .. reason, "Result")
end

function Game.delivered(self: any, item: any, carriers: { Player })
	self.Delivered += 1
	Map.loadedCargo(self.World, self.Delivered)
	for _, player in carriers do
		local stats = self.Participants[player]
		if stats then
			stats.Deliveries += 1
		end
	end
	self:announce(item.Name .. " loaded! " .. self.Delivered .. "/" .. self.Required)
	if self.Delivered >= self.Required then
		self:announce("Checklist complete. Everyone into the truck to escape!")
	end
end

function Game.addNoise(self: any, amount: number, category: string, pos: Vector3)
	if Config.Stage < 2 or self.Phase ~= "Playing" then
		return
	end
	local key = if self.Boost then self.Boost.Key else nil
	local strength = if key then Config.Catalog[key].Strength else 0
	self.Noise = math.clamp(self.Noise + Rules.noise(amount, category, key, strength), 0, 100)
	self.Monster.Investigate = pos
	if category == "Furniture" then
		self.Event:FireAllClients("Sound", { Kind = "Bump", Position = pos })
	end
	if self.Noise >= 100 then
		self.Monster:wake()
	end
end

function Game.hide(self: any, player: Player, spot: any)
	local stats, hrp = self.Participants[player], root(player)
	if not stats or not hrp or self.Phase ~= "Playing" or stats.Downed then
		return
	end
	if os.clock() < (self.HideCooldown[player] or 0) then
		return
	end
	self.HideCooldown[player] = os.clock() + 0.7
	if stats.Hidden then
		stats.Hidden.Occupant = nil
		stats.Hidden = nil
		hrp.Anchored = false
		self:notify(player, "You left your hiding place.")
		return
	end
	if spot.Occupant or (hrp.Position - spot.Position).Magnitude > 8 then
		return
	end
	if workspace:Raycast(hrp.Position, spot.Position - hrp.Position, self.Furniture.WallRay) then
		return
	end
	if self.Furniture.Carrying[player] then
		self:notify(player, "Put the furniture down before hiding.")
		return
	end
	if self.Monster.Hunting and self.Monster:canSee(player, true) then
		self:notify(player, "It can see you! Break sight before hiding.")
		return
	end
	stats.Hidden, spot.Occupant = spot, player
	hrp.CFrame, hrp.Anchored, stats.Sprint = CFrame.new(spot.Position), true, false
	stats.LastPos = spot.Position
	self:notify(player, "Hidden. Press E near the wardrobe or tap LEAVE HIDE.")
end

function Game.rescuePrompt(self: any, player: Player)
	local hrp = root(player)
	if not hrp then
		return
	end
	local old = hrp:FindFirstChild("Rescue")
	if old then
		old:Destroy()
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name, prompt.ActionText, prompt.ObjectText =
		"Rescue", "Help (stay nearby 3s)", player.DisplayName
	prompt.MaxActivationDistance, prompt.KeyboardKeyCode, prompt.Parent = 7, Enum.KeyCode.E, hrp
	prompt.Triggered:Connect(function(rescuer: Player)
		local stats, rr = self.Participants[player], root(rescuer)
		if
			rescuer == player
			or not stats
			or not stats.Downed
			or stats.Rescue
			or not self:canAct(rescuer)
			or self.Furniture.Carrying[rescuer]
		then
			return
		end
		if not rr or (rr.Position - hrp.Position).Magnitude > 7 then
			return
		end
		if workspace:Raycast(rr.Position, hrp.Position - rr.Position, self.Furniture.WallRay) then
			return
		end
		stats.Rescue = { Player = rescuer, At = os.clock() + Config.RescueSeconds }
		self:notify(rescuer, "Helping... stay within reach for 3 seconds.")
	end)
end

function Game.down(self: any, player: Player)
	local stats = self.Participants[player]
	if not stats or stats.Downed or self.Phase ~= "Playing" then
		return
	end
	stats.Downed, stats.Sprint, stats.Rescue = true, false, nil
	if stats.Hidden then
		stats.Hidden.Occupant = nil
		stats.Hidden = nil
	end
	self.Furniture:release(player, true)
	local hrp = root(player)
	if hrp then
		hrp.Anchored = true
		stats.LastPos = hrp.Position
	end
	local count = 0
	for _ in self.Participants do
		count += 1
	end
	if count == 1 and stats.Recoveries > 0 then
		stats.Recoveries -= 1
		stats.RecoverAt = os.clock() + Config.SoloRecoverySeconds
		self:notify(
			player,
			"Company smelling salts in 9 seconds. "
				.. stats.Recoveries
				.. " solo recoveries remain."
		)
	else
		self:notify(player, "Downed! A teammate can help you back up.")
	end
	self:rescuePrompt(player)
end

function Game.revive(self: any, player: Player)
	local stats, hrp = self.Participants[player], root(player)
	if not stats or not hrp then
		return
	end
	stats.Downed, stats.RecoverAt, stats.Rescue, stats.ImmuneUntil = false, nil, nil, os.clock() + 5
	hrp.Anchored = false
	local prompt = hrp:FindFirstChild("Rescue")
	if prompt then
		prompt:Destroy()
	end
	self:notify(player, "Back on your feet. Five seconds to get clear!")
end

function Game.action(self: any, player: Player, verb: any, value: any, extra: any)
	if type(verb) ~= "string" or #verb > 24 then
		return
	end
	if type(value) == "string" and #value > 40 then
		return
	end
	local now = os.clock()
	local rate = self.Rates[player] or { Tokens = 10, At = now, Slow = 0 }
	rate.Tokens = math.min(10, rate.Tokens + (now - rate.At) * 5)
	rate.At, self.Rates[player] = now, rate
	if rate.Tokens < 1 then
		return
	end
	rate.Tokens -= 1
	if verb == "Sync" then
		if now >= (rate.SyncAt or 0) then
			rate.SyncAt = now + 5
			self:broadcast()
		end
	elseif verb == "Start" then
		self:start()
	elseif verb == "Drop" then
		self.Furniture:release(player, true)
	elseif verb == "Rotate" then
		self.Furniture:rotate(player, value)
	elseif verb == "Sprint" and type(value) == "boolean" then
		local stats = self.Participants[player]
		if stats then
			stats.Sprint = value
		end
	elseif verb == "LeaveHide" then
		local stats = self.Participants[player]
		if stats and stats.Hidden then
			self:hide(player, stats.Hidden)
		end
	elseif verb == "Flashlight" then
		player:SetAttribute("Flashlight", player:GetAttribute("Flashlight") == false)
		Cosmetics.apply(player, self.Inventory:snapshot(player))
	elseif
		verb == "SelectBoost"
		and self:canShop(player)
		and (self.Phase == "Lobby" or self.Phase == "Countdown")
	then
		if value == "None" then
			if self.Selected and self.Selected.UserId == player.UserId then
				self.Selected = nil
			end
		elseif Rules.isBoost(value) then
			if self.Selected then
				self:notify(
					player,
					"The team boost slot is already reserved. Its supplier can cancel it."
				)
				return
			end
			local data = self.Inventory.Cache[player.UserId]
			if data and data.uses[value] > 0 then
				self.Selected = { UserId = player.UserId, Name = player.DisplayName, Key = value }
				self:announce(
					player.DisplayName
						.. " offers "
						.. Config.Catalog[value].Name
						.. ". One use activates at round start."
				)
			else
				self:notify(
					player,
					"No saved uses available. Earn one every two qualifying attempts."
				)
			end
		end
	elseif self:canShop(player) and now >= rate.Slow then
		rate.Slow = now + 2
		if verb == "Preference" and Rules.isBoost(value) then
			task.spawn(function()
				self.Inventory:choose(player, value)
			end)
		elseif verb == "Cosmetic" and type(value) == "string" then
			task.spawn(function()
				self.Inventory:cosmetic(player, value, extra)
			end)
		elseif verb == "Refresh" then
			task.spawn(function()
				self.Inventory:load(player)
			end)
		elseif verb == "Buy" and type(value) == "string" then
			local catalog = Config.Catalog[value]
			if not catalog or self.Inventory.Memory or not self.Inventory.Cache[player.UserId] then
				return
			end
			local id = catalog.ProductId or catalog.PassId
			if id <= 0 or (value == "CrewPack" and self.Inventory.Owned[player.UserId]) then
				return
			end
			self.Event:FireClient(player, "Purchase", { Key = value, Id = id, Kind = catalog.Kind })
		end
	end
end

function Game.step(self: any, dt: number)
	if self.Phase == "Countdown" and os.clock() >= self.Deadline then
		task.spawn(function()
			self:beginRound()
		end)
	end
	if self.Phase == "Results" and os.clock() >= self.Deadline then
		self.Phase, self.Participants, self.Boost, self.Selected = "Lobby", {}, nil, nil
		self.Noise, self.Delivered = 0, 0
		self.Furniture:reset()
	end
	for _, player in Players:GetPlayers() do
		local stats, hum, hrp = self.Participants[player], humanoid(player), root(player)
		if not hum or not hrp then
			continue
		end
		if self.Phase ~= "Playing" then
			hum.WalkSpeed = Config.WalkSpeed
			continue
		end
		if not stats then
			hum.WalkSpeed = Config.WalkSpeed
			if (hrp.Position - self.World.Spawn.Position).Magnitude > 22 then
				player.Character:PivotTo(self.World.Spawn)
			end
			continue
		end
		local item = self.Furniture.Carrying[player]
		hum.WalkSpeed = if stats.Downed or stats.Hidden
			then 0
			elseif item then (if item.Large and self:crewCount() == 1
				then Config.SoloDragSpeed
				else Config.CarrySpeed)
			elseif stats.Sprint then Config.SprintSpeed
			else Config.WalkSpeed
		local traveled = (hrp.Position - stats.LastPos).Magnitude
		if traveled > Config.SprintSpeed * dt + 7 then
			self.Furniture:release(player, false)
			hrp.CFrame = CFrame.new(stats.LastPos)
			traveled = 0
		end
		if hrp.Position.Y < -15 then
			self:down(player)
			hrp.CFrame = self.World.Spawn
		end
		if self:canAct(player) and traveled > 0.1 then
			stats.Active += dt
			if item then
				stats.Carry += dt
			end
			if os.clock() - stats.LastStep > (if stats.Sprint and not item then 0.45 else 0.85) then
				stats.LastStep = os.clock()
				self:addNoise(
					if stats.Sprint and not item then Config.Noise.Sprint else Config.Noise.Walk,
					"Footstep",
					hrp.Position
				)
			end
		end
		stats.LastPos = hrp.Position
		if stats.Downed then
			if stats.RecoverAt and os.clock() >= stats.RecoverAt then
				self:revive(player)
			end
			if stats.Rescue then
				local rescuer = stats.Rescue.Player
				local rr = root(rescuer)
				if
					not self:canAct(rescuer)
					or not rr
					or (rr.Position - hrp.Position).Magnitude > 7
					or self.Furniture.Carrying[rescuer]
				then
					stats.Rescue = nil
				elseif os.clock() >= stats.Rescue.At then
					self.Participants[rescuer].Rescues += 1
					self:revive(player)
				end
			end
		end
	end
	if self.Phase ~= "Playing" then
		return
	end
	self.Furniture:step(dt)
	self.Noise = math.max(0, self.Noise - Config.Noise.Decay * dt)
	self.Monster:step()
	if
		self.Noise >= Config.Noise.Medium
		and not self.Monster.Hunting
		and os.clock() - self.LastAmbience > 7
	then
		self.LastAmbience = os.clock()
		self.Event:FireAllClients("Ambience", self.World.MonsterSpawn.Position)
		for _, light in self.World.Lights do
			light.Enabled = false
		end
		task.delay(0.25, function()
			for _, light in self.World.Lights do
				light.Enabled = true
			end
		end)
	end
	if os.clock() - self.LastContract > 35 then
		self.LastContract = os.clock()
		self:announce(Config.Contracts[math.random(1, #Config.Contracts)])
	end
	local alive, aboard, crew, recovering = 0, 0, 0, false
	for player, stats in self.Participants do
		crew += 1
		if not stats.Downed then
			alive += 1
		end
		if stats.RecoverAt then
			recovering = true
		end
		local hrp = root(player)
		if hrp and not stats.Downed and Map.inTruck(self.World, hrp.Position) then
			aboard += 1
		end
	end
	if crew == 0 then
		self:finish(false, "The crew left. No invoice was issued.")
	elseif alive == 0 and not recovering then
		self:finish(false, "The whole crew needs a nap. Try again for free.")
	elseif self.Delivered >= self.Required and aboard == crew then
		self:finish(true, "Everyone escaped with the furniture!")
	elseif os.clock() >= self.Deadline then
		self:finish(false, "Seven minutes are up. The house kept the deposit.")
	end
end
return Game
