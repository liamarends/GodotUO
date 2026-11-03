--!strict
local Lighting = game:GetService("Lighting")
local Map = {}
local wood = Color3.fromRGB(91, 74, 65)
local cream = Color3.fromRGB(143, 146, 139)
local orange = Color3.fromRGB(224, 132, 49)

function Map.part(
	parent: Instance,
	name: string,
	size: Vector3,
	cf: CFrame,
	color: Color3,
	material: Enum.Material?
): Part
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame, p.Color = name, size, cf, color
	p.Anchored = true
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function sign(
	parent: Instance,
	text: string,
	pos: Vector3,
	size: Vector3,
	color: Color3
): Part
	local p = Map.part(parent, "Sign", size, CFrame.new(pos), color)
	local gui = Instance.new("SurfaceGui")
	gui.Face, gui.SizingMode, gui.PixelsPerStud =
		Enum.NormalId.Front, Enum.SurfaceGuiSizingMode.PixelsPerStud, 36
	gui.Parent = p
	local label = Instance.new("TextLabel")
	label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
	label.Text, label.TextColor3, label.TextScaled = text, Color3.fromRGB(255, 238, 204), true
	label.Font, label.TextWrapped, label.Parent = Enum.Font.GothamBold, true, gui
	return p
end

function Map.build(): any
	local old = workspace:FindFirstChild("HauntedHouse")
	if old then
		old:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name, folder.Parent = "HauntedHouse", workspace
	local blockers = Instance.new("Folder")
	blockers.Name, blockers.Parent = "WallsAndCover", folder
	local floors = Instance.new("Folder")
	floors.Name, floors.Parent = "WalkableSurfaces", folder
	local props = Instance.new("Folder")
	props.Name, props.Parent = "Furniture", folder
	local world: any = {
		Folder = folder,
		Blockers = blockers,
		Floors = floors,
		Props = props,
		Lights = {},
		Hides = {},
		Spawn = CFrame.new(15, 4, 51),
		MonsterSpawn = CFrame.new(0, 17, -16),
	}
	Map.part(
		floors,
		"Yard",
		Vector3.new(180, 2, 180),
		CFrame.new(0, -1, 12),
		Color3.fromRGB(33, 49, 44),
		Enum.Material.Grass
	)
	Map.part(
		floors,
		"GroundFloor",
		Vector3.new(64, 1, 48),
		CFrame.new(0, 0.5, 0),
		wood,
		Enum.Material.WoodPlanks
	)
	Map.part(
		floors,
		"UpperFloor",
		Vector3.new(52, 1, 48),
		CFrame.new(-6, 13.5, 0),
		wood,
		Enum.Material.WoodPlanks
	)
	Map.part(floors, "StairLanding", Vector3.new(12, 1, 8), CFrame.new(26, 13.5, -20), wood)
	Map.part(floors, "UpperFront", Vector3.new(12, 1, 8), CFrame.new(26, 13.5, 20), wood)
	-- Broad, shallow steps fit two players and large furniture.
	for i = 1, 16 do
		local height = i * 13 / 16
		Map.part(
			floors,
			"Stair" .. i,
			Vector3.new(11, height, 2),
			CFrame.new(26, 1 + height / 2, 17 - i * 2),
			wood
		)
	end
	local function wall(name: string, size: Vector3, pos: Vector3, color: Color3?)
		return Map.part(
			blockers,
			name,
			size,
			CFrame.new(pos),
			color or cream,
			Enum.Material.WoodPlanks
		)
	end
	wall("West", Vector3.new(1, 26, 48), Vector3.new(-32, 14, 0))
	wall("East", Vector3.new(1, 26, 48), Vector3.new(32, 14, 0))
	wall("Back", Vector3.new(64, 26, 1), Vector3.new(0, 14, -24))
	wall("FrontLeft", Vector3.new(25, 26, 1), Vector3.new(-19.5, 14, 24))
	wall("FrontRight", Vector3.new(25, 26, 1), Vector3.new(19.5, 14, 24))
	wall("DoorLintel", Vector3.new(14, 17, 1), Vector3.new(0, 18.5, 24))
	wall("Roof", Vector3.new(68, 1, 52), Vector3.new(0, 27.5, 0), Color3.fromRGB(38, 47, 62))
	for _, y in { 7, 20 } do
		wall("RoomWall", Vector3.new(1, 12, 16), Vector3.new(-10, y, -16))
		wall("RoomWall", Vector3.new(1, 12, 20), Vector3.new(-10, y, 14))
		wall("DoorTrim", Vector3.new(1, 3, 12), Vector3.new(-10, y + 4.5, -2))
	end
	wall("StairRail", Vector3.new(0.6, 3, 30), Vector3.new(20, 15.5, -1), wood)
	-- Windows are luminous panels, not collision-free holes in the exterior.
	for _, y in { 7, 20 } do
		for _, x in { -21, 21 } do
			local pane = Map.part(
				folder,
				"MoonlitWindow",
				Vector3.new(7, 6, 0.15),
				CFrame.new(x, y, 23.4),
				Color3.fromRGB(81, 114, 170),
				Enum.Material.Neon
			)
			pane.CanCollide = false
		end
	end
	for _, pos in
		{
			Vector3.new(0, 11, 8),
			Vector3.new(-22, 11, -4),
			Vector3.new(25, 11, 5),
			Vector3.new(0, 24, 0),
			Vector3.new(-22, 24, 4),
		}
	do
		local fixture = Map.part(
			folder,
			"OldLamp",
			Vector3.new(2, 0.3, 2),
			CFrame.new(pos),
			Color3.fromRGB(255, 210, 134),
			Enum.Material.Neon
		)
		fixture.CanCollide = false
		local light = Instance.new("PointLight")
		light.Color, light.Brightness, light.Range, light.Shadows = fixture.Color, 0.65, 24, true
		light.Parent = fixture
		table.insert(world.Lights, light)
	end
	for _, pos in
		{
			Vector3.new(-27, 1, -16),
			Vector3.new(-27, 1, 17),
			Vector3.new(-27, 14, -16),
			Vector3.new(-27, 14, 17),
		}
	do
		wall("WardrobeBack", Vector3.new(1, 7, 6), pos + Vector3.new(-2.5, 3.5, 0), wood)
		wall("WardrobeSide", Vector3.new(6, 7, 0.5), pos + Vector3.new(0, 3.5, -3), wood)
		wall("WardrobeSide", Vector3.new(6, 7, 0.5), pos + Vector3.new(0, 3.5, 3), wood)
		local marker = Map.part(
			folder,
			"HideSpot",
			Vector3.new(0.5, 0.5, 0.5),
			CFrame.new(pos + Vector3.new(3, 3, 0)),
			wood
		)
		marker.Transparency, marker.CanCollide = 1, false
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText, prompt.ObjectText, prompt.KeyboardKeyCode =
			"Hide / leave", "Quiet wardrobe", Enum.KeyCode.E
		prompt.MaxActivationDistance, prompt.HoldDuration, prompt.Parent = 7, 0.3, marker
		table.insert(
			world.Hides,
			{ Prompt = prompt, Position = pos + Vector3.new(0, 3, 0), Occupant = nil }
		)
	end
	-- Open moving truck faces the house; the orange rectangle is the delivery bay.
	Map.part(
		floors,
		"TruckBed",
		Vector3.new(18, 1, 19),
		CFrame.new(0, 0.5, 52),
		orange,
		Enum.Material.DiamondPlate
	)
	wall(
		"TruckLeft",
		Vector3.new(0.6, 10, 19),
		Vector3.new(-9.3, 5.5, 52),
		Color3.fromRGB(201, 195, 175)
	)
	wall(
		"TruckRight",
		Vector3.new(0.6, 10, 19),
		Vector3.new(9.3, 5.5, 52),
		Color3.fromRGB(201, 195, 175)
	)
	wall("TruckCab", Vector3.new(18, 8, 7), Vector3.new(0, 4.5, 65), orange)
	local zone =
		Map.part(folder, "DeliveryZone", Vector3.new(17, 8, 18), CFrame.new(0, 5, 52), orange)
	zone.Transparency, zone.CanCollide, zone.CanTouch, zone.CanQuery = 1, false, false, false
	world.TruckZone = zone
	sign(
		folder,
		"HUSH & HAUL\nWE MOVE. YOU DON'T ASK.",
		Vector3.new(0, 7, 61.3),
		Vector3.new(16, 4, 0.2),
		orange
	)
	sign(
		folder,
		"DON'T WAKE THE HOUSE\n7 minutes. Furniture first. Crew second?",
		Vector3.new(0, 13, 24.7),
		Vector3.new(13, 3, 0.2),
		wood
	).CFrame *= CFrame.Angles(
		0,
		math.pi,
		0
	)
	sign(
		folder,
		"LOAD HERE\nThen get the whole crew aboard",
		Vector3.new(0, 1.1, 41),
		Vector3.new(12, 0.2, 3),
		orange
	).CanCollide =
		false
	for _, x in { -9.5, 9.5 } do
		for _, z in { 47, 61 } do
			local wheel = Map.part(
				folder,
				"Wheel",
				Vector3.new(2, 4, 4),
				CFrame.new(x, 1.5, z),
				Color3.fromRGB(20, 23, 28)
			)
			wheel.Shape, wheel.CanCollide = Enum.PartType.Cylinder, false
		end
	end
	local spawn = Instance.new("SpawnLocation")
	spawn.Name, spawn.Size, spawn.CFrame =
		"CrewSpawn", Vector3.new(8, 1, 8), CFrame.new(15, 0.5, 51)
	spawn.Anchored, spawn.Neutral, spawn.Duration, spawn.Transparency = true, true, 0, 1
	spawn.Parent = folder
	Lighting.ClockTime, Lighting.Brightness = 0.3, 1.2
	Lighting.Ambient, Lighting.OutdoorAmbient =
		Color3.fromRGB(44, 51, 74), Color3.fromRGB(70, 83, 119)
	Lighting.FogColor, Lighting.FogStart, Lighting.FogEnd = Color3.fromRGB(32, 44, 65), 100, 220
	return world
