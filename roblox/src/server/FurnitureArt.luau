--!strict
local Art = require(script.Parent.Environment)
local C = Art.Colors
local FurnitureArt = {}
function FurnitureArt.build(model: Model, id: number, size: Vector3, pos: Vector3)
	local function p(n: string, s: Vector3, o: Vector3, c: Color3, mat: Enum.Material?): Part
		return Art.part(model, n, s, CFrame.new(pos + o), c, mat)
	end
	local function legs(height: number)
		for _, x in { -1, 1 } do
			for _, z in { -1, 1 } do
				local leg = p(
					"TurnedLeg",
					Vector3.new(0.3, height, 0.3),
					Vector3.new(x * (size.X / 2 - 0.4), height / 2, z * (size.Z / 2 - 0.4)),
					C.Wood
				)
				leg.CFrame *= CFrame.Angles(z * 0.06, 0, -x * 0.06)
				p(
					"BrassFoot",
					Vector3.new(0.34, 0.2, 0.34),
					Vector3.new(x * (size.X / 2 - 0.4), 0.15, z * (size.Z / 2 - 0.4)),
					C.Brass,
					Enum.Material.Metal
				)
			end
		end
	end
	if id == 1 then
		local base = p(
			"FlutedBase",
			Vector3.new(0.25, 2.2, 2.2),
			Vector3.new(0, 0.2, 0),
			C.Brass,
			Enum.Material.Metal
		)
		base.Shape = Enum.PartType.Cylinder
		base.CFrame *= CFrame.Angles(0, 0, math.pi / 2)
		p(
			"Stem",
			Vector3.new(0.22, 2.6, 0.22),
			Vector3.new(0, 1.5, 0),
			C.Brass,
			Enum.Material.Metal
		)
		for i = 0, 11 do
			local theta = i * math.pi / 6
			local pleat = p(
				"PleatedShade",
				Vector3.new(0.65, 1.2, 0.14),
				Vector3.new(math.sin(theta) * 1.1, 3.3, math.cos(theta) * 1.1),
				C.Ivory,
				Enum.Material.Fabric
			)
			pleat.CFrame *= CFrame.Angles(0, theta, 0)
		end
		local bulb = p(
			"Bulb",
			Vector3.new(0.4, 0.6, 0.4),
			Vector3.new(0, 3.2, 0),
			C.Ivory,
			Enum.Material.Neon
		)
		bulb.Shape = Enum.PartType.Ball
	elseif id == 2 then
		p(
			"Cardboard",
			Vector3.new(2.8, 2.8, 2.8),
			Vector3.new(0, 1.4, 0),
			Color3.fromRGB(147, 119, 82),
			Enum.Material.Cardboard
		)
		p("Tape", Vector3.new(0.4, 2.85, 2.85), Vector3.new(0, 1.4, 0), C.Ivory)
		local tag = p("FragileLabel", Vector3.new(1.7, 1, 0.05), Vector3.new(0, 1.7, -1.43), C.Wood)
		Art.text(tag, "REGRETS\nTHIS WAY UP")
	elseif id == 4 then
		p("InlaidMusicCase", Vector3.new(2.5, 1, 2), Vector3.new(0, 0.6, 0), C.Wood)
		p("Lid", Vector3.new(2.6, 0.18, 2.1), Vector3.new(0, 1.2, 0), C.Brass)
		p(
			"VelvetInset",
			Vector3.new(2.2, 0.07, 1.7),
			Vector3.new(0, 1.33, 0),
			C.Teal,
			Enum.Material.Fabric
		)
		local dancer = p("CarvedBird", Vector3.new(0.7, 0.7, 0.4), Vector3.new(0, 1.75, 0), C.Ivory)
		dancer.Shape = Enum.PartType.Ball
		p("BirdWing", Vector3.new(1.4, 0.1, 0.35), Vector3.new(0, 1.8, 0), C.Brass)
		p(
			"WindingKey",
			Vector3.new(0.2, 0.6, 0.5),
			Vector3.new(1.35, 0.65, 0),
			C.Brass,
			Enum.Material.Metal
		)
	elseif id == 7 then
		p(
			"LeatherSuitcase",
			Vector3.new(2.8, 2.5, 1.7),
			Vector3.new(0, 1.3, 0),
			C.Rust,
			Enum.Material.Leather
		)
		for _, x in { -0.9, 0.9 } do
			p("TravelStrap", Vector3.new(0.18, 2.6, 1.8), Vector3.new(x, 1.3, 0), C.Brass)
		end
		p("SuitcaseHandle", Vector3.new(1.1, 0.15, 0.3), Vector3.new(0, 2.8, 0), C.Wood)
		local tag =
			p("Destination", Vector3.new(1.2, 0.7, 0.05), Vector3.new(0, 1.6, -0.88), C.Wood)
		Art.text(tag, "NEXT HOUSE\nONE WAY")
	elseif id == 9 then
		legs(0.5)
		for _, x in { -1.35, 1.35 } do
			p("MirrorStile", Vector3.new(0.22, 3.6, 0.35), Vector3.new(x, 2.1, -1.25), C.Brass)
		end
		for _, y in { 0.35, 3.8 } do
			p("MirrorRail", Vector3.new(2.9, 0.2, 0.35), Vector3.new(0, y, -1.25), C.Brass)
		end
		p("Stand", Vector3.new(0.25, 3.2, 0.25), Vector3.new(0, 1.8, 0.7), C.Wood)
	elseif id == 8 then
		legs(0.5)
		p("CabinetCarcass", Vector3.new(2.8, 2.3, 2.6), Vector3.new(0, 1.6, 0.15), C.Teal)
		p("OverhangingTop", Vector3.new(3, 0.25, 3), Vector3.new(0, 2.85, 0), C.Wood)
		for _, y in { 0.9, 1.6 } do
			p("LowerDrawer", Vector3.new(2.5, 0.6, 0.15), Vector3.new(0, y, -1.22), C.Wood)
			p("DrawerPull", Vector3.new(0.7, 0.1, 0.12), Vector3.new(0, y, -1.34), C.Brass)
		end
	elseif id == 6 or id == 12 then
		legs(2.7)
		p("Apron", Vector3.new(size.X - 0.5, 0.7, size.Z - 0.5), Vector3.new(0, 2.4, 0), C.Wood)
		p("BeveledTop", Vector3.new(size.X, 0.35, size.Z), Vector3.new(0, 2.95, 0), C.Wood)
		p("Inlay", Vector3.new(size.X - 0.3, 0.03, size.Z - 0.3), Vector3.new(0, 3.15, 0), C.Brass)
		p(
			"TopInset",
			Vector3.new(size.X - 0.45, 0.03, size.Z - 0.45),
			Vector3.new(0, 3.17, 0),
			C.Wood
		)
		if id == 6 then
			p(
				"Runner",
				Vector3.new(1.1, 0.05, size.Z - 0.2),
				Vector3.new(0, 3.2, 0),
				C.Ivory,
				Enum.Material.Fabric
			)
			for _, x in { -2, 2 } do
				local plate = p(
					"UnfinishedMeal",
					Vector3.new(0.08, 1.3, 1.3),
					Vector3.new(x, 3.23, 0),
					C.Ivory,
					Enum.Material.SmoothPlastic
				)
				plate.Shape = Enum.PartType.Cylinder
				plate.CFrame *= CFrame.Angles(0, 0, math.pi / 2)
				p(
					"Fork",
					Vector3.new(0.08, 0.05, 0.8),
					Vector3.new(x + 0.8, 3.24, 0),
					C.Brass,
					Enum.Material.Metal
				)
			end
		else
			local letter =
				p("LastLetter", Vector3.new(2, 0.03, 1.4), Vector3.new(0, 3.22, 0), C.Ivory)
			Art.text(letter, "TELL THE HOUSE\nGOODBYE", Enum.NormalId.Top)
			for i = 1, 3 do
				p("Ledger", Vector3.new(1.1, 0.2, 1.4), Vector3.new(2, 3.2 + i * 0.2, 0.6), C.Teal)
			end
		end
	else
		legs(1.3)
		local wide = id == 5 or id == 11
		local fabric = if id == 11 then Color3.fromRGB(109, 87, 100) else C.Teal
		p(
			"SeatFrame",
			Vector3.new(size.X - 0.15, 0.6, size.Z - 0.15),
			Vector3.new(0, 1.4, 0),
			C.Wood
		)
		local count = if wide then 3 else 1
		for i = 1, count do
			local x = (i - (count + 1) / 2) * (size.X - 1) / count
			p(
				"SeatCushion",
				Vector3.new((size.X - 1) / count - 0.06, 0.65, size.Z - 0.7),
				Vector3.new(x, 1.95, -0.1),
				fabric,
				Enum.Material.Fabric
			)
			p(
				"BackCushion",
				Vector3.new((size.X - 1) / count - 0.06, 1.7, 0.6),
				Vector3.new(x, 3.05, size.Z / 2 - 0.45),
				fabric,
				Enum.Material.Fabric
			)
			p(
				"TuftButton",
				Vector3.new(0.12, 0.12, 0.08),
				Vector3.new(x, 3.1, size.Z / 2 - 0.78),
				C.Brass
			)
		end
		for _, x in { -1, 1 } do
			local arm = p(
				"RolledArm",
				Vector3.new(size.Z - 0.2, 0.65, 0.65),
				Vector3.new(x * (size.X / 2 - 0.33), 2.55, 0),
				fabric,
				Enum.Material.Fabric
			)
			arm.Shape = Enum.PartType.Cylinder
			arm.CFrame *= CFrame.Angles(0, math.pi / 2, 0)
		end
		if id == 10 then
			for _, x in { -1, 1 } do
				for i = -2, 2 do
					local runner = p(
						"RockerRunner",
						Vector3.new(0.22, 0.18, 0.55),
						Vector3.new(x, 0.16 + math.abs(i) * 0.08, i * 0.52),
						C.Wood
					)
					runner.CFrame *= CFrame.Angles(i * 0.12, 0, 0)
				end
			end
		end
	end
	model:SetAttribute("ArtCollection", "ValeHouse1987")
end
return FurnitureArt
