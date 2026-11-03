--!strict
local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage").Shared
local Config, Rules = require(Shared.GameConfig), require(Shared.Rules)
local Map = require(script.Parent.Map)
local House = {}
local stories = {
	"A moving label reads: KEEP THE LIGHT ON. Someone underlined KEEP.",
	"Inside the box: twelve birthday cards, all signed 'Still here.'",
	"The armchair's tag says: Dad's seat. Please face the window.",
	"The music box contains a note: Play this when you get home.",
	"Two impressions remain in the sofa. Nobody sat here tonight.",
	"The table has pencil marks measuring a child who stopped growing.",
	"A letter begins: We meant to leave together.",
	"The drawer contains a key labeled 'the next house'.",
	"On the mirror: Don't look for us. Remember us.",
	"Grandma's rocker has a ticket for a journey she never took.",
	"A blanket is folded for a guest who never arrived.",
	"An unfinished list ends: Tell the house goodbye.",
}
local hints = {
	Rocker = "ROCKER: steady it before leaving it alone.",
	Music = "MUSIC BOX: stay level; lower it on the stairs.",
	Mirror = "MIRROR: amber glass warns of movement behind you.",
	Drawer = "DRAWER: pause a second between turns; steady to close.",
	Homesick = "HOMESICK: keep it in sight, or steady it for 30s.",
}
local function root(p: Player): BasePart?
	return if p.Character then p.Character:FindFirstChild("HumanoidRootPart") :: BasePart? else nil
end
function House.new(world: any, gameState: any): any
	local self: any = {
		World = world,
		Game = gameState,
		Doors = {},
		Portraits = {},
		Round = 0,
		IncidentAt = 0,
		Disturbance = 0,
		LastNoise = Vector3.zero,
		RestoredAt = 0,
		AmbientAt = 0,
	}
	setmetatable(self, { __index = House })
	for _, location in
		{ Vector3.new(-10, 1, -8), Vector3.new(-10, 14, -8), Vector3.new(-7, 1, -60) }
	do
		local y = location.Y
		local rear = location.Z == -60
		local hinge = CFrame.new(location) * CFrame.Angles(0, if rear then math.pi / 2 else 0, 0)
		local door = Map.part(
			world.Blockers,
			"MemoryDoor",
			Vector3.new(0.5, 8, 10),
			hinge * CFrame.new(0, 4, 5),
			Color3.fromRGB(83, 103, 111),
			Enum.Material.Wood
		)
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText, prompt.ObjectText, prompt.MaxActivationDistance, prompt.Parent =
			"Open path", "Memory door · wedge keeps open", 8, door
		local entry = {
			Part = door,
			Hinge = hinge,
			Angle = math.pi / 2,
			Target = math.pi / 2,
			WedgeUntil = 0,
		}
		table.insert(self.Doors, entry)
		require(script.Parent.Environment).text(
			door,
			if rear then "GARDEN EXIT\nOPEN THE LONG WAY" else "VALE HOUSE\nPLEASE CLOSE QUIETLY",
			Enum.NormalId.Right
		)
		prompt.Triggered:Connect(function(p: Player)
			local hrp = root(p)
			if
				not gameState:canAct(p)
				or not hrp
				or (hrp.Position - door.Position).Magnitude > 9
			then
				return
			end
			entry.Target = math.pi / 2
			self:cue("Latch", "The door remembers being open.", door.Position)
		end)
		local portrait = Map.part(
			world.Folder,
			"FamilyPortrait",
			Vector3.new(3, 4, 0.3),
			CFrame.new(-20, y + 6, -23.3),
			Color3.fromRGB(151, 127, 92)
		)
		local face = Map.part(
			world.Folder,
			"FadedFace",
			Vector3.new(1.3, 2, 0.4),
			portrait.CFrame * CFrame.new(0, 0, -0.25),
			Color3.fromRGB(178, 179, 166)
		)
		portrait.CanCollide, portrait.CanQuery, face.CanCollide, face.CanQuery =
			false, false, false, false
		table.insert(self.Portraits, { Frame = portrait, Face = face, Home = portrait.CFrame })
	end
	local rug = Map.part(
		world.Folder,
		"QuietRoute",
		Vector3.new(4, 0.05, 34),
		CFrame.new(12, 1.04, 4),
		Color3.fromRGB(56, 109, 109),
		Enum.Material.Fabric
	)
	rug.CanCollide, rug.CanQuery = false, false
	self.Rug = rug
	local boards = Map.part(
		world.Folder,
		"CreakyShortcut",
		Vector3.new(7, 0.05, 16),
		CFrame.new(0, 1.05, 12),
		Color3.fromRGB(156, 111, 70),
		Enum.Material.WoodPlanks
	)
	boards.CanCollide, boards.CanQuery = false, false
	self.Boards = boards
	return self
