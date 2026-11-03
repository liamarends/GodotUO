--!strict
local Config = require(game:GetService("ReplicatedStorage").Shared.GameConfig)
local Cosmetics = {}
function Cosmetics.apply(player: Player, snapshot: any)
	local char = player.Character
	if not char then
		return
	end
	local head = char:FindFirstChild("Head") :: BasePart?
	local torso = (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")) :: BasePart?
	if not head or not torso then
		return
	end
	local old = char:FindFirstChild("CompanyUniform")
	if old then
		old:Destroy()
	end
	local existingLamp = head:FindFirstChild("CrewFlashlight")
	local lamp: SpotLight
	if existingLamp and existingLamp:IsA("SpotLight") then
		lamp = existingLamp
	else
		lamp = Instance.new("SpotLight")
		lamp.Name, lamp.Face, lamp.Angle, lamp.Shadows, lamp.Parent =
			"CrewFlashlight", Enum.NormalId.Front, 85, true, head
	end
	lamp.Brightness, lamp.Range = Config.FlashlightBrightness, Config.FlashlightRange
	lamp.Color = Config.FlashlightColors[if snapshot.OwnsCrew then snapshot.Flashlight else 1]
	lamp.Enabled = player:GetAttribute("Flashlight") ~= false
	local housing = head:FindFirstChild("CrewLampHousing")
	if not housing then
		local shell = Instance.new("Part")
		shell.Name, shell.Size, shell.CFrame =
			"CrewLampHousing", Vector3.new(0.65, 0.45, 0.5), head.CFrame * CFrame.new(0, 0.3, -0.65)
		shell.Color, shell.Material = Color3.fromRGB(213, 136, 55), Enum.Material.Metal
		shell.CanCollide, shell.CanQuery, shell.CanTouch, shell.Massless = false, false, false, true
		shell.Parent = head
		local weld = Instance.new("WeldConstraint")
		weld.Part0, weld.Part1, weld.Parent = head, shell, shell
	end
	local uniform = if snapshot.OwnsCrew then snapshot.Uniform else 0
	if uniform > 0 then
		local outfit = Instance.new("Folder")
		outfit.Name, outfit.Parent = "CompanyUniform", char
		local vest = Instance.new("Part")
		vest.Name, vest.Size, vest.CFrame =
			"Vest", torso.Size + Vector3.new(0.12, 0.1, 0.14), torso.CFrame
		vest.Color, vest.Material = Config.Uniforms[uniform].Color, Enum.Material.Fabric
		vest.CanCollide, vest.CanQuery, vest.CanTouch, vest.Massless = false, false, false, true
		vest.Parent = outfit
		local weld = Instance.new("WeldConstraint")
		weld.Part0, weld.Part1, weld.Parent = torso, vest, vest
		local stripe = Instance.new("SurfaceGui")
		stripe.Face, stripe.Parent = Enum.NormalId.Front, vest
		local label = Instance.new("TextLabel")
		label.Size, label.BackgroundTransparency, label.TextScaled = UDim2.fromScale(1, 1), 1, true
		label.Text, label.Font, label.TextColor3, label.Parent =
			"HUSH\n& HAUL", Enum.Font.GothamBold, Color3.fromRGB(255, 240, 201), stripe
		for _, name in
			{
				"Left Leg",
				"Right Leg",
				"LeftUpperLeg",
				"RightUpperLeg",
				"LeftLowerLeg",
				"RightLowerLeg",
			}
		do
			local leg = char:FindFirstChild(name)
			if leg and leg:IsA("BasePart") then
				local trouser = Instance.new("Part")
				trouser.Name, trouser.Size, trouser.CFrame =
					"WorkTrousers", leg.Size + Vector3.new(0.06, 0.02, 0.06), leg.CFrame
				trouser.Color, trouser.Material = Color3.fromRGB(44, 57, 71), Enum.Material.Fabric
				trouser.Massless, trouser.CanCollide, trouser.CanQuery, trouser.CanTouch =
					true, false, false, false
				trouser.Parent = outfit
				local legWeld = Instance.new("WeldConstraint")
				legWeld.Part0, legWeld.Part1, legWeld.Parent = leg, trouser, trouser
			end
		end
	end
	local earned = head:FindFirstChild("MemoryBadge")
	if earned then
		earned:Destroy()
	end
	if snapshot.Badge and (snapshot.Mementos or 0) >= Config.CosmeticRewardStep then
		local tag = Instance.new("BillboardGui")
		tag.Name, tag.Size, tag.StudsOffset, tag.MaxDistance, tag.Parent =
			"MemoryBadge", UDim2.fromOffset(170, 22), Vector3.new(0, 2.5, 0), 50, head
		local text = Instance.new("TextLabel")
		text.Size, text.BackgroundTransparency, text.TextScaled = UDim2.fromScale(1, 1), 1, true
		text.Text, text.TextColor3, text.Parent =
			"MEMORY KEEPER", Color3.fromRGB(120, 220, 194), tag
	end
	local oldTag = head:FindFirstChild("SupporterTag")
	if oldTag then
		oldTag:Destroy()
	end
	if snapshot.OwnsCrew and snapshot.Supporter then
		local tag = Instance.new("BillboardGui")
		tag.Name, tag.Size, tag.StudsOffset, tag.MaxDistance, tag.Parent =
			"SupporterTag", UDim2.fromOffset(180, 25), Vector3.new(0, 3, 0), 60, head
		local label = Instance.new("TextLabel")
		label.Size, label.BackgroundTransparency, label.TextScaled = UDim2.fromScale(1, 1), 1, true
		label.Text, label.TextColor3, label.Font, label.Parent =
			"MOVING CREW SUPPORTER", Color3.fromRGB(255, 211, 135), Enum.Font.GothamBold, tag
	end
end
return Cosmetics
