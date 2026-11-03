--!strict
-- Client-only, bounded animation. No physics or client-authoritative house state.
local RunService = game:GetService("RunService")
local Motion = {}
function Motion.start(): any
	local settings = { ReducedFlashing = true }
	local world = workspace:WaitForChild("HauntedHouse")
	local moving: { { Part: BasePart, Home: CFrame } } = {}
	local screens: { BasePart } = {}
	local lights: { PointLight } = {}
	for _, item in world:GetDescendants() do
		if item:IsA("BasePart") and item:GetAttribute("Sway") then
			table.insert(moving, { Part = item, Home = item.CFrame })
		elseif item:IsA("BasePart") and item:GetAttribute("Interference") then
			table.insert(screens, item)
		elseif item:IsA("PointLight") then
			table.insert(lights, item)
		end
	end
	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt: number)
		elapsed += dt
		if elapsed < 0.1 then
			return
		end
		elapsed = 0
		local now = os.clock()
		local camera = workspace.CurrentCamera
		for i, entry in moving do
			if
				entry.Part.Parent
				and camera
				and (camera.CFrame.Position - entry.Home.Position).Magnitude < 65
			then
				entry.Part.CFrame = entry.Home
					* CFrame.Angles(0, 0, math.sin(now * 0.6 + i) * 0.018)
			end
		end
		for _, screen in screens do
			if screen.Parent then
				local shade = if settings.ReducedFlashing
					then 0.28
					else 0.28 + math.sin(now * 2) * 0.025
				screen.Color = Color3.new(shade, shade + 0.04, shade + 0.055)
			end
		end
		-- Accessibility retains stable illumination while server warning subtitles persist.
		if settings.ReducedFlashing then
			for _, light in lights do
				if light.Parent and not light.Enabled then
					light.Enabled = true
				end
			end
		end
	end)
	return settings
end
return Motion
