--!strict
-- Original procedural art. Visual geometry never participates in carry/LOS queries.
local Environment = {}
local C = {
	Wood = Color3.fromRGB(66, 48, 42),
	Ivory = Color3.fromRGB(177, 164, 133),
	Teal = Color3.fromRGB(61, 88, 85),
	Brass = Color3.fromRGB(137, 108, 57),
	Rust = Color3.fromRGB(101, 56, 40),
	Blue = Color3.fromRGB(91, 127, 163),
	Black = Color3.fromRGB(25, 29, 32),
	Orange = Color3.fromRGB(225, 139, 54),
}
Environment.Colors = C
function Environment.part(
	parent: Instance,
	name: string,
	size: Vector3,
	cf: CFrame,
	color: Color3,
	material: Enum.Material?
): Part
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame, p.Color = name, size, cf, color
	p.Material = material or Enum.Material.Wood
	p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery, p.CastShadow =
		true, false, false, false, false
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
function Environment.text(p: BasePart, message: string, face: Enum.NormalId?)
	local g = Instance.new("SurfaceGui")
	g.Face, g.SizingMode, g.PixelsPerStud =
		face or Enum.NormalId.Front, Enum.SurfaceGuiSizingMode.PixelsPerStud, 35
	g.Parent = p
	local t = Instance.new("TextLabel")
	t.Size, t.BackgroundTransparency, t.TextWrapped, t.TextScaled =
		UDim2.fromScale(1, 1), 1, true, true
	t.Text, t.TextColor3, t.Font, t.Parent = message, C.Ivory, Enum.Font.Garamond, g
end
function Environment.model(parent: Instance, name: string): Model
	local m = Instance.new("Model")
	m.Name, m.Parent = name, parent
	m:SetAttribute("OriginalArt", true)
	return m
end
local function cylinder(
	parent: Instance,
	name: string,
	size: Vector3,
	cf: CFrame,
	color: Color3
): Part
	local p = Environment.part(parent, name, size, cf, color, Enum.Material.Metal)
	p.Shape = Enum.PartType.Cylinder
	return p
end
function Environment.portrait(parent: Instance, cf: CFrame, caption: string)
	local m = Environment.model(parent, "ValeFamilyPortrait")
	Environment.part(m, "Frame", Vector3.new(3.3, 4.1, 0.25), cf, C.Brass)
	Environment.part(
		m,
		"FadedPaper",
		Vector3.new(2.9, 3.7, 0.12),
		cf * CFrame.new(0, 0, -0.18),
		C.Ivory
	)
	for i = -1, 1 do
		local head = Environment.part(
			m,
			"Silhouette",
			Vector3.new(0.6, 0.7, 0.1),
			cf * CFrame.new(i * 0.8, 0.65, -0.27),
			C.Wood
		)
		head.Shape = Enum.PartType.Ball
		Environment.part(
			m,
			"SundayCoat",
			Vector3.new(0.65, 1.2, 0.1),
			cf * CFrame.new(i * 0.8, -0.25, -0.27),
			C.Teal
		)
	end
	local plate = Environment.part(
		m,
		"Inscription",
		Vector3.new(2.8, 0.65, 0.1),
		cf * CFrame.new(0, -1.5, -0.3),
		C.Wood
	)
	Environment.text(plate, caption)
