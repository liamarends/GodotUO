# Don't Wake the House

A complete first-prototype implementation for Roblox Studio: 1–4 movers, seven
minutes, twelve labeled furniture pieces, a two-story house, a moving truck and
one original blanket monster, **The Duvet**. Everything is made from Roblox parts.
There are no downloaded models, paid map assets, invented asset IDs or microphone inputs.

## Open and play

Open `DontWakeTheHouse.rbxlx` in Roblox Studio and press **Play**. The server builds
the map at startup; an empty scene before Play is expected. Click **CLOCK IN**.
The default Studio demo has three temporary uses of each boost and the cosmetic
pack unlocked. It never contacts a DataStore or opens a Robux purchase prompt.

If building from source, install the pinned Rojo executable listed in
[tool-versions.json](tool-versions.json), create `build/` in the repository root,
and run from that root:

```text
rojo build roblox/default.project.json -o build/dont-wake-the-house.rbxlx
```

Open the generated file. For source-folder ZIP users, the ZIP has a `roblox/`
folder: run the same command from its parent. No Rojo plugin is needed to open
the built place. For live editing, `rojo serve roblox/default.project.json` and
the matching Studio plugin are optional; inspect the sync diff first.

To preview the generated house while editing, run this in Studio's **Command Bar**:

```lua
local Map = require(game.ServerScriptService.Server.Map)
Map.furniture(Map.build())
```

Play creates a fresh map again. Edit `Map.luau` to make permanent map changes;
hand edits to generated parts are replaced at the next server start.

## Controls and first shift

| Action | Keyboard/mouse | Touch |
|---|---|---|
| Move / look | WASD / mouse | Roblox thumbstick / drag view |
| Pick up, join a large load, hide, rescue | E at the object | Tap its proximity prompt |
| Rotate carried furniture | R / T | Turn buttons |
| Put down | G | Put down button |
| Sprint | Hold Shift | Toggle Walk / Sprint |
| Warm flashlight | F | Light button |
| Leave wardrobe | H or wardrobe E | Leave hide button |
| Checklist / shop | C / B | Checklist / Supplies buttons |

The checklist assigns **4 / 6 / 8 / 10 particular objects** for 1 / 2 / 3 / 4
starting players. Required objects have CONTRACT labels; optional keepsakes reveal
short family stories and earn cosmetic stamps. The first contract favors downstairs
items; subsequent contracts shuffle assignments. Each loaded object counts once.

Small pieces use one carrier. Large pieces have two orange grab handles: stand at
opposite ends, move together, use R/T to turn, and both toggle U to lift. A lone
mover drags slowly; the free dolly improves solo dragging but cannot lift. G sets a
load down carefully; sprint intent makes a drop louder. J recovers a stuck load to
its last nearby clear position. A disconnect releases that mover's claim; the last
remaining mover can drag alone. Late joiners wait for the next round.

Use **Tools [X]** for Hold / Turn / Put down pings (also Z / N / M), free equipment
exchange at the truck, departure, and accessibility settings. V uses a decoy or
wedge. Decoys have a 35s cooldown and lose to a visible target; wedges keep doors
open for 45s. Exchanging equipment preserves cooldowns. Flashlights are always free.

**Departure is explicit:** everyone must be upright, aboard, and approve DEPART in
Tools within 12 seconds. Tap again to cancel; stepping off revokes consent. Leaving
early is allowed with fewer cosmetic stamps. The starting quota does not increase
when people join or drop when they disconnect. Set the experience maximum to four.

See [the living-house update](LIVING-HOUSE.md) for object countermeasures, new
controls, design scope, and the verification boundary.

Walking is quiet; sprinting, dropping loads and bumping walls raise shared noise.
At 35 noise it is Stirring, at 70 Searching, with spaced knocks, portraits and local light failures. At
100, The Duvet hunts for 32 seconds. Break its sight before entering a wardrobe.
Its reach warning gives 1.15 seconds to move away. A caught mover is downed;
an unencumbered teammate can help by remaining within reach for three seconds.
A solo mover gets two automatic recoveries, each after nine seconds. Recovery
provides five seconds to get clear. The third solo capture, a fully downed team,
or an expired seven-minute clock loses the attempt. Retry after the result screen
for free. There is no gore, health damage purchase, shop pressure or death prompt.

## Runnable stages and balance

Set `Stage` in [src/shared/GameConfig.luau](src/shared/GameConfig.luau), then rebuild:

1. **Stage 1:** carrying, rotating, deliveries, count scaling, escape and reset;
   noise and hunts are off, shop hidden. Test furniture before adding pressure.
2. **Stage 2:** adds noise, atmosphere, monster, hiding, downing and recovery.
3. **Stage 3 (default):** complete round loop, HUD, shop, saved inventory, free
   attempt rewards, optional team boost and cosmetics.

