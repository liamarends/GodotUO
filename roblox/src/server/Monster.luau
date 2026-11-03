--!strict
local PathfindingService = game:GetService("PathfindingService")
local Config = require(game:GetService("ReplicatedStorage").Shared.GameConfig)
local Map = require(script.Parent.Map)
local Monster = {}

function Monster.new(world: any, gameState: any): any
	local model = Instance.new("Model")
	model.Name, model.Parent = "The Duvet", world.Folder
	local root =
		Map.part(model, "HumanoidRootPart", Vector3.new(3, 2, 2), world.MonsterSpawn, Color3.new())
	root.Transparency, root.Anchored = 1, false
	local joints: { Motor6D } = {}
	local function body(name: string, size: Vector3, offset: Vector3, color: Color3): Part
		local p = Map.part(model, name, size, root.CFrame * CFrame.new(offset), color)
		p.Anchored, p.Massless, p.CanCollide = false, true, false
		local weld = Instance.new("Motor6D")
		weld.Name, weld.Part0, weld.Part1, weld.C0, weld.Parent =
			name .. "Joint", root, p, CFrame.new(offset), root
		if name == "BlanketArm" or name == "Slipper" or name == "Head" then
			table.insert(joints, weld)
		end
		p.CanQuery, p.CanTouch = false, false
		p.Material = Enum.Material.Fabric
		return p
	end
	body("Torso", Vector3.new(4, 4, 2.6), Vector3.new(0, 0.5, 0), Color3.fromRGB(87, 97, 129))
	body("Head", Vector3.new(4.5, 2.5, 2.5), Vector3.new(0, 3.5, 0), Color3.fromRGB(209, 209, 188))
	for _, x in { -1, 1 } do
		local eye = body(
			"SleepyEye",
			Vector3.new(0.7, 0.25, 0.2),
			Vector3.new(x, 3.6, -1.3),
			Color3.fromRGB(255, 186, 80)
		)
		eye.Material = Enum.Material.Neon
		body(
			"BlanketArm",
			Vector3.new(0.8, 4.5, 1),
			Vector3.new(x * 2.4, 0.5, 0),
			Color3.fromRGB(108, 119, 150)
		)
		body(
			"Slipper",
			Vector3.new(1.6, 0.6, 2.4),
			Vector3.new(x, -2, -0.3),
			Color3.fromRGB(181, 126, 121)
		)
	end
	local humanoid = Instance.new("Humanoid")
	humanoid.RequiresNeck, humanoid.HipHeight, humanoid.WalkSpeed = false, 2, Config.Monster.Speed
	humanoid.DisplayDistanceType, humanoid.Parent = Enum.HumanoidDisplayDistanceType.None, model
	model.PrimaryPart = root
	root:SetNetworkOwner(nil)
	local tag = Instance.new("BillboardGui")
	tag.Name, tag.Size, tag.StudsOffset, tag.AlwaysOnTop, tag.Parent =
		"SleepLabel", UDim2.fromOffset(140, 40), Vector3.new(0, 6, 0), false, root
	local label = Instance.new("TextLabel")
	label.Size, label.BackgroundTransparency, label.TextScaled = UDim2.fromScale(1, 1), 1, true
	label.Font, label.TextColor3, label.Text, label.Parent =
		Enum.Font.GothamBold, Color3.fromRGB(255, 217, 163), "z Z z...", tag
	-- A quilted doorframe silhouette: the house wears the blanket left on its last bed.
	body(
		"MemoryLintel",
		Vector3.new(6, 0.5, 0.5),
		Vector3.new(0, 5, 0.6),
		Color3.fromRGB(92, 72, 59)
	)
	for _, x in { -1, 1 } do
		body(
			"MemoryJamb",
			Vector3.new(0.5, 7, 0.5),
			Vector3.new(x * 2.8, 1.7, 0.6),
			Color3.fromRGB(92, 72, 59)
		)
	end
	for i = 1, 3 do
		body(
			"QuiltPatch",
			Vector3.new(1, 0.8, 0.1),
			Vector3.new(i - 2, 0.5, -1.35),
			Color3.fromRGB(143, 113 + i * 15, 98)
		)
	end
	for row = 1, 4 do
		for col = 1, 4 do
			body(
				"QuiltStitch",
				Vector3.new(0.65, 0.06, 0.08),
				Vector3.new((col - 2.5) * 0.85, row * 0.75 - 1.4, -1.35),
				Color3.fromRGB(181, 161, 123)
			)
		end
	end
	for _, x in { -1, 1 } do
		body(
			"HangingTassel",
			Vector3.new(0.15, 1.5, 0.15),
			Vector3.new(x * 1.7, -1.5, -1.1),
			Color3.fromRGB(132, 110, 81)
		)
	end
	local self: any = {
		World = world,
		Game = gameState,
		Model = model,
		Root = root,
		Humanoid = humanoid,
		Label = label,
		Hunting = false,
		EndAt = 0,
		RestUntil = 0,
		LastPath = 0,
		PathBusy = false,
		Points = {},
		Index = 1,
		Investigate = world.MonsterSpawn.Position,
		Attack = nil,
		Generation = 0,
		KnockAt = 0,
		Joints = joints,
	}
	setmetatable(self, { __index = Monster })
	self:reset()
	return self
end

function Monster.reset(self: any)
	self.Generation += 1
	self.Hunting, self.Attack, self.Points = false, nil, {}
	self.Root.Anchored = true
	self.Model:PivotTo(self.World.MonsterSpawn)
	self.Label.Text = "z Z z..."
	self.RestUntil = os.clock() + Config.Monster.RestSeconds
	local seal = self.World.MemorySeal
	if seal then
		seal.Transparency, seal.CanCollide, seal.CanQuery = 0, true, true
	end
