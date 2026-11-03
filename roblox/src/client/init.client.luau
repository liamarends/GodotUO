--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")
local Debris = game:GetService("Debris")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("HouseRemotes")
local action = remotes:WaitForChild("Action") :: RemoteEvent
local event = remotes:WaitForChild("Update") :: RemoteEvent
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.ZIndexBehavior =
	"MovingCompanyHUD", false, Enum.ZIndexBehavior.Sibling
gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
gui.Parent = player:WaitForChild("PlayerGui")
player.CameraMinZoomDistance, player.CameraMaxZoomDistance = 5, 22

local colors = {
	Panel = Color3.fromRGB(21, 30, 43),
	Card = Color3.fromRGB(34, 46, 59),
	Cream = Color3.fromRGB(248, 232, 206),
	Orange = Color3.fromRGB(239, 155, 68),
	Teal = Color3.fromRGB(90, 193, 174),
	Muted = Color3.fromRGB(177, 189, 200),
	Red = Color3.fromRGB(239, 111, 101),
}
local state: any = { Phase = "Lobby", Noise = 0, Time = 0, Required = 4, Delivered = 0 }
local personal: any = {
	CanShop = false,
	Inventory = {
		Ready = false,
		Uses = { SoftSoles = 0, Padding = 0 },
		Progress = 0,
		Choice = "SoftSoles",
		Uniform = 0,
		Flashlight = 1,
	},
}
local priceInfo: any = {}
local cards: any = {}
local pendingBuy: any = nil
local sprint = false

local function roundCorners(instance: GuiObject, radius: number?)
	local corner = Instance.new("UICorner")
	corner.CornerRadius, corner.Parent = UDim.new(0, radius or 10), instance
end
local function frame(parent: Instance, name: string, pos: UDim2, size: UDim2, color: Color3): Frame
	local f = Instance.new("Frame")
	f.Name, f.Position, f.Size, f.BackgroundColor3, f.BorderSizePixel, f.Parent =
		name, pos, size, color, 0, parent
	roundCorners(f)
	return f
end
local function label(
	parent: Instance,
	text: string,
	pos: UDim2,
	size: UDim2,
	fontSize: number?
): TextLabel
	local l = Instance.new("TextLabel")
	l.Text, l.Position, l.Size, l.BackgroundTransparency = text, pos, size, 1
	l.TextColor3, l.Font, l.TextSize = colors.Cream, Enum.Font.GothamMedium, fontSize or 15
	l.TextWrapped, l.TextXAlignment, l.TextYAlignment =
		true, Enum.TextXAlignment.Left, Enum.TextYAlignment.Center
	l.Parent = parent
	return l
end
local function button(
	parent: Instance,
	text: string,
	pos: UDim2,
	size: UDim2,
	callback: () -> ()
): TextButton
	local b = Instance.new("TextButton")
	b.Text, b.Position, b.Size, b.BackgroundColor3, b.TextColor3 =
		text, pos, size, colors.Orange, colors.Panel
	b.Font, b.TextSize, b.TextWrapped, b.BorderSizePixel, b.Parent =
		Enum.Font.GothamBold, 14, true, 0, parent
	roundCorners(b, 8)
	b.Activated:Connect(callback)
	return b
end

local header =
	frame(gui, "Header", UDim2.fromOffset(10, 6), UDim2.new(1, -20, 0, 105), colors.Panel)
local brand = label(
	header,
	"HUSH & HAUL  /  NIGHT SHIFT",
	UDim2.fromOffset(12, 5),
	UDim2.new(1, -24, 0, 22),
	15
)
brand.TextColor3, brand.Font = colors.Orange, Enum.Font.GothamBold
local timer = label(header, "LOBBY", UDim2.fromOffset(12, 28), UDim2.new(0.35, -12, 0, 30), 23)
local delivered =
	label(header, "Load 0 / 4", UDim2.new(0.35, 0, 0, 28), UDim2.new(0.65, -12, 0, 30), 18)
delivered.TextXAlignment = Enum.TextXAlignment.Right
local noiseText =
	label(header, "HOUSE NOISE  0 / 100", UDim2.fromOffset(12, 58), UDim2.new(1, -24, 0, 22), 13)
local noiseTrack =
	frame(header, "NoiseTrack", UDim2.fromOffset(12, 84), UDim2.new(1, -24, 0, 10), colors.Card)