end
function House.cue(self: any, kind: string, text: string, pos: Vector3)
	self.Game.Event:FireAllClients("Cue", { Kind = kind, Text = text, Position = pos })
end
function House.reset(self: any)
	self.Round += 1
	local route = if self.Round == 1 then 0 else math.random(0, 1)
	self.Boards.Position = Vector3.new(route * 4, 1.05, 12)
	self.Rug.Position = Vector3.new(12 + route * 4, 1.04, 4)
	self.IncidentAt, self.Disturbance, self.RestoredAt = os.clock() + Config.ComplicationDelay, 0, 0
	self.Game.Optional = 0
	self.Game.Report =
		{ Loudest = 0, Accident = "Nothing broken. Suspicious.", Rescues = 0, Reward = 0 }
	for _, d in self.Doors do
		d.Angle, d.Target, d.WedgeUntil = math.pi / 2, math.pi / 2, 0
		d.Part.CFrame = d.Hinge * CFrame.Angles(0, d.Angle, 0) * CFrame.new(0, 4, 5)
	end
	for _, light in self.World.Lights do
		light.Enabled = true
	end
	for _, p in self.Portraits do
		p.Face.CFrame = p.Home * CFrame.new(0, 0, -0.25)
	end
	local order = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 }
	-- First contract emphasizes downstairs handling; later contracts vary without moving walls.
	if self.Round > 1 then
		for i = #order, 2, -1 do
			local j = math.random(i)
			order[i], order[j] = order[j], order[i]
		end
	end
	local required = Rules.contract(order, self.Game.Required)
	local candidates: { { any } } =
		{ { 3, "Homesick" }, { 4, "Music" }, { 8, "Drawer" }, { 9, "Mirror" }, { 10, "Rocker" } }
	for i = #candidates, 2, -1 do
		local j = math.random(i)
		candidates[i], candidates[j] = candidates[j], candidates[i]
	end
	local active = {}
	for i = 1, (if self.Round == 1 then 1 else 3) do
		active[candidates[i][1]] = candidates[i][2]
	end
	for _, item in self.Game.Furniture.Items do
		item.Required = required[item.Id] == true
		item.Complication = active[item.Id]
		item.Hint = hints[item.Complication] or "Ordinary furniture. Famous last words."
		item.Label.Text = (if item.Required then "CONTRACT · " else "OPTIONAL · ")
			.. item.Name
			.. "\n"
			.. item.Hint
		item.Story = stories[item.Id]
	end
	self.Game.RoundStarted = os.clock()
end
function House.noise(self: any, amount: number, category: string, pos: Vector3)
	self.LastNoise = pos
	if category == "Furniture" or category == "Ping" then
		self.Disturbance += 1
	end
	local report = self.Game.Report
	if report and amount > report.Loudest then
		report.Loudest, report.Accident =
			math.floor(amount),
			category
				.. " near "
				.. (if pos.Y > 12 then "the upstairs rooms" else "the ground floor")
	end
	for _, portrait in self.Portraits do
		local origin = portrait.Face.Position
		if (origin - pos).Magnitude > 1 then
			portrait.Face.CFrame = CFrame.lookAt(origin, Vector3.new(pos.X, origin.Y, pos.Z))
		end
	end
	if amount >= 3 then
		self:cue("Noise", category .. " +" .. math.floor(amount) .. " noise", pos)
	end
end
function House.footstep(self: any, pos: Vector3): number
	if
		pos.Y < 10
		and math.abs(pos.X - self.Boards.Position.X) < 3.5
		and pos.Z > 4
		and pos.Z < 20
	then
		self:cue("Creak", "Creaky shortcut · the teal carpet is quieter", pos)
		return 2
	end
	return 1
end
function House.watched(self: any, pos: Vector3): boolean
	-- Avatar-facing approximation, no camera/location reports trusted from clients.
	for player, stats in self.Game.Participants do
		local hrp = root(player)
		if hrp and not stats.Downed then
			local offset = pos - hrp.Position
			if
				offset.Magnitude < 7
				or (
					offset.Magnitude < 55
					and hrp.CFrame.LookVector:Dot(offset.Unit) > 0.05
					and not workspace:Raycast(hrp.Position, offset, self.Game.Furniture.WallRay)
				)
			then
				return true
			end
		end
	end
	return false