end

function Monster.wake(self: any)
	if self.Hunting or os.clock() < self.RestUntil then
		return
	end
	self.Hunting, self.EndAt, self.LastPath = true, os.clock() + Config.Monster.HuntSeconds, 0
	self.WakeAt = os.clock() + 2
	self.KnockAt = 0
	self.Root.Anchored = false
	self.Root:SetNetworkOwner(nil)
	local seal = self.World.MemorySeal
	if seal then
		seal.Transparency, seal.CanCollide, seal.CanQuery = 1, false, false
	end
	self.Label.Text = "WHO MOVED MY SOFA?"
	self.Game:announce("THE DUVET IS AWAKE! Break sight, then hide in a wardrobe.", "Hunt")
end

function Monster.canSee(self: any, player: Player, ignoreCone: boolean?): boolean
	if not self.Game:canAct(player) then
		return false
	end
	local stats = self.Game.Participants[player]
	if stats and os.clock() < stats.ImmuneUntil then
		return false
	end
	local char = player.Character
	local hrp = if char then char:FindFirstChild("HumanoidRootPart") :: BasePart? else nil
	if not hrp then
		return false
	end
	local origin = self.Root.Position + Vector3.new(0, 2, 0)
	local offset = hrp.Position - origin
	if offset.Magnitude > Config.Monster.ViewDistance then
		return false
	end
	if
		not ignoreCone
		and offset.Magnitude > 10
		and self.Root.CFrame.LookVector:Dot(offset.Unit) < 0.05
	then
		return false
	end
	local params = RaycastParams.new()
	params.FilterType, params.FilterDescendantsInstances =
		Enum.RaycastFilterType.Exclude, { self.Model }
	local hit = workspace:Raycast(origin, offset, params)
	return hit == nil or hit.Instance:IsDescendantOf(char :: Model)
end

function Monster.pathTo(self: any, destination: Vector3)
	if self.PathBusy or os.clock() - self.LastPath < 1 then
		return
	end
	self.LastPath, self.PathBusy = os.clock(), true
	local generation = self.Generation
	task.spawn(function()
		local path = PathfindingService:CreatePath({
			AgentRadius = 2,
			AgentHeight = 7,
			AgentCanJump = true,
			WaypointSpacing = 3,
		})
		local ok = pcall(function()
			path:ComputeAsync(self.Root.Position, destination)
		end)
		if generation == self.Generation and self.Hunting then
			if ok and path.Status == Enum.PathStatus.Success then
				self.Points, self.Index = path:GetWaypoints(), 2
			else
				self.Points = {}
				-- MoveTo respects walls/physics even if a route temporarily fails.
				self.Humanoid:MoveTo(destination)
			end
		end
		self.PathBusy = false
	end)
end

function Monster.step(self: any)
	for i, joint in self.Joints do
		joint.C0 = CFrame.new(joint.C0.Position)
			* CFrame.Angles(
				math.sin(os.clock() * (if self.Hunting then 5 else 0.8) + i)
					* (if self.Hunting then 0.22 else 0.035),
				0,
				0
			)
	end
	if not self.Hunting then
		return
	end
	if os.clock() >= self.EndAt or self.Game.Phase ~= "Playing" then
		self:reset()
		self.Game.Noise = math.min(self.Game.Noise, 25)
		self.Game:announce(
			"The Duvet went back to bed. Quietly resume your questionable employment.",
			"Rest"
		)
		return
	end
	if os.clock() < self.WakeAt then
		self.Humanoid:MoveTo(self.Root.Position)
		return
	end
	if os.clock() > self.KnockAt then
		self.KnockAt = os.clock() + 3
		self.Game.House:cue(
			"Duvet",
			"The Duvet: two knocks, then a dragging blanket.",
			self.Root.Position
		)
	end
	local nearest: Player? = nil
	local best = math.huge
	for player in self.Game.Participants do
		if self:canSee(player) then
			local hrp = player.Character
				and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if hrp then
				local distance = (hrp.Position - self.Root.Position).Magnitude
				if distance < best then
					nearest, best = player, distance
				end
			end
		end
	end
	if self.Attack then
		local attack = self.Attack
		self.Humanoid:MoveTo(self.Root.Position)
		if os.clock() >= attack.At then
			self.Attack = nil
			local hrp = attack.Player.Character
				and attack.Player.Character:FindFirstChild("HumanoidRootPart")
			if
				hrp
				and self:canSee(attack.Player, true)
				and (hrp.Position - self.Root.Position).Magnitude
					<= Config.Monster.AttackDistance + 1
			then
				self.Game:down(attack.Player)
			end
			self.Label.Text = "Shhhh..."
		end
		return
	end
	if nearest and best <= Config.Monster.AttackDistance then
		self.Attack = { Player = nearest, At = os.clock() + Config.Monster.WarningSeconds }
		self.Label.Text = "SHHH! MOVE AWAY!"
		self.Game.Event:FireClient(nearest, "Warning", "The Duvet is reaching! Move away now!")
		self.Humanoid:MoveTo(self.Root.Position)
		return
	end
	if nearest and nearest.Character then
		self.Investigate = (nearest.Character:FindFirstChild("HumanoidRootPart") :: BasePart).Position
	end
	self:pathTo(self.Investigate)
	local waypoint = self.Points[self.Index]
	if waypoint then
		if (waypoint.Position - self.Root.Position).Magnitude < 3 then
			self.Index += 1
		end
		if waypoint.Action == Enum.PathWaypointAction.Jump then
			self.Humanoid.Jump = true
		end
		self.Humanoid:MoveTo(waypoint.Position)
	end
end
return Monster