end

function Map.furniture(world: any): { any }
	world.Props:ClearAllChildren()
	local cargo = world.Folder:FindFirstChild("LoadedCargo")
	if cargo then
		cargo:Destroy()
	end
	cargo = Instance.new("Folder")
	cargo.Name, cargo.Parent = "LoadedCargo", world.Folder
	local specs: { { string | boolean | Vector3 } } = {
		{ "Unpaid Lamp", false, Vector3.new(3, 4, 3), Vector3.new(-19, 1, 7), "Lamp" },
		{ "Box of Regrets", false, Vector3.new(3, 3, 3), Vector3.new(6, 1, 15), "Box" },
		{ "Judgmental Chair", false, Vector3.new(3, 4, 3), Vector3.new(-18, 1, -14), "Chair" },
		{ "Tax Documents", false, Vector3.new(3, 3, 3), Vector3.new(8, 1, -10), "Box" },
		{ "Sofa So Good", true, Vector3.new(8, 4, 4), Vector3.new(-22, 1, 0), "Sofa" },
		{ "Family Dining Table", true, Vector3.new(7, 4, 5), Vector3.new(4, 1, 0), "Table" },
		{ "Emotional Baggage", false, Vector3.new(3, 3, 3), Vector3.new(-20, 14, 5), "Box" },
		{ "Nightstand", false, Vector3.new(3, 3, 3), Vector3.new(8, 14, -16), "Table" },
		{
			"Suspicious Reading Lamp",
			false,
			Vector3.new(3, 4, 3),
			Vector3.new(-18, 14, -10),
			"Lamp",
		},
		{ "Grandma's Chair", false, Vector3.new(3, 4, 3), Vector3.new(8, 14, 16), "Chair" },
		{ "Dream Couch", true, Vector3.new(8, 4, 4), Vector3.new(-22, 14, 10), "Sofa" },
		{ "Desk of Unfinished Work", true, Vector3.new(7, 4, 4), Vector3.new(4, 14, 4), "Table" },
	}
	local items = {}
	for id, spec in specs do
		local name, large, size, pos, kind =
			spec[1] :: string,
			spec[2] :: boolean,
			spec[3] :: Vector3,
			spec[4] :: Vector3,
			spec[5] :: string
		local model = Instance.new("Model")
		model.Name, model.Parent = name, world.Props
		local center = pos + Vector3.new(0, size.Y / 2, 0)
		local root = Map.part(model, "CarryBounds", size, CFrame.new(center), orange)
		root.Transparency, root.CanCollide = 1, false
		model.PrimaryPart = root
		local function detail(n: string, s: Vector3, offset: Vector3, c: Color3)
			local p = Map.part(model, n, s, CFrame.new(pos + offset), c, Enum.Material.Wood)
			p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
		end
		if kind == "Box" then
			detail("Cardboard", size, Vector3.new(0, 1.5, 0), Color3.fromRGB(164, 123, 79))
			detail("Tape", Vector3.new(0.5, 3.05, 3.05), Vector3.new(0, 1.5, 0), orange)
		elseif kind == "Lamp" then
			detail("Base", Vector3.new(2, 0.3, 2), Vector3.new(0, 0.2, 0), wood)
			detail("Stem", Vector3.new(0.3, 2.5, 0.3), Vector3.new(0, 1.5, 0), orange)
			detail(
				"Shade",
				Vector3.new(2.7, 1.2, 2.7),
				Vector3.new(0, 3.3, 0),
				Color3.fromRGB(210, 193, 151)
			)
		else
			local cushion = if kind == "Sofa" then Color3.fromRGB(84, 120, 112) else wood
			detail("SeatOrTop", Vector3.new(size.X, 0.7, size.Z), Vector3.new(0, 2.4, 0), cushion)
			if kind ~= "Table" then
				detail(
					"Back",
					Vector3.new(size.X, 2, 0.6),
					Vector3.new(0, 3, size.Z / 2 - 0.3),
					cushion
				)
			end
			for _, x in { -1, 1 } do
				for _, z in { -1, 1 } do
					detail(
						"Leg",
						Vector3.new(0.4, 2.3, 0.4),
						Vector3.new(x * (size.X / 2 - 0.4), 1.15, z * (size.Z / 2 - 0.4)),
						wood
					)
				end
			end
		end
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = if large then "Carry / join (2 crew; solo drag)" else "Carry"
		prompt.ObjectText, prompt.KeyboardKeyCode = name, Enum.KeyCode.E
		prompt.MaxActivationDistance, prompt.RequiresLineOfSight, prompt.Parent = 9, true, root
		model:SetAttribute("ItemId", id)
		model:SetAttribute("Large", large)
		table.insert(items, {
			Id = id,
			Name = name,
			Large = large,
			Size = size,
			Model = model,
			Root = root,
			Prompt = prompt,
			Carriers = {},
			Delivered = false,
			Angle = 0,
			BumpAt = 0,
			Spawn = root.CFrame,
		})
	end
	return items
end

function Map.loadedCargo(world: any, index: number)
	local crate = Map.part(
		world.Folder.LoadedCargo,
		"PackedDelivery",
		Vector3.new(2.3, 2, 2.3),
		CFrame.new(-5 + ((index - 1) % 4) * 3.3, 2 + math.floor((index - 1) / 4) * 2, 58),
		orange,
		Enum.Material.WoodPlanks
	)
	crate.CanCollide, crate.CanQuery = false, false
end

function Map.inTruck(world: any, pos: Vector3, margin: number?): boolean
	local localPos = world.TruckZone.CFrame:PointToObjectSpace(pos)
	local m = margin or 0
	return math.abs(localPos.X) <= 8.5 - m
		and math.abs(localPos.Z) <= 9 - m
		and math.abs(localPos.Y) < 7
end
return Map