end
function House.equipment(self: any, player: Player)
	if not self.Game:canAct(player) or self.Game.Furniture.Carrying[player] then
		return
	end
	local stats, hrp = self.Game.Participants[player], root(player)
	if not hrp then
		return
	end
	local now = os.clock()
	if now < (stats.ToolAt or 0) then
		self.Game:notify(player, "Equipment is cooling down.")
		return
	end
	if stats.Equipment == "Decoy" then
		local pos = hrp.Position + hrp.CFrame.LookVector * 8
		if workspace:Raycast(hrp.Position, pos - hrp.Position, self.Game.Furniture.WallRay) then
			return
		end
		stats.ToolAt = now + Config.DecoyCooldown
		self.Game.Monster.Investigate = pos
		self.Game:addNoise(2, "Decoy", pos)
		self:cue("Knock", "Decoy: tap… tap… (visible movers still take priority)", pos)
		local marker = Map.part(
			self.World.Folder,
			"WindupDecoy",
			Vector3.new(0.8, 0.8, 0.8),
			CFrame.new(pos - Vector3.new(0, 2, 0)),
			Color3.fromRGB(244, 173, 79)
		)
		marker.CanCollide, marker.CanQuery = false, false
		game:GetService("Debris"):AddItem(marker, 6)
	elseif stats.Equipment == "Wedge" then
		for _, d in self.Doors do
			if (d.Part.Position - hrp.Position).Magnitude < 10 then
				d.Target, d.WedgeUntil = math.pi / 2, now + Config.WedgeSeconds
				stats.ToolAt = now + Config.WedgeSeconds
				self:cue("Latch", "Door wedged open for 45 seconds", d.Part.Position)
				return
			end
		end
		self.Game:notify(player, "Use the wedge within 10 studs of a memory door.")
	else
		self.Game:notify(
			player,
			"Dolly: passively improves solo dragging, but cannot lift a heavy load."
		)
	end
end
function House.step(self: any, dt: number)
	if self.Game.Phase ~= "Playing" then
		return
	end
	local now = os.clock()
	local traces = self.World.Folder:FindFirstChild("MemoryTraces")
	local photo = traces and traces:FindFirstChild("HiddenFamilyPhoto")
	local chair = self.Game.Furniture.Items[3]
	if photo and chair and (chair.Root.Position - chair.Spawn.Position).Magnitude > 3 then
		photo.Transparency = 0
		(photo:FindFirstChildOfClass("SurfaceGui") :: SurfaceGui).Enabled = true
	end
	if now >= self.AmbientAt and not self.Game.Monster.Hunting then
		self.AmbientAt = now + 24
		local sources = self.World.AmbientSources
		if sources and #sources > 0 then
			local source = sources[math.random(1, #sources)]
			self:cue(source.Kind, source.Text, source.Position)
		end
	end
	if
		Config.Stage >= 2
		and not self.Game.Monster.Hunting
		and now >= self.IncidentAt
		and self.Game.Noise >= 35
	then
		self.IncidentAt = now + Config.IncidentCooldown
		local nearest, dist = nil, math.huge
		for _, light in self.World.Lights do
			local lamp = light.Parent :: BasePart
			local distance = (lamp.Position - self.LastNoise).Magnitude
			if distance < dist then
				nearest, dist = light, distance
			end
		end
		if nearest then
			nearest.Enabled = false
			self.RestoredAt = now + 2.5
		end
		local keepsake = self.Game.Furniture.Items[2]
		if
			math.random(1, 3) == 1
			and keepsake
			and not keepsake.Delivered
			and #keepsake.Carriers == 0
			and (keepsake.Root.Position - keepsake.Spawn.Position).Magnitude > 5
			and not self:watched(keepsake.Root.Position)
			and not self:watched(keepsake.Spawn.Position)
		then
			keepsake.Model:PivotTo(keepsake.Spawn)
			keepsake.Angle = 0
			self:cue(
				"Creak",
				"The house returned a misplaced box. It kept the birthday cards.",
				keepsake.Spawn.Position
			)
		end
		self:cue("Knock", "Three familiar knocks. Something wants its room back.", self.LastNoise)
		if self.Disturbance >= 3 then
			for _, d in self.Doors do
				if now > d.WedgeUntil then
					d.Target = 0
				end
			end
			self.Disturbance = 0
		end
	end
	if self.RestoredAt > 0 and now >= self.RestoredAt then
		self.RestoredAt = 0
		for _, light in self.World.Lights do
			light.Enabled = true
		end
	end
	for _, d in self.Doors do
		local nextAngle = d.Angle + math.clamp(d.Target - d.Angle, -dt * 0.6, dt * 0.6)
		local cf = d.Hinge * CFrame.Angles(0, nextAngle, 0) * CFrame.new(0, 4, 5)
		-- Never sweep a door through a mover or any carried/abandoned furniture.
		local blocked = false
		for _, p in Players:GetPlayers() do
			local hrp = root(p)
			if hrp then
				local v = cf:PointToObjectSpace(hrp.Position)
				if math.abs(v.X) < 2.8 and math.abs(v.Z) < 7 and math.abs(v.Y) < 6 then
					blocked = true
				end
			end
		end
		for _, item in self.Game.Furniture.Items do
			if
				not item.Delivered
				and (item.Root.Position - cf.Position).Magnitude < item.Size.Magnitude / 2 + 6
			then
				blocked = true
			end
		end
		if not blocked then
			d.Angle = nextAngle
			d.Part.CFrame = cf
		end
	end
end
return House