local noiseFill =
	frame(noiseTrack, "Fill", UDim2.fromScale(0, 0), UDim2.fromScale(0, 1), colors.Teal)
local context = label(
	gui,
	"Load labeled furniture. Move quietly. Leave together.",
	UDim2.fromOffset(14, 114),
	UDim2.new(1, -28, 0, 42),
	14
)
context.TextStrokeTransparency = 0.45
local teamStatus = label(gui, "", UDim2.fromOffset(14, 199), UDim2.new(1, -28, 0, 42), 12)
teamStatus.TextColor3, teamStatus.TextStrokeTransparency = colors.Teal, 0.35
local message =
	frame(gui, "Message", UDim2.new(0.1, 0, 0.45, -35), UDim2.new(0.8, 0, 0, 75), colors.Panel)
local messageText = label(message, "", UDim2.fromOffset(12, 6), UDim2.new(1, -24, 1, -12), 17)
message.Visible = false
local messageSerial = 0
local warningUntil = 0
local function toast(text: string, warning: boolean?)
	if not warning and os.clock() < warningUntil then
		return
	end
	if warning then
		warningUntil = os.clock() + 2
	end
	messageSerial += 1
	local serial = messageSerial
	message.Visible, messageText.Text = true, text
	message.BackgroundColor3 = if warning then Color3.fromRGB(100, 40, 39) else colors.Panel
	task.delay(if warning then 2 else 5, function()
		if serial == messageSerial then
			message.Visible = false
		end
	end)
end

local checklist =
	frame(gui, "Checklist", UDim2.fromOffset(10, 245), UDim2.new(0, 285, 0, 250), colors.Panel)
checklist.Visible = false
local listText = label(checklist, "", UDim2.fromOffset(10, 10), UDim2.new(1, -20, 1, -20), 13)
listText.TextYAlignment = Enum.TextYAlignment.Top
button(gui, "Checklist [C]", UDim2.fromOffset(10, 158), UDim2.fromOffset(130, 38), function()
	checklist.Visible = not checklist.Visible
end)
local shopButton: TextButton
local shop = frame(gui, "Shop", UDim2.fromScale(0.5, 0.5), UDim2.new(1, -24, 1, -24), colors.Panel)
shop.AnchorPoint, shop.Visible, shop.ZIndex = Vector2.new(0.5, 0.5), false, 10
local sizeLimit = Instance.new("UISizeConstraint")
sizeLimit.MaxSize, sizeLimit.Parent = Vector2.new(620, 660), shop
label(shop, "CREW SUPPLY DESK", UDim2.fromOffset(14, 10), UDim2.new(1, -70, 0, 28), 21)
button(shop, "X", UDim2.new(1, -52, 0, 8), UDim2.fromOffset(42, 38), function()
	shop.Visible = false
end)
local shopStatus =
	label(shop, "Inventory loading...", UDim2.fromOffset(14, 44), UDim2.new(1, -28, 0, 52), 13)
shopStatus.TextColor3 = colors.Teal
local scroll = Instance.new("ScrollingFrame")
scroll.Name, scroll.Position, scroll.Size =
	"Catalog", UDim2.fromOffset(10, 100), UDim2.new(1, -20, 1, -154)
scroll.BackgroundTransparency, scroll.BorderSizePixel, scroll.ScrollBarThickness = 1, 0, 6
scroll.AutomaticCanvasSize, scroll.CanvasSize, scroll.Parent =
	Enum.AutomaticSize.Y, UDim2.new(), shop
local layout = Instance.new("UIListLayout")
layout.Padding, layout.SortOrder, layout.Parent =
	UDim.new(0, 10), Enum.SortOrder.LayoutOrder, scroll