All speed, round, rescue, hunt, participation, price-intent, ID and boost values
are in `GameConfig`. Stages are development switches, never paid content.
The full build is the deliverable; the two earlier-stage place files are useful
for isolated Studio checks. Shops, saving and cosmetics are implemented here
because the expanded brief explicitly requests them. No leaderboards, checkpoints,
additional maps or monsters are included. If a leaderboard is added, separate
boosted and unboosted times. The generic cart/checkpoint rule does not apply to
this house prototype; each boost covers exactly one moving round.

## Exact Explorer hierarchy

All ten executable source files are included. There is no pseudocode or required
manual script transcription. With Rojo, folder entry files become the named
Script/LocalScript below, with sibling modules as their children.

```text
ReplicatedStorage
  Shared (Folder)
    GameConfig (ModuleScript) <- src/shared/GameConfig.luau
    Rules (ModuleScript)      <- src/shared/Rules.luau
  HouseRemotes (runtime Folder)
    Action (RemoteEvent)
    Update (RemoteEvent)
ServerScriptService
  Server (Script)             <- src/server/init.server.luau
    Map (ModuleScript)        <- src/server/Map.luau
    Furniture (ModuleScript)  <- src/server/Furniture.luau
    Monster (ModuleScript)    <- src/server/Monster.luau
    Game (ModuleScript)       <- src/server/Game.luau
    Inventory (ModuleScript)  <- src/server/Inventory.luau
    Cosmetics (ModuleScript)  <- src/server/Cosmetics.luau
StarterPlayer
  StarterPlayerScripts
    Client (LocalScript)      <- src/client/init.client.luau
Workspace
  HauntedHouse (runtime Folder)
    WallsAndCover (Folder)
    WalkableSurfaces (Folder)
    Furniture (Folder; 12 Models, CarryBounds + prompt + detail parts)
    LoadedCargo (Folder)
    CrewSpawn (SpawnLocation)
    DeliveryZone (Part, invisible)
    The Duvet (Model; Humanoid, server-owned root, welded part body)
    ...wardrobes, fixtures, signs and truck decoration
Players/<player>/PlayerGui
  MovingCompanyHUD (runtime ScreenGui)
    Header, Message, Checklist, Shop, CarryControls and action buttons
```

For manual installation in a **new empty place**, create the non-runtime tree
exactly, paste each complete source file into its corresponding object, and leave
the server Script's RunContext at Legacy/default. Remove the template baseplate
and spawn so the generated map is the only scene. No remote objects, map models,
plugins, HTTP setting or API access setting is needed for the Studio demo.

## Fair shop and free rewards

| Catalog entry | Intended Creator Hub price | What a purchase grants |
|---|---:|---|
| Soft Soles | 10 Robux | 3 saved uses; each reduces **team footsteps only** by 10% for one round |
| Furniture Padding | 15 Robux | 3 saved uses; each reduces **team bumps and drops only** by 10% for one round |
| Moving Crew Pack | 49 Robux | Permanent branded orange/teal/plum uniforms, three equal-brightness flashlight colors and optional supporter tag |

The actual in-game storefront price comes from the local player's
`MarketplaceService:GetProductInfoAsync`, including regional/personalized prices.
The table above is setup intent, never a hard-coded purchase price. Zero IDs or a
failed price lookup disable purchase buttons. The normal Roblox confirmation
opens only after an intentional Buy click in the safe lobby.

Buying adds inventory; it never selects a boost. A supplier voluntarily reserves
the team's single slot in the lobby/countdown. First server-accepted selection
wins; competing selections spend nothing. Only its supplier can cancel it.
Exactly one use is consumed at gameplay start, the effect benefits everyone,
and strength never stacks. HUD/shop show supplier, effect, stock and free reward
progress. Inventory combines purchased and earned uses; unused uses never expire.

After every two completed qualifying attempts, win or loss, a player earns one
use of their chosen boost. A qualifying attempt requires **45 seconds actually
moving** and **12 seconds carrying while moving, one delivery, or one rescue**.
Idle lobby time, spectating, unfinished disconnects and standing still do not
qualify. The selected free reward is saved; choose it in Supplies. Completed
attempt IDs prevent repeated awards. All equipment, maps and retries stay free.

## Account setup you must complete

Real Roblox account/experience/product/pass IDs have not been provided, and this
project has **not been published to Roblox**. Complete the following under the
account or group that will own this experience, initially in a separate test
experience:

1. Sign into Studio. Open the place and use **File → Publish to Roblox As** to
   create the test experience. Configure its name, supported devices and access;
   use **Creator Hub → Creations → your experience → Places** to set its starting
   place's maximum server size to **4**. Use R15 or R6 avatars; both are supported
   by the procedural clothing code. Finish Roblox's required audience/access
   settings before inviting testers.
