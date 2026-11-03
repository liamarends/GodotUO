--!nocheck
-- Offline doubles exercise shipped code, not copied purchase implementations.
local tests = 0
local function test(name, callback)
	callback()
	tests += 1
	print("PASS " .. name)
end
local function clone(value)
	if type(value) ~= "table" then return value end
	local copy = {}
	for k, v in value do copy[k] = clone(v) end
	return copy
end
local Color3 = { fromRGB = function(r, g, b) return {r, g, b} end }
local Config = (function()
-- INSERT_CONFIG
end)()
-- Do not mutate the real frozen configuration. Only this harness uses fake IDs.
Config = clone(Config)
Config.Catalog.SoftSoles.ProductId = 101
Config.Catalog.Padding.ProductId = 102
Config.Catalog.CrewPack.PassId = 103
local Rules = (function()
-- INSERT_RULES
end)()
local stored, mode, owns, studio = {}, "ok", false, false
local updates = 0
local callbacks = {}
local store = {}
function store:UpdateAsync(key, callback)
	updates += 1
	if mode == "fail" then error("Injected storage outage") end
	local first = callback(clone(stored[key]))
	if mode == "replay" then first = callback(clone(stored[key])) end
	stored[key] = clone(first)
	if mode == "ambiguous" then error("Injected lost response after durable commit") end
	return clone(stored[key])
end
local playersById, roster = {}, {}
local Players = {}
function Players:GetPlayerByUserId(id) return playersById[id] end
function Players:GetPlayers() return roster end
local marketplace = { PromptGamePassPurchaseFinished = { Connect = function(_, cb) table.insert(callbacks, cb) end } }
function marketplace:UserOwnsGamePassAsync(_id, _pass) return owns end
local services = {
	DataStoreService = { GetDataStore = function() return store end },
	MarketplaceService = marketplace, Players = Players,
	RunService = { IsStudio = function() return studio end },
	ReplicatedStorage = { Shared = { GameConfig = "Config", Rules = "Rules" }, WaitForChild = function(self, key) return self[key] end },
	HttpService = { GenerateGUID = function() return "round-fixture" end }, PhysicsService = {},
}
local game = { GetService = function(_, name) assert(services[name], name); return services[name] end }
local script = { Parent = { Map = "Map", Furniture = "Furniture", Monster = "Monster", Inventory = "Inventory", Cosmetics = "Cosmetics", House = "House" } }
local loaded = { Config = Config, Rules = Rules, Map = {}, Furniture = {}, Monster = {}, Cosmetics = {}, House = {} }
local require = function(name) assert(loaded[name], name); return loaded[name] end
local Enum = { ProductPurchaseDecision = { PurchaseGranted = "granted", NotProcessedYet = "pending" } }
local task = { wait = function() end, spawn = function(fn) fn() end }
local CFrame = { new = function() return 0 end }
local warn = function(...) end -- Expected outage diagnostics are asserted through outcomes.
local Inventory = (function()
-- INSERT_INVENTORY
end)()
loaded.Inventory = Inventory
local Game = (function()
-- INSERT_GAME
end)()
local function inventory()
	local inv = Inventory.new(function() end)
	inv:installReceiptHandler()
	return inv
end
local function receipt(id, user, product)
	return { PurchaseId = id, PlayerId = user or 1, ProductId = product or 101 }
end