local function refreshShop()
	local inv = personal.Inventory
	shopButton.Visible = Config.Stage == 3
	shopButton.Text = if personal.CanShop then "Supplies [B]" else "Shop · lobby"
	if not personal.CanShop then
		shop.Visible = false
	end
	local supplier = state.Boost
	teamStatus.Text = (
		if supplier
			then (if supplier.Active then "TEAM BOOST · " else "NEXT ROUND · ")
				.. Config.Catalog[supplier.Key].Name
				.. " (10%) by "
				.. supplier.Name
			else "NO TEAM BOOST · one optional boost for everyone"
	)
		.. "\nFree use: "
		.. inv.Progress
		.. "/2 attempts · saved uses "
		.. inv.Uses.SoftSoles
		.. " soles / "
		.. inv.Uses.Padding
		.. " padding"
	local boostText = if supplier
		then (if supplier.Active then "Active: " else "Selected: ")
			.. Config.Catalog[supplier.Key].Name
			.. " by "
			.. supplier.Name
		else "Team boost slot: empty"
	shopStatus.Text = (
		if inv.Memory
			then "STUDIO DEMO · temporary inventory · no Robux\n"
			elseif not inv.Ready then "Inventory unavailable · purchases disabled\n"
			else "Saved uses never expire · purchases do not activate\n"
	) .. boostText
	for _, key in { "SoftSoles", "Padding", "CrewPack" } do
		local card, catalog, info = cards[key], Config.Catalog[key], priceInfo[key]
		if not card then
			continue
		end
		local owned = key == "CrewPack" and inv.OwnsCrew
		local enabled = inv.Ready
			and not inv.Memory
			and personal.CanShop
			and not owned
			and info ~= nil
			and info.ForSale
		card.Buy.Active, card.Buy.AutoButtonColor = enabled, enabled
		card.Buy.BackgroundColor3 = if enabled then colors.Orange else colors.Muted
		card.Buy.Text = if owned
			then "Owned"
			elseif inv.Memory then "Demo · no purchase"
			elseif (catalog.ProductId or catalog.PassId) <= 0 then "ID not configured"
			elseif info then (if info.ForSale
				then "Buy · " .. info.Price .. " Robux"
				else "Not for sale")
			else "Price unavailable"
		if key ~= "CrewPack" then
			card.Stock.Text = "Saved uses: " .. inv.Uses[key] .. "  |  " .. catalog.Duration
			card.Select.Text = if supplier
					and supplier.UserId == player.UserId
					and supplier.Key == key
					and not supplier.Active
				then "Cancel selection"
				else "Offer 1 use"
			card.Select.Active = inv.Ready
				and personal.CanShop
				and (state.Phase == "Lobby" or state.Phase == "Countdown")
			card.Earn.Text = if inv.Choice == key
				then "Free reward: selected"
				else "Choose free reward"
		end
	end
end

local function fetchPrices()
	for _, key in { "SoftSoles", "Padding", "CrewPack" } do
		local catalog = Config.Catalog[key]
		local id = catalog.ProductId or catalog.PassId
		if id <= 0 or personal.Inventory.Memory then
			continue
		end
		task.spawn(function()
			-- Client lookup is intentional: Roblox may personalize/regionalize the displayed price.
			local ok, info = pcall(function()
				return MarketplaceService:GetProductInfoAsync(
					id,
					if catalog.Kind == "Pass" then Enum.InfoType.GamePass else Enum.InfoType.Product
				)
			end)
			priceInfo[key] = if ok and type(info.PriceInRobux) == "number"
				then { Price = info.PriceInRobux, ForSale = info.IsForSale == true }
				else nil
			refreshShop()
		end)
	end
end
local function toggleShop()
	if not personal.CanShop then
		toast("The supply desk opens in the lobby between rounds.")
		return
	end
	shop.Visible = not shop.Visible
	if shop.Visible then
		checklist.Visible = false
		fetchPrices()
		refreshShop()
	end
end
shopButton =
	button(gui, "Supplies [B]", UDim2.fromOffset(148, 158), UDim2.fromOffset(130, 38), toggleShop)

