--!strict
-- Only packaged by build_studio_audit.py. Never present in the normal place.
-- Uses engine fixtures, not human-input or performance certification.
return function(g: any)
	assert(game:GetService("RunService"):IsStudio(), "Audit is Studio-only")
	local Players = game:GetService("Players")
	local Config = require(game:GetService("ReplicatedStorage").Shared.GameConfig)
	assert(Config.StudioMemoryMode, "Audit requires isolated demo inventory")
	local passed, failed = 0, 0
	local function check(name: string, fn: () -> ())
		local ok, err = pcall(fn)
		if ok then
			passed += 1
			print("AUDIT PASS " .. name)
		else
			failed += 1
			warn("AUDIT FAIL " .. name .. ": " .. tostring(err))
		end
	end
	task.wait(5)
	local expected = script.Parent:GetAttribute("AuditPlayers") or 1
	local untilAt = os.clock() + 180
	while #Players:GetPlayers() < expected and os.clock() < untilAt do
		task.wait(1)
	end
	check("expected connected client count", function()
		assert(#Players:GetPlayers() == expected, tostring(#Players:GetPlayers()))
	end)
	local world = g.World
	check("decoration cannot snag or block queries", function()
		for _, p in world.Art:GetDescendants() do
			if p:IsA("BasePart") then
				assert(not p.CanCollide and not p.CanQuery and not p.CanTouch, p:GetFullName())
			end
		end
	end)
	check("bounded scene complexity", function()
		local count, shadows = 0, 0
		for _, p in world.Folder:GetDescendants() do
			if p:IsA("BasePart") then
				count += 1
			end
			if p:IsA("Light") and p.Shadows then
				shadows += 1
			end
		end
		print("AUDIT METRIC parts=" .. count .. " shadowLights=" .. shadows)
		assert(count < 1800 and shadows <= 5, "geometry/light budget exceeded")
	end)
	g.House:reset()
	for _, item in g.Furniture.Items do
		check("spawn bounds " .. item.Name, function()
			assert(
				#workspace:GetPartBoundsInBox(
						item.Root.CFrame,
						item.Size * 0.94,
						g.Furniture.Overlap
					) == 0,
				"spawn intersects blocker"
			)
			assert(item.Model:GetAttribute("ArtCollection") == "ValeHouse1987")
		end)
		check("swept delivery route " .. item.Name, function()
			local upper = item.Spawn.Position.Y > 12
			local y = (if upper then 14 else 1) + item.Size.Y / 2 + 0.1
			local x = item.Spawn.Position.X
			local route = { item.Spawn, CFrame.new(if x < -10 then -18 else x, y, -2) }
			if x < -10 then
				table.insert(route, CFrame.new(0, y, -2))
			end
			if upper then
				for _, cf in
					{
						CFrame.new(12, y, -2),
						CFrame.new(12, y, -19),
						CFrame.new(26, y, -19),
						CFrame.new(26, y, -19) * CFrame.Angles(0, math.pi / 2, 0),
					}
				do
					table.insert(route, cf)
				end
				for i = 16, 1, -1 do
					table.insert(
						route,
						CFrame.new(26, 1 + i * 13 / 16 + item.Size.Y / 2 + 0.1, 17 - i * 2)
							* CFrame.Angles(0, math.pi / 2, 0)
					)
				end
				table.insert(
					route,
					CFrame.new(26, 1 + item.Size.Y / 2 + 0.1, 19) * CFrame.Angles(0, math.pi / 2, 0)
				)
				table.insert(
					route,
					CFrame.new(12, 1 + item.Size.Y / 2 + 0.1, 19) * CFrame.Angles(0, math.pi / 2, 0)
				)
			end
			local low = 1 + item.Size.Y / 2 + 0.1
			for _, cf in
				{
					CFrame.new(0, low, 12),
					CFrame.new(0, low, 29),
					CFrame.new(0, low, 40),
					CFrame.new(0, low, 52),
				}
			do
				table.insert(route, cf)
			end
			for i = 2, #route do
				local a, b = route[i - 1], route[i]
				local steps = math.max(18, math.ceil((a.Position - b.Position).Magnitude * 3))
				for n = 0, steps do
					local cf = a:Lerp(b, n / steps)
					local hits =
						workspace:GetPartBoundsInBox(cf, item.Size * 0.94, g.Furniture.Overlap)
					assert(
						#hits == 0,
						"segment "
							.. i
							.. " at "
							.. tostring(cf.Position)
							.. " hits "
							.. (if hits[1] then hits[1].Name else "?")
					)
				end
			end
		end)
	end
	world.MemorySeal.CanCollide, world.MemorySeal.CanQuery = false, false -- same gate state as a hunt
	for _, destination in
		{
			Vector3.new(0, 3, 36),
			Vector3.new(-20, 3, 0),
			Vector3.new(0, 3, -44),
			Vector3.new(0, -8, -44),
			Vector3.new(-43, 3, -50),
		}
	do
		check("monster engine path " .. tostring(destination), function()
			local path = game:GetService("PathfindingService"):CreatePath({
				AgentRadius = 2,
				AgentHeight = 7,
				AgentCanJump = true,
				WaypointSpacing = 3,
			})
			path:ComputeAsync(world.MonsterSpawn.Position, destination)
			assert(path.Status == Enum.PathStatus.Success, tostring(path.Status))
		end)
	end
	local player = Players:GetPlayers()[1]
	if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local root = player.Character.HumanoidRootPart
		check("round start and selected boost exactly once", function()
			local before = g.Inventory:snapshot(player).Uses.SoftSoles
			g.Selected = { UserId = player.UserId, Key = "SoftSoles", Name = player.Name }
			g:start()
			g:beginRound()
			assert(g.Phase == "Playing" and g.Boost.Key == "SoftSoles")
			assert(g.Inventory:snapshot(player).Uses.SoftSoles == before - 1)
		end)
		check("engine pickup distance, release and delivery dedup", function()
			local item = g.Furniture.Items[1]
			g.Furniture:pickup(player, item, 1)
			assert(not g.Furniture.Carrying[player], "distant pickup accepted")
			root.CFrame = item.Root.CFrame * CFrame.new(0, 0, -4)
			g.Participants[player].LastPos = root.Position
			g.Furniture:pickup(player, item, 1)
			assert(g.Furniture.Carrying[player] == item, "near pickup rejected")
			g.Furniture:release(player, false)
			assert(not g.Furniture.Carrying[player])
			item.Model:PivotTo(CFrame.new(0, 3, 52))
			local before = g.Delivered + g.Optional
			g.Furniture:step(0.1)
			g.Furniture:step(0.1)
			assert(g.Delivered + g.Optional == before + 1 and item.Delivered)
		end)
		check("hunt wake/reset", function()
			g.Monster.RestUntil = 0
			g.Monster:wake()
			assert(g.Monster.Hunting and not g.Monster.Root.Anchored)
			g.Monster:reset()
			assert(not g.Monster.Hunting and g.Monster.Root.Anchored)
		end)
		if #Players:GetPlayers() >= 2 then
			check("two real clients claim opposite handles and release independently", function()
				local partner = Players:GetPlayers()[2]
				local other = partner.Character
					and partner.Character:FindFirstChild("HumanoidRootPart")
				assert(other, "partner avatar not ready")
				local item = g.Furniture.Items[5]
				root.CFrame = item.Root.CFrame * CFrame.new(-6, 1, 0)
				other.CFrame = item.Root.CFrame * CFrame.new(6, 1, 0)
				g.Participants[player].LastPos = root.Position
				g.Participants[partner].LastPos = other.Position
				g.Furniture:pickup(player, item, 1)
				local before = item.Root.Position
				g.Furniture:step(0.1)
				assert(
					(item.Root.Position - before).Magnitude < 0.01,
					"single carrier moved large load"
				)
				g.Furniture:pickup(partner, item, 2)
				assert(#item.Carriers == 2 and item.Slots[1] == player and item.Slots[2] == partner)
				g.Furniture:release(partner, false)
				assert(#item.Carriers == 1 and g.Furniture.Carrying[player] == item)
				g.Furniture:release(player, false)
			end)
		end
		check("timeout loss and clean replay", function()
			g.Deadline = os.clock() - 1
			g:step(0.1)
			assert(g.Phase == "Results")
			g.Deadline = os.clock() - 1
			g:step(0.1)
			assert(g.Phase == "Lobby")
			g:start()
			g:beginRound()
			assert(g.Phase == "Playing" and g.Delivered == 0 and not g.Boost)
			assert(#g.Furniture.Items == 12 and not g.Furniture.Items[1].Delivered)
		end)
		check("completed contract departure", function()
			for _, item in g.Furniture.Items do
				if item.Required then
					item.Model:PivotTo(CFrame.new(0, 3, 52))
				end
			end
			g.Furniture:step(0.1)
			assert(g.Delivered == g.Required)
			for mover, stats in g.Participants do
				local rr = mover.Character.HumanoidRootPart
				rr.CFrame = CFrame.new(0, 4, 52)
				stats.LastPos = rr.Position
				g:action(mover, "Depart")
			end
			g:step(0.1)
			assert(g.Phase == "Results", "departure did not finish")
		end)
	else
		warn("AUDIT SKIP round fixtures: no loaded client")
	end
	print(
		"AUDIT COMPLETE passed="
			.. passed
			.. " failed="
			.. failed
			.. "; engine fixtures, NOT human-input/multiplayer certification"
	)
	world.Folder:SetAttribute("AuditComplete", true)
end