test("receipt grant is durable and duplicate-safe", function()
	inventory()
	assert(marketplace.ProcessReceipt(receipt("paid-1")) == "granted")
	assert(stored.u_1.uses.SoftSoles == 3 and stored.u_1.receipts["paid-1"])
	assert(marketplace.ProcessReceipt(receipt("paid-1")) == "granted")
	assert(stored.u_1.uses.SoftSoles == 3)
end)
test("another server retries the same receipt without a second grant", function()
	inventory()
	assert(marketplace.ProcessReceipt(receipt("paid-1")) == "granted")
	assert(stored.u_1.uses.SoftSoles == 3)
end)
test("failed save never acknowledges or grants a purchase", function()
	mode = "fail"
	assert(marketplace.ProcessReceipt(receipt("paid-fail")) == "pending")
	assert(not stored.u_1.receipts["paid-fail"] and stored.u_1.uses.SoftSoles == 3)
	mode = "ok"
	assert(marketplace.ProcessReceipt(receipt("paid-fail")) == "granted")
	assert(stored.u_1.uses.SoftSoles == 6)
end)
test("ambiguous save response retries without duplicating durable grant", function()
	mode = "ambiguous"
	assert(marketplace.ProcessReceipt(receipt("paid-ambiguous")) == "pending")
	assert(stored.u_1.uses.SoftSoles == 9)
	mode = "ok"
	assert(marketplace.ProcessReceipt(receipt("paid-ambiguous")) == "granted")
	assert(stored.u_1.uses.SoftSoles == 9)
end)
test("UpdateAsync callback replay grants only once", function()
	mode = "replay"
	assert(marketplace.ProcessReceipt(receipt("paid-replay")) == "granted")
	assert(stored.u_1.uses.SoftSoles == 12)
	mode = "ok"
end)
test("unknown product remains pending", function()
	assert(marketplace.ProcessReceipt(receipt("unknown", 1, 999)) == "pending")
	assert(not stored.u_1.receipts.unknown)
end)
test("receipt persists when buyer has disconnected", function()
	assert(playersById[77] == nil)
	assert(marketplace.ProcessReceipt(receipt("offline", 77, 102)) == "granted")
	assert(stored.u_77.uses.Padding == 3)
end)
test("load failure does not replace existing inventory with defaults", function()
	local inv = inventory()
	mode = "fail"
	local ok = inv:update(77, function() end)
	assert(not ok and inv.Cache[77] == nil and stored.u_77.uses.Padding == 3)
	mode = "ok"
end)
test("unsupported schema fails closed without overwriting data", function()
	stored.u_88 = { version = 999, sentinel = "keep" }
	assert(marketplace.ProcessReceipt(receipt("bad-schema", 88)) == "pending")
	assert(stored.u_88.sentinel == "keep")
end)
test("rejoin reads durable uses", function()
	local inv = inventory()
	assert(inv:update(77, function() end))
	assert(inv:snapshot({ UserId = 77 }).Uses.Padding == 3)
end)
test("round activation consumes exactly one and retries are idempotent", function()
	local inv = inventory()
	assert(inv:consume(77, "round-a", "Padding"))
	assert(inv:consume(77, "round-a", "Padding"))
	assert(stored.u_77.uses.Padding == 2)
	assert(not inv:consume(77, "round-a", "SoftSoles"))
	assert(inv:confirm(77, "round-a"))
	assert(stored.u_77.pending["round-a"] == nil)
end)
test("aborted activation refunds once", function()
	local inv = inventory()
	assert(inv:consume(77, "round-abort", "Padding"))
	assert(inv:refund(77, "round-abort", "Padding"))
	assert(inv:refund(77, "round-abort", "Padding"))
	assert(stored.u_77.uses.Padding == 2)
	assert(not inv:consume(77, "round-abort", "Padding"))
end)
test("expired unconfirmed start recovers its use after a crash", function()
	local inv = inventory()
	assert(inv:consume(77, "round-crash", "Padding"))
	stored.u_77.pending["round-crash"].expires = 0
	assert(inv:update(77, function() end))
	assert(stored.u_77.uses.Padding == 2 and stored.u_77.activations["round-crash"] == "Refunded")
end)
test("two meaningful completed attempts earn the selected free use", function()
	local inv = inventory()
	inv:choose({ UserId = 77 }, "SoftSoles")
	assert(inv:complete(77, "loss-1", true))
	assert(stored.u_77.progress == 1 and stored.u_77.uses.SoftSoles == 0)
	assert(inv:complete(77, "win-2", true))
	assert(stored.u_77.progress == 0 and stored.u_77.uses.SoftSoles == 1)
	assert(inv:complete(77, "win-2", true))
	assert(stored.u_77.progress == 0 and stored.u_77.uses.SoftSoles == 1)
end)
test("idle and incomplete attempts earn nothing", function()
	local inv = inventory()
	assert(inv:complete(77, "idle", false))
	assert(not stored.u_77.attempts.idle)
	assert(not Rules.meaningful(44, 100, 10, 1, 45, 12))
	assert(not Rules.meaningful(50, 11, 0, 0, 45, 12))
	assert(Rules.meaningful(45, 12, 0, 0, 45, 12))
	assert(Rules.meaningful(45, 0, 1, 0, 45, 12))
	assert(Rules.meaningful(45, 0, 0, 1, 45, 12))
end)
test("boosts affect only their category and only by ten percent", function()
	assert(Rules.noise(10, "Footstep", "SoftSoles", 0.1) == 9)
	assert(Rules.noise(10, "Furniture", "SoftSoles", 0.1) == 10)
	assert(Rules.noise(10, "Furniture", "Padding", 0.1) == 9)
	assert(Rules.noise(10, "Footstep", "Padding", 0.1) == 10)
	assert(Rules.noise(10, "Footstep", nil, 0) == 10)
end)
test("pass prompt dismissal and false purchase claims cannot grant ownership", function()
	local inv = inventory()
	local player = { UserId = 77 }
	callbacks[#callbacks](player, 103, true)
	assert(not inv.Owned[77])
	callbacks[#callbacks](player, 103, false)
	assert(not inv.Owned[77])
	owns = true
	inv:refreshPass(player)
	assert(inv.Owned[77])
	inv:cosmetic(player, "uniform", 2)
	assert(stored.u_77.uniform == 2)
	inv:cosmetic(player, "uniform", 0/0)
	assert(stored.u_77.uniform == 2)
end)
test("Studio demo is isolated and cannot acknowledge paid receipts", function()
	studio = true
	local inv = inventory()
	local before = updates
	inv:update(123, function() end)
	assert(inv.Cache[123].uses.SoftSoles == 3 and stored.u_123 == nil and updates == before)
	assert(marketplace.ProcessReceipt(receipt("demo", 123)) == "pending")
	studio = false
end)

-- Server activation arbitration uses the actual Game methods, with only world objects stubbed.
local function player(id)
	local p = { UserId = id, DisplayName = "Crew" .. id, Parent = Players, GetAttribute = function() return nil end, SetAttribute = function() end }
	p.Character = { PivotTo = function() end, FindFirstChild = function() return { Position = 0 } end, FindFirstChildOfClass = function() return { Health = 100 } end }
	playersById[id] = p
	return p
end
local first, second = player(1), player(77)
roster = { first, second }
local function round()
	local inv = inventory()
	inv:update(1, function() end)
	inv:update(77, function() end)
	local g = { Phase = "Lobby", Rates = {}, Inventory = inv, Participants = {}, HideCooldown = {},
		House = { reset = function() end }, World = { Spawn = 0 }, Furniture = { reset = function() end, release = function() end }, Monster = { reset = function() end },
		canShop = function() return true end, notify = function() end, announce = function() end,
		queueSave = function(_, _, operation) assert(operation()) end }
	return setmetatable(g, { __index = Game })
end
test("simultaneous selections reserve one slot without spending either inventory", function()
	local g = round()
	local a, b = stored.u_1.uses.SoftSoles, stored.u_77.uses.Padding
	g:action(first, "SelectBoost", "SoftSoles")
	g:action(second, "SelectBoost", "Padding")
	assert(g.Selected.UserId == 1)
	assert(stored.u_1.uses.SoftSoles == a and stored.u_77.uses.Padding == b)
	g.Phase = "Countdown"
	g:beginRound()
	assert(g.Phase == "Playing" and g.Boost.UserId == 1 and g.Required == 6)
	assert(stored.u_1.uses.SoftSoles == a - 1 and stored.u_77.uses.Padding == b)
end)
test("supplier disconnect before start clears selection without consumption", function()
	local g = round()
	local a = stored.u_1.uses.SoftSoles
	g:action(first, "SelectBoost", "SoftSoles")
	g:leave(first)
	assert(g.Selected == nil and stored.u_1.uses.SoftSoles == a)
end)
test("only supplier can cancel and purchases do not select boosts", function()
	local g = round()
	g:action(first, "SelectBoost", "SoftSoles")
	g:action(second, "SelectBoost", "None")
	assert(g.Selected.UserId == 1)
	g:action(first, "SelectBoost", "None")
	assert(g.Selected == nil)
	assert(marketplace.ProcessReceipt(receipt("buy-no-activate")) == "granted")
	assert(g.Selected == nil and g.Boost == nil)
end)
test("house awareness thresholds and hunt override are readable", function()
 assert(Rules.awareness(34,false)=="Asleep")
 assert(Rules.awareness(35,false)=="Stirring")
 assert(Rules.awareness(70,false)=="Searching")
 assert(Rules.awareness(0,true)=="Awake")
end)
test("contracts select specific unique IDs at each crew scale",function()
 for _, count in Config.DeliveryTargets do
  local selected=Rules.contract({12,11,10,9,8,7,6,5,4,3,2,1},count)
  local n=0;for _ in selected do n+=1 end
  assert(n==count and selected[12] and not selected[1])
 end
end)
test("departure requires every current mover aboard and consenting",function()
 assert(not Rules.departure(0,0,0))
 assert(not Rules.departure(2,1,2))
 assert(not Rules.departure(2,2,1))
 assert(Rules.departure(1,1,1) and Rules.departure(4,4,4))
end)
test("server departure votes reject distant and inactive movers and can cancel",function()
 local g=round();g.DepartVotes={};g.canAct=function() return true end
 loaded.Map.inTruck=function() return false end
 g:action(first,"Depart");assert(g.DepartVotes[first]==nil)
 loaded.Map.inTruck=function() return true end
 g:action(first,"Depart");assert(g.DepartVotes[first]>os.clock())
 g:action(first,"Depart");assert(g.DepartVotes[first]==nil)
 g.canAct=function() return false end
 g:action(first,"Depart");assert(g.DepartVotes[first]==nil)
end)
test("early departure and optional keepsakes give smaller cosmetic-only payouts",function()
 assert(Rules.reward(2,0,false)==2)
 assert(Rules.reward(2,1,false)==4)
 assert(Rules.reward(4,1,true)==10)
end)
test("cosmetic stamps share the attempt dedup transaction",function()
 local inv=inventory()
 local before=stored.u_77.mementos or 0
 assert(inv:complete(77,"stamps",true,14))
 assert(inv:complete(77,"stamps",true,14))
 assert(stored.u_77.mementos==before+14)
 inv.Owned[77]=false
 inv:cosmetic({UserId=77},"badge",true)
 assert(stored.u_77.badge==true)
 inv:cosmetic({UserId=77},"uniform",3)
 assert(stored.u_77.uniform~=3)
end)
test("earned badge cannot be equipped before earning stamps",function()
 local inv=inventory();inv:update(222,function() end)
 inv:cosmetic({UserId=222},"badge",true)
 assert(not stored.u_222.badge)
end)
test("failed cosmetic reward save is retryable without a duplicate",function()
 local inv=inventory();local before=stored.u_77.mementos
 mode="ambiguous";assert(not inv:complete(77,"stamps-outage",true,3));mode="ok"
 assert(inv:complete(77,"stamps-outage",true,3))
 assert(stored.u_77.mementos==before+3)
end)
local workspace={Raycast=function() return nil end}
local Furniture=(function()
-- INSERT_FURNITURE
end)()
local function point(x)
 return setmetatable({X=x}, {__sub=function(a,b) return {Magnitude=math.abs(a.X-b.X)} end})
end
local function carryFixture()
 local p={Character={FindFirstChild=function() return {Position=point(0)} end},SetAttribute=function() end}
 local q={Character={FindFirstChild=function() return {Position=point(0)} end},SetAttribute=function() end}
 local item={Large=true,Delivered=false,Root={Position=point(0)},Handles={},Slots={},Carriers={},Prompts={{},{}},LiftVotes={},BumpAt=0}
 local noises=0
 local g={Phase="Playing",canAct=function() return true end,crewCount=function() return 2 end,notify=function() end,addNoise=function() noises+=1 end,Participants={[p]={Equipment="Decoy"},[q]={Equipment="Wedge"}}}
 local f=setmetatable({Game=g,Carrying={}}, {__index=Furniture})
 return f,item,p,q,function() return noises end
end
test("two carriers claim distinct handles and cannot duplicate pickups",function()
 local f,item,p,q=carryFixture()
 f:pickup(p,item,1);f:pickup(p,item,2);f:pickup(q,item,1)
 assert(#item.Carriers==1)
 f:pickup(q,item,2);assert(#item.Carriers==2 and not item.Prompts[1].Enabled and not item.Prompts[2].Enabled)
end)
test("server rejects distant and obstructed furniture claims",function()
 local f,item,p=carryFixture();item.Root.Position=point(50)
 f:pickup(p,item,1);assert(#item.Carriers==0)
 item.Root.Position=point(0);workspace.Raycast=function() return true end
 f:pickup(p,item,1);assert(#item.Carriers==0)
 workspace.Raycast=function() return nil end
end)
test("release clears handle and lift readiness while preserving partner",function()
 local f,item,p,q=carryFixture();f:pickup(p,item,1);f:pickup(q,item,2)
 f:lift(p);assert(item.LiftVotes[p]);f:release(p,false)
 assert(f.Carrying[p]==nil and item.Slots[1]==nil and item.LiftVotes[p]==nil)
 assert(item.Carriers[1]==q and item.Prompts[1].Enabled)
end)
test("collision cooldown suppresses repeated noise events",function()
 local f,item,_,_,count=carryFixture()
 f:bump(item);f:bump(item);assert(count()==1)
end)
test("delivered objects cannot be claimed again",function()
 local f,item,p=carryFixture();item.Delivered=true;f:pickup(p,item,1)
 assert(#item.Carriers==0 and f.Carrying[p]==nil)
end)
test("a dropped truck load is credited once to its last carriers",function()
 local f,item,p=carryFixture()
 item.Size={X=3,Z=3};item.Id=1;item.LastCarriers={p};item.Model={PivotTo=function() end}
 local credited=0
 f.Game.delivered=function(_,object,carriers) assert(object==item and carriers[1]==p);credited+=1 end
 loaded.Map.inTruck=function() return false end
 assert(not f:tryDeliver(item) and credited==0)
 loaded.Map.inTruck=function() return true end
 assert(f:tryDeliver(item));assert(f:tryDeliver(item))
 assert(credited==1 and item.Delivered and #item.Carriers==0)
 loaded.Map.inTruck=function() return false end
end)
print(string.format("%d regression cases passed. Mock services only; Studio/live-platform checks remain required.", tests))