for order, key in { "SoftSoles", "Padding", "CrewPack" } do
	local catalog = Config.Catalog[key]
	local card = frame(
		scroll,
		key,
		UDim2.new(),
		UDim2.new(1, -8, 0, if key == "CrewPack" then 184 else 226),
		colors.Card
	)
	card.LayoutOrder = order
	label(card, catalog.Name, UDim2.fromOffset(12, 8), UDim2.new(1, -24, 0, 26), 20)
	label(card, catalog.Description, UDim2.fromOffset(12, 39), UDim2.new(1, -24, 0, 58), 14)
	local stock =
		label(card, catalog.Duration, UDim2.fromOffset(12, 100), UDim2.new(1, -24, 0, 31), 12)
	stock.TextColor3 = colors.Teal
	local buy = button(
		card,
		"Price unavailable",
		UDim2.fromOffset(12, 138),
		UDim2.new(0.5, -18, 0, 38),
		function()
			local info = priceInfo[key]
			if
				not personal.CanShop
				or personal.Inventory.Memory
				or not personal.Inventory.Ready
				or not info
				or not info.ForSale
			then
				return
			end
			if key == "CrewPack" and personal.Inventory.OwnsCrew then
				return
			end
			pendingBuy = { Key = key, At = os.clock() }
			action:FireServer("Buy", key)
		end
	)
	local data: any = { Buy = buy, Stock = stock }
	if key ~= "CrewPack" then
		data.Select = button(
			card,
			"Offer 1 use",
			UDim2.new(0.5, 6, 0, 138),
			UDim2.new(0.5, -18, 0, 38),
			function()
				local selected = state.Boost
				action:FireServer(
					"SelectBoost",
					if selected
							and selected.UserId == player.UserId
							and selected.Key == key
							and not selected.Active
						then "None"
						else key
				)
			end
		)
		data.Earn = button(
			card,
			"Choose free reward",
			UDim2.fromOffset(12, 182),
			UDim2.new(1, -24, 0, 34),
			function()
				action:FireServer("Preference", key)
			end
		)
		data.Earn.BackgroundColor3 = colors.Teal
	else
		buy.Size = UDim2.new(1, -24, 0, 38)
	end
	cards[key] = data
end

local wardrobe = frame(scroll, "Cosmetics", UDim2.new(), UDim2.new(1, -8, 0, 202), colors.Card)
wardrobe.LayoutOrder = 4
label(
	wardrobe,
	"Crew wardrobe · pass owners",
	UDim2.fromOffset(12, 6),
	UDim2.new(1, -24, 0, 30),
	17
)
local uniformButton = button(
	wardrobe,
	"Uniform",
	UDim2.fromOffset(12, 44),
	UDim2.new(1, -24, 0, 40),
	function()
		action:FireServer("Cosmetic", "uniform", (personal.Inventory.Uniform + 1) % 4)
	end
)
local flashlightButton = button(
	wardrobe,
	"Flashlight color",
	UDim2.fromOffset(12, 92),
	UDim2.new(1, -24, 0, 40),
	function()
		action:FireServer("Cosmetic", "flashlight", personal.Inventory.Flashlight % 3 + 1)
	end
)
local supporterButton = button(
	wardrobe,
	"Supporter tag",
	UDim2.fromOffset(12, 140),
	UDim2.new(1, -24, 0, 40),
	function()
		action:FireServer("Cosmetic", "supporter", not personal.Inventory.Supporter)
	end
)
local reward = frame(scroll, "FreeAccess", UDim2.new(), UDim2.new(1, -8, 0, 134), colors.Card)
reward.LayoutOrder = 5
local progressText = label(reward, "", UDim2.fromOffset(12, 8), UDim2.new(1, -24, 0, 116), 14)
button(
	shop,
	"Refresh inventory / ownership",
	UDim2.fromOffset(14, 0),
	UDim2.new(1, -28, 0, 38),
	function()
		action:FireServer("Refresh")
		fetchPrices()
	end
).Position =
	UDim2.new(0, 14, 1, -46)

local startButton = button(
	gui,
	"CLOCK IN · START ROUND",
	UDim2.new(0.5, -115, 1, -65),
	UDim2.fromOffset(230, 46),
	function()
		action:FireServer("Start")
	end
)
local controls = frame(
	gui,
	"CarryControls",
	UDim2.new(1, -206, 1, -173),
	UDim2.fromOffset(196, 156),
	colors.Panel
)
button(controls, "Turn ↶ [R]", UDim2.fromOffset(7, 6), UDim2.fromOffset(88, 42), function()
	action:FireServer("Rotate", -1)
end)
button(controls, "Turn ↷ [T]", UDim2.fromOffset(101, 6), UDim2.fromOffset(88, 42), function()
	action:FireServer("Rotate", 1)
end)
button(controls, "Put down [G]", UDim2.fromOffset(7, 55), UDim2.fromOffset(182, 42), function()
	action:FireServer("Drop")
end)
local sprintButton = button(
	controls,
	"Sprint",
	UDim2.fromOffset(7, 104),
	UDim2.fromOffset(88, 42),
	function()
		sprint = not sprint
		action:FireServer("Sprint", sprint)
	end
)
button(controls, "Light [F]", UDim2.fromOffset(101, 104), UDim2.fromOffset(88, 42), function()
	action:FireServer("Flashlight")
end)
local leaveButton = button(
	gui,
	"LEAVE HIDE [H]",
	UDim2.new(0.5, -95, 1, -65),
	UDim2.fromOffset(190, 46),
	function()
		action:FireServer("LeaveHide")
	end
)
leaveButton.Visible = false

