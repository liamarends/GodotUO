--!strict
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Config = require(Shared.GameConfig)
local Rules = require(Shared.Rules)
local Inventory = {}

local function decode(raw: any): any
	if raw == nil then
		return Rules.newProfile()
	end
	assert(
		type(raw) == "table" and raw.version == 1,
		"Unsupported inventory schema; refusing overwrite"
	)
	for _, key in { "uses", "receipts", "activations", "attempts" } do
		assert(type(raw[key]) == "table", "Invalid inventory")
	end
	for _, key in { "SoftSoles", "Padding" } do
		local n = raw.uses[key]
		assert(type(n) == "number" and n >= 0 and n < math.huge and n % 1 == 0, "Invalid balance")
	end
	assert(
		Rules.isBoost(raw.choice)
			and type(raw.progress) == "number"
			and raw.progress >= 0
			and raw.progress < Config.AttemptsPerFreeUse,
		"Invalid reward progress"
	)
	raw.pending = raw.pending or {}
	return raw
end

function Inventory.new(notify: (Player, string) -> ()): any
	local self: any = {
		Cache = {},
		Busy = {},
		Owned = {},
		Notify = notify,
		Pending = 0,
		Memory = RunService:IsStudio() and Config.StudioMemoryMode,
		Changed = function(_player: Player) end,
	}
	self.Store = if self.Memory then nil else DataStoreService:GetDataStore(Config.StoreName)
	setmetatable(self, { __index = Inventory })
	return self
end

-- Every mutation reads the latest durable value; no stale profile is saved on leave.
-- A receipt marker and its inventory grant share ONE UpdateAsync transaction/key.
function Inventory.update(self: any, userId: number, change: (any) -> ()): (boolean, any)
	while self.Busy[userId] do
		task.wait(0.05)
	end
	self.Busy[userId], self.Pending = true, self.Pending + 1
	local ok, result = pcall(function()
		if self.Memory then
			local data = self.Cache[userId]
			if not data then
				data = Rules.newProfile()
				data.uses.SoftSoles, data.uses.Padding =
					Config.StudioTestInventory, Config.StudioTestInventory
			end
			change(data)
			return data
		end
		return self.Store:UpdateAsync("u_" .. userId, function(raw: any)
			local data = decode(raw)
			-- Recover an unconfirmed start after a server crash. Confirmed rounds keep their charge.
			for id, pending in data.pending do
				if pending.expires < os.time() then
					if data.activations[id] == pending.key then
						data.uses[pending.key] += 1
						data.activations[id] = "Refunded"
					end
					data.pending[id] = nil
				end
			end
			change(data) -- MUST NOT yield. Roblox may rerun this transform.
			return data
		end)
	end)
	if ok then
		self.Cache[userId] = result
	end
	self.Busy[userId], self.Pending = nil, self.Pending - 1
	if not ok then
		warn("DWH inventory transaction failed; no success acknowledged:", result)
	end
	local player = Players:GetPlayerByUserId(userId)
	if ok and player then
		local notified, notificationError = pcall(self.Changed, player)
		if not notified then
			warn("DWH inventory UI refresh failed:", notificationError)
		end
	end
	return ok, result
end

function Inventory.load(self: any, player: Player)
	local ok = self:update(player.UserId, function(_data: any) end)
	if not ok then
		self.Notify(
			player,
			"Inventory unavailable. Gameplay is free; purchases and boosts wait for a safe load."
		)
	end
	self:refreshPass(player)
end

function Inventory.refreshPass(self: any, player: Player)
	local owns = false
	if self.Memory then
		owns = Config.StudioTestOwnsCrewPack
	elseif Config.Catalog.CrewPack.PassId > 0 then
		local ok, result = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(
				player.UserId,
				Config.Catalog.CrewPack.PassId
			)
		end)
		if not ok then
			return
		end -- Do not revoke an already verified pass during a transient error.
		owns = result
	end
	self.Owned[player.UserId] = owns
	self.Changed(player)
