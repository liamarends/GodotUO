--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
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
local subtitles = true
local shake = 0
local shakeUntil = 0
local bright = false
local environment = require(script.EnvironmentMotion).start()

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
local listScroll = Instance.new("ScrollingFrame")
listScroll.Size, listScroll.BackgroundTransparency, listScroll.AutomaticCanvasSize, listScroll.CanvasSize, listScroll.Parent =
	UDim2.fromScale(1, 1), 1, Enum.AutomaticSize.Y, UDim2.new(), checklist
local listText = label(listScroll, "", UDim2.fromOffset(10, 10), UDim2.new(1, -30, 0, 0), 13)
listText.AutomaticSize = Enum.AutomaticSize.Y
listText.TextYAlignment = Enum.TextYAlignment.Top
button(gui, "Checklist [C]", UDim2.fromOffset(10, 158), UDim2.new(0.33, -12, 0, 38), function()
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
	button(gui, "Supplies [B]", UDim2.new(0.33, 7, 0, 158), UDim2.new(0.33, -12, 0, 38), toggleShop)

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
	UDim2.new(1, -206, 1, -220),
	UDim2.fromOffset(196, 204),
	colors.Panel
)
button(controls, "Left [R]", UDim2.fromOffset(7, 6), UDim2.fromOffset(88, 42), function()
	action:FireServer("Rotate", -1)
end)
button(controls, "Right [T]", UDim2.fromOffset(101, 6), UDim2.fromOffset(88, 42), function()
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
local liftButton = button(
	controls,
	"Lift [U]",
	UDim2.fromOffset(7, 153),
	UDim2.fromOffset(88, 42),
	function()
		action:FireServer("Lift")
	end
)
button(controls, "Tool [V]", UDim2.fromOffset(101, 153), UDim2.fromOffset(88, 42), function()
	action:FireServer("UseTool")
end)
local utility =
	frame(gui, "CrewTools", UDim2.fromScale(0.5, 0.5), UDim2.new(1, -24, 1, -24), colors.Panel)
utility.AnchorPoint, utility.Visible, utility.ZIndex = Vector2.new(0.5, 0.5), false, 12
local utilitySize = Instance.new("UISizeConstraint")
utilitySize.MaxSize, utilitySize.Parent = Vector2.new(580, 580), utility
label(utility, "CREW TOOLS & ACCESS", UDim2.fromOffset(12, 5), UDim2.new(1, -70, 0, 36), 18)
button(utility, "X", UDim2.new(1, -52, 0, 6), UDim2.fromOffset(42, 38), function()
	utility.Visible = false
end)
local toolScroll = Instance.new("ScrollingFrame")
toolScroll.Size, toolScroll.Position, toolScroll.BackgroundTransparency =
	UDim2.new(1, -20, 1, -58), UDim2.fromOffset(10, 50), 1
toolScroll.AutomaticCanvasSize, toolScroll.CanvasSize, toolScroll.Parent =
	Enum.AutomaticSize.Y, UDim2.new(), utility
local toolLayout = Instance.new("UIListLayout")
toolLayout.Padding, toolLayout.SortOrder, toolLayout.Parent =
	UDim.new(0, 7), Enum.SortOrder.LayoutOrder, toolScroll
local toolOrder = 0
local function toolButton(text: string, callback: () -> ()): TextButton
	toolOrder += 1
	local b = button(toolScroll, text, UDim2.new(), UDim2.new(1, -12, 0, 44), callback)
	b.LayoutOrder = toolOrder
	return b
end
for _, ping in { "Hold", "Turn", "Put down" } do
	toolButton("Ping: " .. ping, function()
		action:FireServer("Ping", ping)
		utility.Visible = false
	end)
end
for _, equipment in Config.Equipment do
	toolButton("Free truck exchange: " .. equipment, function()
		action:FireServer("Equipment", equipment)
	end)
end
local equipmentInfo = label(
	toolScroll,
	"Decoy: redirect sound (35s cooldown). Wedge: keep a door open 45s. Dolly: solo drag +2 speed; cannot lift. Flashlight is always free.",
	UDim2.new(),
	UDim2.new(1, -16, 0, 80),
	13
)
toolOrder += 1
equipmentInfo.LayoutOrder = toolOrder
local crewInfo = label(toolScroll, "", UDim2.new(), UDim2.new(1, -16, 0, 75), 13)
toolOrder += 1
crewInfo.LayoutOrder = toolOrder
local toolStatus = toolButton("Use equipment [V]", function()
	action:FireServer("UseTool")
	utility.Visible = false
end)
toolButton("Recover stuck load [J] · returns a few studs", function()
	action:FireServer("RecoverLoad")
	utility.Visible = false
end)
local departButton = toolButton("DEPART · everyone aboard must approve", function()
	action:FireServer("Depart")
end)
toolButton("Subtitles on/off", function()
	subtitles = not subtitles
	toast(if subtitles then "Important sound subtitles ON" else "Sound subtitles OFF")
end)
toolButton("Camera shake: cycle OFF / LOW / FULL", function()
	shake = (shake + 1) % 3
	toast("Camera shake: " .. ({ "OFF", "LOW", "FULL" })[shake + 1])
end)
toolButton("Reduced flashing: ON / OFF", function()
	environment.ReducedFlashing = not environment.ReducedFlashing
	toast(
		if environment.ReducedFlashing
			then "Reduced flashing ON · stable room lights"
			else "Reduced flashing OFF · occasional slow lamp failure"
	)
end)
toolButton("Darkness: standard / brighter", function()
	bright = not bright
	Lighting.ExposureCompensation = if bright then 0.7 else 0
	toast(if bright then "Brighter rooms" else "Standard moonlight")
end)
toolButton("Earned Memory Keeper badge on/off (12 stamps)", function()
	action:FireServer("Cosmetic", "badge", not personal.Inventory.Badge)
end)
button(gui, "Tools [X]", UDim2.new(0.66, 8, 0, 158), UDim2.new(0.34, -18, 0, 38), function()
	utility.Visible = not utility.Visible
	shop.Visible = false
	checklist.Visible = false
end)
local subtitle = label(gui, "", UDim2.new(0.05, 0, 0.72, 0), UDim2.new(0.9, 0, 0, 48), 15)
subtitle.TextXAlignment, subtitle.TextStrokeTransparency = Enum.TextXAlignment.Center, 0.2
local subtitleAt = 0
local report =
	frame(gui, "ShiftReport", UDim2.fromScale(0.5, 0.5), UDim2.new(0.9, 0, 0.45, 0), colors.Panel)
report.AnchorPoint, report.Visible = Vector2.new(0.5, 0.5), false
local reportText = label(report, "", UDim2.fromOffset(14, 12), UDim2.new(1, -28, 1, -24), 16)
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
		{ Name = "Lift", Key = Enum.KeyCode.U },
		{ Name = "UseTool", Key = Enum.KeyCode.V },
		{ Name = "RecoverLoad", Key = Enum.KeyCode.J },
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

bind("DWH_Tools", Enum.KeyCode.X, function(input)
	if input == Enum.UserInputState.Begin then
		utility.Visible = not utility.Visible
		shop.Visible = false
		checklist.Visible = false
	end
end)
for index, ping in { "Hold", "Turn", "Put down" } do
	bind(
		"DWH_Ping" .. index,
		({ Enum.KeyCode.Z, Enum.KeyCode.N, Enum.KeyCode.M })[index],
		function(input)
			if input == Enum.UserInputState.Begin then
				action:FireServer("Ping", ping)
			end
		end
	)
end
local function soundAt(kind: string, pos: Vector3)
	local anchor = Instance.new("Part")
	anchor.Anchored, anchor.CanCollide, anchor.CanQuery, anchor.CanTouch, anchor.Transparency =
		true, false, false, false, 1
	anchor.Size, anchor.Position, anchor.Parent = Vector3.one, pos, workspace
	local sound = Instance.new("Sound")
	-- These are bundled Roblox engine sounds, verified against the installed client.
	sound.SoundId = if kind == "Bump"
		then "rbxasset://sounds/action_jump_land.mp3"
		elseif kind == "Creak" or kind == "Music" then "rbxasset://sounds/action_get_up.mp3"
		elseif
			kind == "Knock"
			or kind == "Duvet"
			or kind == "Latch"
		then "rbxasset://sounds/action_jump_land.mp3"
		else "rbxasset://sounds/action_footsteps_plastic.mp3"
	sound.Volume, sound.PlaybackSpeed, sound.RollOffMaxDistance =
		0.5,
		if kind == "Creak"
			then 0.45
			elseif kind == "Music" then 1.5
			elseif kind == "Duvet" then 0.35
			else 0.75,
		75
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
			.. "/100 · "
			.. (state.Awareness or "Asleep")
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
		local lines =
			{ "LOAD " .. state.Required .. " [REQ] ITEMS\n[OPT] = bonus · [2] = two movers\n" }
		for _, item in state.Checklist do
			table.insert(
				lines,
				(if item.Delivered then "✓ " else "○ ")
					.. (if item.Required then "[REQ] " else "[OPT] ")
					.. item.Name
					.. (if item.Large then " [2]" else "")
			)
		end
		local crewLines = { "CREW · useful even while waiting or downed" }
		for _, mover in state.Teammates or {} do
			table.insert(crewLines, mover.Name .. ": " .. mover.Status)
		end
		crewInfo.Text = table.concat(crewLines, "\n")
		listText.Text = table.concat(lines, "\n")
		report.Visible = state.Phase == "Results" and not utility.Visible and not shop.Visible
		reportText.Text = "SHIFT REPORT\n" .. state.Result
		departButton.Text = (
			if state.Delivered >= state.Required then "DEPART" else "LEAVE EARLY · reduced stamps"
		)
			.. " · "
			.. (state.Votes or 0)
			.. "/"
			.. (state.Crew or 0)
			.. " approvals · tap to approve/cancel"
		toolStatus.Text = "Use "
			.. (personal.Equipment or "Decoy")
			.. " [V] · cooldown "
			.. (personal.ToolCooldown or 0)
			.. "s"
		if state.Phase ~= "Playing" then
			sprint = false
		end
		refreshShop()
	elseif kind == "Personal" then
		personal = data
		liftButton.Text = if data.LiftReady then "Lower [U]" else "Lift [U]"
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
			.. ". All maps, equipment and retries are free.\nCosmetic stamps: "
			.. (inv.Mementos or 0)
			.. " / 12 for Memory Keeper badge (Tools)."
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
	elseif kind == "Cue" then
		local camera = workspace.CurrentCamera
		local direction = "nearby"
		if camera then
			local offset = camera.CFrame:PointToObjectSpace(data.Position)
			direction = (
				if offset.Z > 0
					then "behind"
					elseif math.abs(offset.X) < 4 then "ahead"
					elseif offset.X < 0 then "left"
					else "right"
			)
				.. " · "
				.. math.floor(offset.Magnitude)
				.. " studs"
		end
		if subtitles or data.Kind == "Ping" then
			subtitle.Text = data.Text .. " [" .. direction .. "]"
			subtitleAt = os.clock() + 3
		end
		if data.Kind ~= "Noise" and data.Kind ~= "Ping" then
			soundAt(data.Kind, data.Position)
		end
		if data.Kind == "Duvet" or data.Kind == "Knock" then
			task.delay(0.3, function()
				soundAt(data.Kind, data.Position)
			end)
		end
	elseif kind == "Warning" then
		shakeUntil = os.clock() + 0.8
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

-- Local procedural carrying pose; no uploaded animation IDs or game-state authority.
local shoulders: { Motor6D } = {}
local lastChar: Model? = nil
local posed = false
RunService.PreSimulation:Connect(function()
	local char = player.Character
	if char ~= lastChar then
		lastChar = char
		shoulders = {}
		posed = false
		if char then
			for _, joint in char:GetDescendants() do
				if
					joint:IsA("Motor6D")
					and (
						joint.Name == "RightShoulder"
						or joint.Name == "LeftShoulder"
						or joint.Name == "Right Shoulder"
						or joint.Name == "Left Shoulder"
					)
				then
					table.insert(shoulders, joint)
				end
			end
		end
	end
	if personal.Carry then
		posed = true
		for _, joint in shoulders do
			joint.Transform = CFrame.Angles(
				math.rad(-65) + (if personal.LiftReady then -0.2 else 0),
				0,
				math.sin(os.clock() * 4) * 0.025
			)
		end
	elseif posed then
		for _, joint in shoulders do
			joint.Transform = CFrame.identity
		end
		posed = false
	end
end)
RunService:BindToRenderStep("DWHComfort", Enum.RenderPriority.Camera.Value + 1, function()
	if os.clock() > subtitleAt then
		subtitle.Text = ""
	end
	local camera = workspace.CurrentCamera
	if camera and shake > 0 and os.clock() < shakeUntil then
		camera.CFrame *= CFrame.Angles(math.sin(os.clock() * 35) * 0.002 * shake, 0, 0)
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