2. In that experience's **Monetization → Developer Products**, create **Soft
   Soles — 3 uses**, describe the exact team effect above, set the starting price
   to **10 Robux**, and save. Create **Furniture Padding — 3 uses** at **15 Robux**.
   Copy each **developer product ID**, not the experience ID or an image ID.
   Put them into `Catalog.SoftSoles.ProductId` and `Catalog.Padding.ProductId`.
   See [Roblox developer products](https://create.roblox.com/docs/production/monetization/developer-products).
3. Under **Monetization → Passes**, create **Moving Crew Pack**, upload an icon
   you own (a screenshot of this original truck is sufficient), and describe the
   cosmetic-only benefit. Open its Sales settings, enable it for sale, set the
   starting price to **49 Robux**, and save. Copy its **Asset ID/pass ID** into
   `Catalog.CrewPack.PassId`. This is a game pass, not a developer product.
   See [Roblox passes](https://create.roblox.com/docs/production/monetization/passes).
4. Keep the products/pass owned by and associated with this same experience.
   Rebuild/republish its place after inserting IDs. Set `Stage = 3`.
   Leave prices to Roblox; verify the price shown by Supplies matches the prompt,
   using Creator Hub's **Dynamic Price Check** if enabling managed pricing.
   See [regional price display](https://create.roblox.com/docs/production/monetization/regional-pricing).
5. For **persistent Studio tests only**, set `StudioMemoryMode = false` in the
   separate test experience, use a distinct `StoreName` such as
   `DWH_Inventory_Test_v1`, and enable **Game Settings → Security → Enable Studio
   Access to API Services**. Never point an outage test at live player data.
   Published servers always use real DataStores even if StudioMemoryMode is true.
   See [DataStore access](https://create.roblox.com/docs/cloud-services/data-stores).
6. Run [TESTING.md](TESTING.md). Validate actual purchases in a controlled published
   test environment before selling to players; real purchase prompts may spend
   Robux. Studio demo stock is temporary, has no cash value and is never migrated
   into purchased inventory. Disable the demo flag for production maintenance
   clarity, although the server already requires `RunService:IsStudio()`.

No Roblox credentials belong in this repository. No auto-publishing workflow is
configured. Creating products, setting their prices, publishing the experience,
and completing account access requirements remain account-owner tasks.

## Implementation and failure behavior

`Game` owns phase, seven-minute deadline, starting roster/quota, participation,
rescue, noise and the single boost slot. `Furniture` accepts nearby unobstructed
claims without yielding, caps carrier counts and moves anchored Models on the
server with swept wall tests, overlap checks and floor support. Clients send
bounded intent only, never item poses, delivery awards or noise amounts. Bump
and drop noise share an item cooldown. Leaving a carrier releases the claim;
the remaining solo mover can drag. Respawn does not clear a downed state.

`Monster` uses server pathfinding, noise investigation, sight rays and a delayed
attack with a second sight/distance check. `Map` uses original parts and the engine's
bundled `action_footsteps_plastic.mp3`, `action_get_up.mp3`, and
`action_jump_land.mp3` for stylized ambient/bump audio. No numeric audio asset IDs
are used. All flashlights share brightness, range and cone settings.

`Inventory` is the only owner of `ProcessReceipt`. One `UpdateAsync` stores the
receipt ID and its grant together in the user's profile; acknowledgments happen
only after that write returns successfully. Replays, concurrent server retries,
and a lost response after commit cannot double-grant. Unknown products and failed
writes return `NotProcessedYet`. Keep retired product IDs handled if you ever
replace this catalog. There is no client purchase-grant remote or product-prompt
dismissal grant. Pass prompts trigger a fresh server ownership lookup.

All mutations are write-through against the latest durable record; there is no
stale whole-profile save at disconnect. Same-server operations serialize; datastore
transforms do not yield. Failed/unknown schemas are never overwritten with defaults.
An idempotent round activation marker prevents double spending. A pending start
has a 540-second recovery lease: an unconfirmed start is refunded at the next
inventory transaction after expiry. Confirming a started round removes that
lease. This favors refunding an uncertain start over losing a paid use. Regular
unused uses have no expiry. A completed activation is consumed even if its
supplier disconnects during that round; the whole team's benefit continues.

Completed free reward writes retry with backoff while the server lives, with up
to 25 seconds to finish on shutdown. If Roblox storage is unavailable until a
server is terminated, an attempt that never reached storage cannot be recovered
from memory; already saved inventory and processed receipts remain protected.
Receipt history is intentionally not pruned. Before long-term production scale,
monitor datastore record size and design a migration before its platform limit;
do not delete purchase IDs to reduce size. This prototype includes no live support
dashboard, trading, gifting or cross-experience economy.

## Verification boundary

The accompanying [test record/checklist](TESTING.md) distinguishes executed static
and mocked-service checks from unrun Studio and live platform checks. A compiled
place is not evidence of a Studio playtest. Open Output and Script Analysis,
test solo and multiplayer, and tune the placeholder geometry/AI if Studio reveals
navigation or camera issues before public release.