end

function Inventory.snapshot(self: any, player: Player): any
	local data = self.Cache[player.UserId]
	return {
		Ready = data ~= nil,
		Memory = self.Memory,
		OwnsCrew = self.Owned[player.UserId] == true,
		Uses = if data then table.clone(data.uses) else { SoftSoles = 0, Padding = 0 },
		Progress = if data then data.progress else 0,
		Choice = if data then data.choice else "SoftSoles",
		Uniform = if data then data.uniform else 0,
		Flashlight = if data then data.flashlight else 1,
		Supporter = if data then data.supporter else false,
	}
end

function Inventory.consume(self: any, userId: number, roundId: string, key: string): boolean
	local ok, data = self:update(userId, function(profile: any)
		if Rules.consume(profile, roundId, key) then
			profile.pending[roundId] =
				{ key = key, expires = os.time() + Config.RoundSeconds + 120 }
		end
	end)
	return ok and data.activations[roundId] == key
end

function Inventory.confirm(self: any, userId: number, roundId: string): boolean
	local ok = self:update(userId, function(data: any)
		data.pending[roundId] = nil
	end)
	return ok
end

function Inventory.refund(self: any, userId: number, roundId: string, key: string): boolean
	local ok = self:update(userId, function(data: any)
		if data.activations[roundId] == key then
			data.uses[key] += 1
			data.activations[roundId] = "Refunded"
		end
		data.pending[roundId] = nil
	end)
	return ok
end

function Inventory.complete(
	self: any,
	userId: number,
	roundId: string,
	meaningful: boolean
): boolean
	if not meaningful then
		return true
	end
	local ok = self:update(userId, function(data: any)
		Rules.completeAttempt(data, roundId, meaningful, Config.AttemptsPerFreeUse)
	end)
	return ok
end

function Inventory.choose(self: any, player: Player, key: string)
	if not Rules.isBoost(key) then
		return
	end
	local ok = self:update(player.UserId, function(data: any)
		data.choice = key
	end)
	if not ok then
		self.Notify(player, "Could not save your free-use choice. Please try again.")
	end
end

function Inventory.cosmetic(self: any, player: Player, field: string, value: any)
	if not self.Owned[player.UserId] then
		return
	end
	if field == "supporter" then
		if type(value) ~= "boolean" then
			return
		end
	elseif field == "uniform" or field == "flashlight" then
		if
			type(value) ~= "number"
			or value % 1 ~= 0
			or value < (if field == "uniform" then 0 else 1)
			or value > 3
		then
			return
		end
	else
		return
	end
	local ok = self:update(player.UserId, function(data: any)
		data[field] = value
	end)
	if not ok then
		self.Notify(player, "Cosmetic choice could not be saved.")
	end
end

function Inventory.installReceiptHandler(self: any)
	MarketplaceService.ProcessReceipt = function(receipt: any)
		-- This is the only ProcessReceipt assignment in the experience.
		-- Never acknowledge a real receipt in an ephemeral test inventory.
		if self.Memory then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		local key: string? = nil
		for _, name in { "SoftSoles", "Padding" } do
			if
				Config.Catalog[name].ProductId > 0
				and Config.Catalog[name].ProductId == receipt.ProductId
			then
				key = name
			end
		end
		if not key then
			warn("DWH unknown product; receipt remains pending:", receipt.ProductId)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		local product = key :: string
		local purchaseId = tostring(receipt.PurchaseId)
		local ok, data = self:update(receipt.PlayerId, function(profile: any)
			Rules.grantReceipt(profile, purchaseId, product, Config.Catalog[product].Quantity)
		end)
		if ok and data.receipts[purchaseId] == true then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(
		function(player: Player, passId: number, _purchased: boolean)
			if passId == Config.Catalog.CrewPack.PassId then
				-- A dismissal is not ownership evidence; re-query the platform.
				task.spawn(function()
					self:refreshPass(player)
				end)
			end
		end
	)
end
return Inventory