end
function Environment.build(world: any)
	local folder = Instance.new("Folder")
	folder.Name, folder.Parent = "EnvironmentArt", world.Folder
	world.Art = folder
	local function part(n: string, s: Vector3, p: Vector3, c: Color3, mat: Enum.Material?): Part
		return Environment.part(folder, n, s, CFrame.new(p), c, mat)
	end
	local function solid(n: string, s: Vector3, p: Vector3, c: Color3, floor: boolean?): Part
		local a = Environment.part(
			if floor then world.Floors else world.Blockers,
			n,
			s,
			CFrame.new(p),
			c,
			Enum.Material.WoodPlanks
		)
		a.CanCollide, a.CanQuery, a.CastShadow = true, true, true
		return a
	end
	local function plaque(message: string, p: Vector3, w: number, angle: number?)
		local a = part("Wayfinding", Vector3.new(w, 1.6, 0.12), p, C.Wood)
		a.CFrame *= CFrame.Angles(0, angle or 0, 0)
		Environment.text(a, message)
	end
	-- Retain the proven core footprint and upstairs carry routes. Add a rear service
	-- wing over a real sunken basement; split the yard so it cannot cap the stairs.
	world.Floors.Yard:Destroy()
	for _, r in
		{
			{ Vector3.new(180, 2, 77), Vector3.new(0, -1, 63.5) },
			{ Vector3.new(180, 2, 17), Vector3.new(0, -1, -69.5) },
			{ Vector3.new(57, 2, 86), Vector3.new(-61.5, -1, -18) },
			{ Vector3.new(57, 2, 86), Vector3.new(61.5, -1, -18) },
		}
	do
		local a = solid("GardenGround", r[1], r[2], Color3.fromRGB(37, 48, 40), true)
		a.Material = Enum.Material.Grass
	end
	world.Blockers.Back:Destroy()
	solid("RearWallLeft", Vector3.new(25, 12, 1), Vector3.new(-19.5, 7, -24), C.Teal)
	solid("RearWallRight", Vector3.new(25, 12, 1), Vector3.new(19.5, 7, -24), C.Teal)
	solid("RearLintel", Vector3.new(14, 3, 1), Vector3.new(0, 11.5, -24), C.Wood)
	solid("UpperBack", Vector3.new(64, 13, 1), Vector3.new(0, 20.5, -24), C.Teal)
	solid("KitchenFloor", Vector3.new(52, 1, 36), Vector3.new(-6, 0.5, -42), C.Ivory, true)
	solid("BasementFloor", Vector3.new(64, 1, 36), Vector3.new(0, -11.5, -42), C.Black, true)
	solid("KitchenRoof", Vector3.new(65, 1, 37), Vector3.new(0, 13.5, -42), C.Black)
	for _, x in { -32, 32 } do
		solid("ServiceWingSide", Vector3.new(1, 24, 36), Vector3.new(x, 1, -42), C.Teal)
	end
	solid("FoundationFront", Vector3.new(64, 12, 1), Vector3.new(0, -5, -24), C.Black)
	solid("FoundationBack", Vector3.new(64, 12, 1), Vector3.new(0, -5, -60), C.Black)
	for _, x in { -19.5, 19.5 } do
		solid("RearExitWall", Vector3.new(25, 12, 1), Vector3.new(x, 7, -60), C.Teal)
	end
	solid("RearExitLintel", Vector3.new(14, 3, 1), Vector3.new(0, 11.5, -60), C.Wood)
	-- The first step starts level with the kitchen. 12-stud shaft, 0.75-stud rises.
	for i = 1, 16 do
		local top = 1 - i * 0.75
		solid(
			"CellarStep" .. i,
			Vector3.new(11, top + 12, 2),
			Vector3.new(26, (top - 12) / 2, -25 - i * 2),
			C.Wood,
			true
		)
	end
	solid(
		"CellarBottomLanding",
		Vector3.new(12, 1, 3),
		Vector3.new(26, -11.5, -58.5),
		C.Black,
		true
	)
	solid("CellarGuard", Vector3.new(0.5, 3, 27), Vector3.new(20, 2.5, -44), C.Wood)
	-- Upstairs rooms have twelve-stud openings onto the existing landing.
	for _, z in { -5, 12 } do
		solid("BedroomPartition", Vector3.new(2, 12, 0.5), Vector3.new(19, 20, z), C.Teal)
		solid("BedroomPartition", Vector3.new(4, 12, 0.5), Vector3.new(-8, 20, z), C.Teal)
		solid("BedroomLintel", Vector3.new(18, 3, 0.5), Vector3.new(3, 24.5, z), C.Wood)
	end
	-- Sealed memory alcove is visible from the landing and has a readable clue.
	for _, x in { -6, 6 } do
		solid("SealedRoomSide", Vector3.new(0.4, 12, 11), Vector3.new(x, 20, -18.5), C.Teal)
	end
	solid("SealedRoomLintel", Vector3.new(12, 4, 0.4), Vector3.new(0, 24, -13), C.Wood)
	for _, x in { -5.3, 5.3 } do
		solid("SealedRoomJamb", Vector3.new(1.4, 8, 0.4), Vector3.new(x, 18, -13), C.Wood)
	end
	local seal = solid("FarewellSeal", Vector3.new(9.2, 8, 0.3), Vector3.new(0, 18, -13), C.Wood)
	Environment.text(
		seal,
		"THE ROOM WE KEPT\nDo not open until everyone is home.\nMara + Elias + June",
		Enum.NormalId.Back
	)
	world.MemorySeal = seal
	for _, x in { -6, 6 } do
		part("MemorySlats", Vector3.new(0.2, 8, 0.3), Vector3.new(x, 18, -13), C.Wood)
	end
	plaque("THE ROOM WE KEPT\nMara, Elias & June Vale · 1987", Vector3.new(0, 19, -23.3), 9)
	Environment.portrait(folder, CFrame.new(0, 18, -22.9), "WE MEANT TO LEAVE TOGETHER")
	-- Facade: distinct roof silhouette, posts, cornices, masonry and damaged siding.
	world.Blockers.FrontLeft:Destroy()
	world.Blockers.FrontRight:Destroy()
	for _, side in { -1, 1 } do
		solid("FacadeOuterPier", Vector3.new(7, 26, 1), Vector3.new(side * 28.5, 14, 24), C.Teal)
		solid("FacadeInnerPier", Vector3.new(10, 26, 1), Vector3.new(side * 12, 14, 24), C.Teal)
		for _, band in { Vector2.new(2.5, 3), Vector2.new(13.5, 7), Vector2.new(25, 4) } do
			solid(
				"WindowSpandrel",
				Vector3.new(8, band.Y, 1),
				Vector3.new(side * 21, band.X, 24),
				C.Teal
			)
		end
		for _, y in { 7, 20 } do
			local glass = solid(
				"WindowCollision",
				Vector3.new(8, 6, 0.2),
				Vector3.new(side * 21, y, 24),
				C.Blue
			)
			glass.Transparency = 1
		end
	end
	for _, side in { -1, 1 } do
		local roof = part(
			"SlateRoofPitch",
			Vector3.new(36, 0.7, 55),
			Vector3.new(side * 16, 32.3, 0),
			C.Black,
			Enum.Material.Slate
		)
		roof.CFrame *= CFrame.Angles(0, 0, -side * math.rad(17))
		for z = -24, 24, 4 do
			local seam = part(
				"RoofSeam",
				Vector3.new(36, 0.08, 0.12),
				Vector3.new(side * 16, 32.72, z),
				C.Blue,
				Enum.Material.Metal
			)
			seam.CFrame *= CFrame.Angles(0, 0, -side * math.rad(17))
		end
	end
	part("Chimney", Vector3.new(4, 15, 5), Vector3.new(-25, 31, -15), C.Rust, Enum.Material.Brick)
	for _, y in { 13, 26 } do
		part("FrontCornice", Vector3.new(65, 0.4, 0.7), Vector3.new(0, y, 24.55), C.Ivory)
	end
	solid("PorchDeck", Vector3.new(34, 0.6, 10), Vector3.new(0, 0.3, 29), C.Wood, true)
	for _, x in { -15, 15 } do
		part("PorchPost", Vector3.new(0.8, 10, 0.8), Vector3.new(x, 5, 32), C.Ivory)
		part("PostFoot", Vector3.new(1.3, 0.5, 1.3), Vector3.new(x, 0.8, 32), C.Wood)
	end
	part("PorchCanopy", Vector3.new(35, 0.6, 11), Vector3.new(0, 10.5, 29.5), C.Wood)
	for _, pane in world.Folder:GetChildren() do
		if pane:IsA("BasePart") and pane.Name == "MoonlitWindow" then
			pane.Position = Vector3.new(pane.Position.X, pane.Position.Y, 24.15)
			pane.Material, pane.Transparency, pane.CanQuery = Enum.Material.Glass, 0.25, false
			for _, x in { -3.7, 0, 3.7 } do
				Environment.part(
					folder,
					"WindowMullion",
					Vector3.new(0.18, 6.6, 0.3),
					pane.CFrame * CFrame.new(x, 0, -0.2),
					C.Ivory
				)
			end
			for _, y in { -3.3, 0, 3.3 } do
				Environment.part(
					folder,
					"WindowRail",
					Vector3.new(7.6, 0.18, 0.3),
					pane.CFrame * CFrame.new(0, y, -0.2),
					C.Ivory
				)
			end
			for _, x in { -2.8, 2.8 } do
				local curtain = Environment.part(
					folder,
					"TornCurtain",
					Vector3.new(1.5, 6.2, 0.16),
					pane.CFrame * CFrame.new(x, -0.2, -0.5),
					C.Teal,
					Enum.Material.Fabric
				)
				curtain:SetAttribute("Sway", true)
			end
			local light = Instance.new("PointLight")
			light.Color, light.Brightness, light.Range, light.Shadows, light.Parent =
				C.Blue, 0.35, 17, false, pane
		end
	end
	-- Repeated trim and wallpaper motifs use geometry, no uploaded textures.
	for _, y in { 1, 14 } do
		for z = -20, 20, 5 do
			for _, x in { -31.4, 31.4 } do
				part("WainscotPanel", Vector3.new(0.12, 3, 4.6), Vector3.new(x, y + 1.5, z), C.Wood)
				local flower = part(
					"WallpaperDiamond",
					Vector3.new(0.05, 0.5, 0.5),
					Vector3.new(x, y + 7, z),
					C.Brass
				)
				flower.CFrame *= CFrame.Angles(math.rad(45), 0, 0)
			end
		end
		for _, x in { -31.3, 31.3 } do
			part("DadoRail", Vector3.new(0.25, 0.18, 47), Vector3.new(x, y + 3, 0), C.Ivory)
		end
		for i = 1, 5 do
			part(
				"WaterDamage",
				Vector3.new(0.05, 1 + i * 0.5, 0.7),
				Vector3.new(-31.25, y + 9 - i * 0.25, -23 + i),
				C.Rust
			)
		end
	end
	-- Entry landmarks sit outside the measured 12-stud center lane.
	local clock = Environment.model(folder, "StoppedAtSixSeventeen")
	Environment.part(clock, "Case", Vector3.new(2.4, 8, 1.3), CFrame.new(17, 5, 21.8), C.Wood)
	local dial = Environment.part(
		clock,
		"ClockFace",
		Vector3.new(1.9, 1.9, 0.12),
		CFrame.new(17, 7, 21),
		C.Ivory
	)
	Environment.text(dial, "XII\n6:17\nVI")
	cylinder(
		clock,
		"Pendulum",
		Vector3.new(0.12, 0.9, 0.9),
		CFrame.new(17, 3.3, 21) * CFrame.Angles(0, math.pi / 2, 0),
		C.Brass
	)
	part("CoatStand", Vector3.new(0.3, 6, 0.3), Vector3.new(17, 4, 15), C.Wood)
	for i = -1, 1 do
		local hook = part(
			"CoatHook",
			Vector3.new(1.4, 0.15, 0.15),
			Vector3.new(17, 5.3 + i * 0.35, 15),
			C.Brass
		)
		hook.CFrame *= CFrame.Angles(0, i, 0)
	end
	Environment.portrait(
		folder,
		CFrame.new(10, 7, 23.2) * CFrame.Angles(0, math.pi, 0),
		"THE VALES · SUMMER 1987"
	)
	-- Living room: cold fireplace, ash and a silent television.
	for _, x in { -26, -18 } do
		part(
			"HearthPillar",
			Vector3.new(1, 7, 2),
			Vector3.new(x, 4, -22),
			C.Rust,
			Enum.Material.Brick
		)
	end
	part("Mantel", Vector3.new(10, 0.6, 2.7), Vector3.new(-22, 7.6, -22), C.Wood)
	part("ColdFirebox", Vector3.new(7, 5, 0.2), Vector3.new(-22, 3.5, -23.2), C.Black)
	part(
		"Ash",
		Vector3.new(7, 0.07, 3),
		Vector3.new(-22, 1.05, -21.5),
		Color3.fromRGB(76, 74, 68),
		Enum.Material.Slate
	)
	local tv = part("TelevisionCabinet", Vector3.new(4, 3, 2), Vector3.new(-30, 3, 7), C.Wood)
	local screen = Environment.part(
		folder,
		"InterferenceScreen",
		Vector3.new(0.12, 2.3, 3.2),
		tv.CFrame * CFrame.new(2.05, 0, 0),
		C.Blue,
		Enum.Material.Glass
	)
	screen:SetAttribute("Interference", true)
	-- Kitchen runs along the back and west walls, leaving a broad rear-exit loop.
	for x = -27, -9, 6 do
		part("KitchenCabinet", Vector3.new(5.7, 3.5, 3), Vector3.new(x, 2.75, -57.5), C.Teal)
		part(
			"WornCounter",
			Vector3.new(5.9, 0.25, 3.3),
			Vector3.new(x, 4.6, -57.5),
			C.Ivory,
			Enum.Material.Marble
		)
		part("CabinetHandle", Vector3.new(1.2, 0.13, 0.2), Vector3.new(x, 3.5, -55.9), C.Brass)
	end
	part(
		"SinkBasin",
		Vector3.new(3, 0.2, 2),
		Vector3.new(-21, 4.78, -57.4),
		C.Black,
		Enum.Material.Metal
	)
	cylinder(
		folder,
		"Tap",
		Vector3.new(0.2, 1.1, 0.2),
		CFrame.new(-21, 5.2, -58.4) * CFrame.Angles(0, 0, math.pi / 2),
		C.Brass
	)
	part("Icebox", Vector3.new(4, 7, 3), Vector3.new(-29, 4.5, -47), C.Ivory, Enum.Material.Metal)
	part("IceboxHandle", Vector3.new(0.2, 1.8, 0.3), Vector3.new(-27.3, 5, -45.3), C.Brass)
	for x = -29, 17, 4 do
		for z = -58, -28, 4 do
			part(
				"StainedTile",
				Vector3.new(3.85, 0.03, 3.85),
				Vector3.new(x, 1.02, z),
				if (x + z) % 8 == 1 then C.Teal else C.Ivory,
				Enum.Material.CeramicTiles
			)
		end
	end
	part(
		"Radiator",
		Vector3.new(0.6, 3, 7),
		Vector3.new(31, 2.5, -38),
		C.Brass,
		Enum.Material.Metal
	)
	for z = -41, -35 do
		part(
			"RadiatorFin",
			Vector3.new(1, 3.2, 0.18),
			Vector3.new(30.8, 2.6, z),
			C.Black,
			Enum.Material.Metal
		)
	end
	-- Basement workshop, plumbing, boiler and numbered storage remain off the lane.
	part("Workbench", Vector3.new(12, 0.5, 3), Vector3.new(-22, -7.7, -57), C.Wood)
	for _, x in { -27, -17 } do
		part("BenchLeg", Vector3.new(0.5, 3, 2), Vector3.new(x, -9.3, -57), C.Brass)
	end
	for i = 1, 3 do
		part("StorageShelf", Vector3.new(3, 0.25, 18), Vector3.new(-29, -10 + i * 2, -38), C.Wood)
		for z = -44, -30, 7 do
			local box = part(
				"ArchiveBox",
				Vector3.new(2, 1.5, 2),
				Vector3.new(-29, -9.1 + i * 2, z),
				C.Ivory
			)
			Environment.text(box, "VALE\n1987 / " .. i)
		end
	end
	cylinder(
		folder,
		"Boiler",
		Vector3.new(6, 4, 4),
		CFrame.new(14, -8, -55) * CFrame.Angles(0, 0, math.pi / 2),
		C.Rust
	)
	for _, y in { -8, -5 } do
		cylinder(
			folder,
			"UtilityPipe",
			Vector3.new(27, 0.22, 0.22),
			CFrame.new(0, y, -59.2),
			C.Brass
		)
	end
	plaque("CELLAR · THE WATER WAS TURNED OFF IN 1987", Vector3.new(0, -5, -59.3), 13)
	-- Beds, handmade toys and a shared family history; no copyrighted photos.
	for _, origin in { Vector3.new(-18, 14, -18), Vector3.new(15, 14, 5) } do
		part("BedFrame", Vector3.new(5, 0.6, 7), origin + Vector3.new(0, 1, 0), C.Wood)
		part(
			"Mattress",
			Vector3.new(4.7, 0.7, 6.5),
			origin + Vector3.new(0, 1.6, 0),
			C.Ivory,
			Enum.Material.Fabric
		)
		part(
			"PatchworkQuilt",
			Vector3.new(4.75, 0.15, 4.7),
			origin + Vector3.new(0, 2.05, 0.8),
			C.Teal,
			Enum.Material.Fabric
		)
		part(
			"Pillow",
			Vector3.new(3, 0.5, 1.4),
			origin + Vector3.new(0, 2.1, -2.3),
			C.Ivory,
			Enum.Material.Fabric
		)
		part("Headboard", Vector3.new(5.3, 3, 0.4), origin + Vector3.new(0, 2, -3.6), C.Wood)
	end
	for i = 1, 4 do
		local toy = part(
			"JuneWoodenHouse",
			Vector3.new(0.8, 0.7 + i * 0.1, 0.8),
			Vector3.new(17, 14.5, 14 + i),
			C.Brass
		)
		toy:SetAttribute("MemoryToy", true)
	end
	local drawing =
		part("JuneDrawing", Vector3.new(3, 2.5, 0.05), Vector3.new(16, 19, 23.35), C.Ivory)
	drawing.CFrame *= CFrame.Angles(0, math.pi, 0)
	Environment.text(drawing, "OUR NEXT HOUSE\nMama + Papa + June\nPlease bring the chair")
	local signs: { { string | Vector3 | number } } = {
		{ "ENTRY / TRUCK", Vector3.new(0, 8, 23.3), math.pi },
		{ "LIVING ROOM", Vector3.new(-10.6, 9, -2), math.pi / 2 },
		{ "DINING / KITCHEN", Vector3.new(0, 9, -23.3), 0 },
		{ "JUNE'S ROOM", Vector3.new(3, 23, 12.4), math.pi },
		{ "MARA & ELIAS", Vector3.new(3, 23, -4.6), math.pi },
		{ "GARDEN / LONG WAY TO TRUCK", Vector3.new(0, 9, -59.3), 0 },
	}
	for _, data in signs do
		plaque(data[1] :: string, data[2] :: Vector3, 10, data[3] :: number)
	end
	-- Exterior route is 14 studs wide along the west side, with no snagging clutter.
	for _, rect in
		{
			{ Vector3.new(14, 0.05, 104), Vector3.new(-43, 0.03, -12) },
			{ Vector3.new(56, 0.05, 10), Vector3.new(-18, 0.03, -67) },
			{ Vector3.new(56, 0.05, 10), Vector3.new(-18, 0.03, 36) },
		}
	do
		part("GravelRoute", rect[1], rect[2], Color3.fromRGB(76, 76, 66), Enum.Material.Pebble)
	end
	for x = -68, 68, 5 do
		for _, z in { -75, 82 } do
			local picket =
				part("CrookedFence", Vector3.new(1, 4, 0.3), Vector3.new(x, 2, z), C.Wood)
			picket.CFrame *= CFrame.Angles(0, 0, math.rad((x % 7) - 3))
		end
	end
	for i = 1, 30 do
		local x = -65 + (i % 3) * 5
		local shrub = part(
			"OvergrownGarden",
			Vector3.new(3, 2 + (i % 3), 3),
			Vector3.new(x, 1, -66 + i * 4),
			C.Teal,
			Enum.Material.Grass
		)
		shrub.Shape = Enum.PartType.Ball
	end
	local post =
		part("LeaningMailboxPost", Vector3.new(0.4, 4, 0.4), Vector3.new(30, 2, 72), C.Wood)
	post.CFrame *= CFrame.Angles(0, 0, 0.12)
	local mail = part(
		"Mailbox",
		Vector3.new(2, 1.5, 3),
		Vector3.new(30.3, 4, 72),
		C.Rust,
		Enum.Material.Metal
	)
	Environment.text(mail, "17\nVALE")
	for _, x in { -60, -50 } do
		part("ShedSide", Vector3.new(0.5, 8, 12), Vector3.new(x, 4, -58), C.Wood)
	end
	part("ShedBack", Vector3.new(10, 8, 0.5), Vector3.new(-55, 4, -64), C.Teal)
	part(
		"ShedRoof",
		Vector3.new(12, 0.4, 14),
		Vector3.new(-55, 8, -58),
		C.Black,
		Enum.Material.CorrodedMetal
	)
	part(
		"StreetlightPole",
		Vector3.new(0.5, 17, 0.5),
		Vector3.new(30, 8.5, 64),
		C.Black,
		Enum.Material.Metal
	)
	-- Truck cab, lights and equipment establish the warm safe-area silhouette.
	for _, x in { -9.65, 9.65 } do
		part(
			"CabWindow",
			Vector3.new(0.1, 3, 4),
			Vector3.new(x, 6, 65),
			C.Blue,
			Enum.Material.Glass
		)
		part("CargoStripe", Vector3.new(0.1, 0.65, 18), Vector3.new(x, 6, 52), C.Orange)
		for _, z in { 47, 61 } do
			cylinder(
				folder,
				"WheelHub",
				Vector3.new(0.15, 2.1, 2.1),
				CFrame.new(x * 1.11, 1.5, z),
				C.Brass
			)
		end
	end
	part(
		"TruckWindshield",
		Vector3.new(15, 3, 0.15),
		Vector3.new(0, 6, 68.6),
		C.Blue,
		Enum.Material.Glass
	)
	part(
		"FrontBumper",
		Vector3.new(19, 0.7, 1),
		Vector3.new(0, 1.8, 69),
		C.Black,
		Enum.Material.Metal
	)
	for _, x in { -7, 7 } do
		local a = part(
			"TruckWorklight",
			Vector3.new(1.5, 0.7, 0.4),
			Vector3.new(x, 9.5, 42.2),
			C.Ivory,
			Enum.Material.Neon
		)
		local l = Instance.new("PointLight")
		l.Color, l.Brightness, l.Range, l.Shadows, l.Parent =
			Color3.fromRGB(255, 201, 128), 1.4, 28, false, a
	end
	local desk = part("DispatchDesk", Vector3.new(5, 0.4, 3), Vector3.new(23, 3, 53), C.Wood)
	for _, x in { 21, 25 } do
		part("DeskLeg", Vector3.new(0.4, 3, 2.5), Vector3.new(x, 1.5, 53), C.Brass)
	end
	local manifest = part(
		"DispatchManifest",
		Vector3.new(3, 0.06, 2),
		desk.Position + Vector3.new(0, 0.25, 0),
		C.Ivory
	)
	Environment.text(manifest, "HUSH & HAUL\nNO GHOSTS ON PAYROLL", Enum.NormalId.Top)
	for i = 1, 3 do
		local pack =
			part("SupplyDisplay", Vector3.new(1.2, 0.7, 1), Vector3.new(21 + i, 3.6, 53), C.Orange)
		Environment.text(pack, ({ "SOLES", "PADDING", "CREW" })[i])
	end
	part("DollyBack", Vector3.new(2.4, 4, 0.2), Vector3.new(24, 2, 48), C.Teal, Enum.Material.Metal)
	part(
		"DollyToe",
		Vector3.new(2.4, 0.2, 1.7),
		Vector3.new(24, 0.2, 47.3),
		C.Teal,
		Enum.Material.Metal
	)
	for _, x in { 22.8, 25.2 } do
		cylinder(folder, "DollyWheel", Vector3.new(0.4, 0.9, 0.9), CFrame.new(x, 0.5, 48), C.Black)
	end
	-- Low-cost point lights; only existing five ceiling lights cast shadows.
	for _, p in
		{
			Vector3.new(-18, 10, -43),
			Vector3.new(8, 10, -45),
			Vector3.new(-10, -3, -40),
			Vector3.new(26, -3, -56),
		}
	do
		local a = part("ServiceLamp", Vector3.new(1.5, 0.2, 1.5), p, C.Ivory, Enum.Material.Neon)
		local l = Instance.new("PointLight")
		l.Color, l.Brightness, l.Range, l.Shadows, l.Parent = C.Ivory, 0.65, 24, false, a
		table.insert(world.Lights, l)
	end
	for _, p in { Vector3.new(-29, 7, -38), Vector3.new(16, 20, 22), Vector3.new(-29, 7, 15) } do
		part("SwitchPlate", Vector3.new(0.12, 0.8, 0.5), p, C.Ivory, Enum.Material.SmoothPlastic)
		part("Outlet", Vector3.new(0.12, 0.7, 0.5), p - Vector3.new(0, 4, 0), C.Brass)
	end
	world.AmbientSources = {
		{
			Position = Vector3.new(-21, 5, -57),
			Text = "A dry tap drips. The water has been off for years.",
			Kind = "Creak",
		},
		{
			Position = Vector3.new(14, -7, -55),
			Text = "Three knocks travel through the cellar pipes.",
			Kind = "Knock",
		},
		{
			Position = Vector3.new(17, 7, 21),
			Text = "The hall clock ticks once. It still says 6:17.",
			Kind = "Creak",
		},
	}
	-- Dressing stays outside the audited lanes and never changes their collision.
	for _, fixture in world.Folder:GetChildren() do
		if fixture:IsA("BasePart") and fixture.Name == "OldLamp" then
			Environment.part(
				folder,
				"LampCeilingRose",
				Vector3.new(2.7, 0.18, 2.7),
				fixture.CFrame * CFrame.new(0, 0.3, 0),
				C.Brass,
				Enum.Material.Metal
			)
			local dust = Instance.new("ParticleEmitter")
			dust.Name, dust.Texture = "QuietDust", "rbxasset://textures/particles/sparkles_main.dds"
			dust.Rate, dust.Lifetime, dust.Speed =
				1, NumberRange.new(3, 5), NumberRange.new(0.1, 0.3)
			dust.Size, dust.Transparency = NumberSequence.new(0.035), NumberSequence.new(0.88)
			dust.LightEmission, dust.SpreadAngle, dust.Parent = 0.1, Vector2.new(45, 45), fixture
		end
	end
	for i = 1, 5 do
		local book = part(
			"FadedBook",
			Vector3.new(0.3, 1.1, 0.8),
			Vector3.new(-24 + i * 0.4, 8.5, -22),
			if i % 2 == 0 then C.Teal else C.Rust
		)
		book.CFrame *= CFrame.Angles(0, 0, 0.04 * i)
	end
	for _, x in { -5, 12 } do
		part("DiningChairSeat", Vector3.new(2.2, 0.25, 2.2), Vector3.new(x, 2.2, -18), C.Wood)
		part("DiningChairBack", Vector3.new(2.2, 2.4, 0.25), Vector3.new(x, 3.2, -19), C.Teal)
		for _, dx in { -0.9, 0.9 } do
			for _, dz in { -0.9, 0.9 } do
				part(
					"DiningChairLeg",
					Vector3.new(0.2, 1.1, 0.2),
					Vector3.new(x + dx, 1.55, -18 + dz),
					C.Wood
				)
			end
		end
	end
	part("DiningHutch", Vector3.new(5, 7, 2), Vector3.new(15, 4.5, -22), C.Wood)
	for _, y in { 3, 5, 7 } do
		part("HutchShelf", Vector3.new(4.7, 0.15, 0.3), Vector3.new(15, y, -20.8), C.Brass)
	end
	local lamp = part(
		"StreetlightHead",
		Vector3.new(2, 0.4, 2),
		Vector3.new(30, 17, 64),
		C.Ivory,
		Enum.Material.Neon
	)
	local light = Instance.new("PointLight")
	light.Brightness, light.Range, light.Color, light.Shadows, light.Parent =
		0.35, 20, C.Blue, false, lamp
end
return Environment