local function bind(name: string, key: Enum.KeyCode, callback: (Enum.UserInputState) -> ())
	ContextActionService:BindAction(name, function(_name, inputState, _input)
		callback(inputState)
		return Enum.ContextActionResult.Sink
	end, false, key)
end
bind("DWH_Sprint", Enum.KeyCode.LeftShift, function(input)
	if
		input == Enum.UserInputState.Begin
		or input == Enum.UserInputState.End
		or input == Enum.UserInputState.Cancel
	then
		sprint = input == Enum.UserInputState.Begin
		action:FireServer("Sprint", sprint)
	end
end)
for _, pair in
	{
		{ Name = "Drop", Key = Enum.KeyCode.G },
		{ Name = "Flashlight", Key = Enum.KeyCode.F },
		{ Name = "LeaveHide", Key = Enum.KeyCode.H },
	}
do
	bind("DWH_" .. pair.Name, pair.Key, function(input)
		if input == Enum.UserInputState.Begin then
			action:FireServer(pair.Name)
		end
	end)
end
bind("DWH_RotateLeft", Enum.KeyCode.R, function(input)
	if input == Enum.UserInputState.Begin then
		action:FireServer("Rotate", -1)
	end
end)
bind("DWH_RotateRight", Enum.KeyCode.T, function(input)
	if input == Enum.UserInputState.Begin then
		action:FireServer("Rotate", 1)
	end
end)
bind("DWH_Shop", Enum.KeyCode.B, function(input)
	if input == Enum.UserInputState.Begin then
		toggleShop()
	end
end)
bind("DWH_Checklist", Enum.KeyCode.C, function(input)
	if input == Enum.UserInputState.Begin then
		checklist.Visible = not checklist.Visible
	end
end)

local function soundAt(kind: string, pos: Vector3)
	local anchor = Instance.new("Part")
	anchor.Anchored, anchor.CanCollide, anchor.CanQuery, anchor.CanTouch, anchor.Transparency =
		true, false, false, false, 1
	anchor.Size, anchor.Position, anchor.Parent = Vector3.one, pos, workspace
	local sound = Instance.new("Sound")
	-- These are bundled Roblox engine sounds, verified against the installed client.
	sound.SoundId = if kind == "Bump"
		then "rbxasset://sounds/action_jump_land.mp3"
		elseif kind == "Creak" then "rbxasset://sounds/action_get_up.mp3"
		else "rbxasset://sounds/action_footsteps_plastic.mp3"
	sound.Volume, sound.PlaybackSpeed, sound.RollOffMaxDistance =
		0.55, if kind == "Creak" then 0.45 else 0.75, 100
	sound.Parent = anchor
	sound:Play()
	Debris:AddItem(anchor, 8)
end

event.OnClientEvent:Connect(function(kind: string, data: any)
	if kind == "State" then
		state = data
		timer.Text = if state.Phase == "Playing"
			then string.format("%d:%02d", math.floor(state.Time / 60), state.Time % 60)
			elseif state.Phase == "Countdown" then "START " .. state.Time
			elseif state.Phase == "Results" then "NEXT " .. state.Time
			else string.upper(state.Phase)
		delivered.Text = "LOAD " .. state.Delivered .. " / " .. state.Required
		noiseText.Text = "HOUSE NOISE  "
			.. state.Noise
			.. "/100"
			.. (
				if state.Hunting
					then "  •  HUNT " .. state.HuntTime .. "s"
					elseif state.Noise >= Config.Noise.Medium then "  •  RESTLESS"
					else "  •  SLEEPING"
			)
		noiseFill.Size = UDim2.fromScale(state.Noise / 100, 1)
		noiseFill.BackgroundColor3 = if state.Hunting or state.Noise >= 80
			then colors.Red
			elseif state.Noise >= Config.Noise.Medium then colors.Orange
			else colors.Teal
		startButton.Visible = state.Phase == "Lobby"
		local lines = { "LOAD ANY " .. state.Required .. " ITEMS · [2] = two movers\n" }
		for _, item in state.Checklist do
			table.insert(
				lines,
				(if item.Delivered then "✓ " else "○ ")
					.. item.Name
					.. (if item.Large then " [2]" else "")
			)
		end
		listText.Text = table.concat(lines, "\n")
		if state.Phase ~= "Playing" then
			sprint = false
		end
		refreshShop()
	elseif kind == "Personal" then
		personal = data
		local inv = data.Inventory
		controls.Visible = state.Phase == "Playing"
			and data.Participant
			and not data.Downed
			and not data.Hidden
		leaveButton.Visible = data.Hidden
		sprintButton.Text = if sprint then "Sprint ON" else "Walk / Sprint"
		if data.Downed then
			context.Text = if data.Recovery > 0
				then "DOWNED · solo recovery in " .. data.Recovery .. "s"
				else "DOWNED · a teammate must help you"
		elseif data.Hidden then
			context.Text = "HIDDEN · stay quiet. Leave when the hunt ends."
		elseif state.Phase == "Playing" and not data.Participant then
			context.Text = "Move in progress · you join the next round"
		elseif state.Phase == "Playing" and state.Delivered >= state.Required then
			context.Text = "ESCAPE · crew in truck " .. state.OnTruck .. "/" .. state.Crew
		elseif data.Carry then
			context.Text = "Carrying "
				.. data.Carry
				.. (
					if data.Large
						then " · stay close to your partner"
						else " · turn R/T, put down G"
				)
		elseif state.Phase == "Results" then
			context.Text = state.Result
		else
			context.Text = "[E / tap] carry or help · [Shift] sprint · [F] warm flashlight"
		end
		progressText.Text = "FREE USE: "
			.. inv.Progress
			.. "/"
			.. Config.AttemptsPerFreeUse
			.. " completed attempts → "
			.. Config.Catalog[inv.Choice].Name
			.. "\nWins AND losses count: move 45s + carry 12s, deliver, or rescue. This attempt: "
			.. data.ActiveSeconds
			.. "/45s; contribution "
			.. (if data.Contributed then "✓" else "pending")
			.. ". All maps, equipment and retries are free."
		uniformButton.Text = "Uniform: "
			.. (if inv.Uniform == 0 then "Your avatar" else Config.Uniforms[inv.Uniform].Name)
		flashlightButton.Text = "Light color " .. inv.Flashlight .. " / 3 · equal brightness"
		supporterButton.Text = "Supporter tag: " .. (if inv.Supporter then "ON" else "OFF")
		for _, b in { uniformButton, flashlightButton, supporterButton } do
			b.Active = inv.OwnsCrew and personal.CanShop
			b.BackgroundColor3 = if inv.OwnsCrew then colors.Teal else colors.Muted
		end
		refreshShop()
	elseif kind == "Purchase" then
		if
			not pendingBuy
			or pendingBuy.Key ~= data.Key
			or os.clock() - pendingBuy.At > 8
			or not personal.CanShop
			or not shop.Visible
			or personal.Inventory.Memory
		then
			return
		end
		pendingBuy = nil
		local ok = pcall(function()
			if data.Kind == "Pass" then
				MarketplaceService:PromptGamePassPurchase(player, data.Id)
			else
				MarketplaceService:PromptProductPurchase(player, data.Id)
			end
		end)
		if not ok then
			toast("Roblox could not open the purchase confirmation. Please try later.")
		end
	elseif kind == "Warning" then
		toast(data, true)
	elseif kind == "Ambience" then
		soundAt("Creak", data)
		task.delay(1, function()
			soundAt("Steps", data)
		end)
		toast("CREAK... slow footsteps upstairs.")
	elseif kind == "Sound" then
		soundAt(data.Kind, data.Position)
	else
		toast(data, kind == "Hunt")
	end
end)

-- Reset cannot be used as a free revive. Server death handling also preserves downed state.
task.spawn(function()
	for _ = 1, 10 do
		if
			pcall(function()
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
				StarterGui:SetCore("ResetButtonCallback", false)
			end)
		then
			break
		end
		task.wait(1)
	end
end)
action:FireServer("Sync")
