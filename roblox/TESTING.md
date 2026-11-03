# Don't Wake the House — verification

## Checks actually run

### Latest Studio UI check — November 2, 2026

Tested the living-house revision `53a3084` plus the UI repairs in this change,
using local generated places, one Studio client and Studio-memory inventory.
Observed lobby rendering, countdown and running round timer, checklist/tools
panels and incident subtitles. Inspected Output in the first session: server
ready, no runtime errors shown. Reopened the corrected place and visually
confirmed the required-item checklist heading and readable Left/Right controls.
The HUD no longer overlaps the Roblox menu in the observed desktop viewports.

In the second session, opened the supply desk and offered Soft Soles: inventory
remained at three. Starting the round activated the named team boost and reduced
only Soft Soles to two; Padding remained three. Shop displayed Studio demo/no
purchase controls. These observations do not test Robux purchases or persistence.

Recompiled 11 files, passed 34 mocked regression cases, formatting and Rojo build.
Sustained movement input could not be driven reliably by the Windows controller;
no delivery, monster encounter, complete round, replay, multiplayer or mobile
pass is claimed. Studio Script Analysis was not inspected in this session.

### Earlier prototype checks

- All 10 shipped Luau files compiled with the official **Luau 0.745** compiler.
- **21 regression cases passed**, executing shipped Rules, Inventory and Game
  code with deterministic service doubles: duplicate/cross-server receipts,
  failed saves, lost write responses, UpdateAsync callback replay, unknown IDs,
  disconnected grants, load/schema failures, rejoining, single consumption,
  refunds/crash recovery, free rewards, meaningful participation, exact 10%
  category filtering, server pass checks, isolated Studio mode, selection races,
  supplier disconnect/cancellation and purchase-without-activation behavior.
- Roblox-aware offline type analysis with **luau-lsp 1.70.1**, a Rojo sourcemap
  and its pinned Roblox definitions. This is not Studio Script Analysis.
- **StyLua 2.6.0** formatting/parse checks and **Rojo 7.7.1** place assembly.
- Generated place XML inspected for the expected Script/LocalScript/ModuleScript
  hierarchy. No external asset IDs are required; all three purchase IDs are zero.
- **Studio startup smoke check:** opened the generated local place and started
  one client in Studio **0.745.449.7450003** on November 2, 2026 (local date).
  Observed the generated house/truck, lit rooms/stairs, avatar and running HUD
  with Studio demo balances. This checks startup/rendering, not a completed round.
  A HUD overlap with Roblox's top bar was found and corrected in source using
  CoreUISafeInsets and hiding the duplicate player list; the updated build still
  needs a visual recheck. The running Studio window was left available to the user.

Run compilation and the regression suite from the repository root:

```text
python roblox/tests/run.py --luau PATH_TO_LUAU --compiler PATH_TO_LUAU_COMPILE
stylua --check --config-path roblox/stylua.toml roblox/src
rojo build roblox/default.project.json -o build/dont-wake-the-house.rbxlx
```

With tools on PATH, `python roblox/tests/run.py` is sufficient. Tests insert the
actual source into an isolated harness; they do not reproduce a second purchase
implementation. Source files remain unchanged by the harness. Generated test
files live in ignored `build/`. The CI workflow repeats these checks on Windows
and Linux and provides the assembled place as a build artifact.

## Full Studio checks you need to run — not run here

Open the supplied place, open **Output** and **Script Analysis**, and press Play.
Use **Test → Server & Clients** for multiplayer and the device emulator for touch.
Record Studio version, source commit, client count, steps, observed result and
Output errors. The following are required before calling this playtested:

| Check | Steps and expected result |
|---|---|
| Solo carrying | Stage 1, one client. Start outside; target is 4. Carry/turn/drop a lamp, chair and box. Drag a sofa slowly. Walk through the front door and both stair directions. No fling, wall penetration or detached visual parts. |
| Delivery once | Bring one object fully into the bay. Counter increases by exactly one and a cargo crate appears. Revisit/touch the bay, spam prompts/drop and wait: no additional credit for that object. |
| Two movers | Stage 1, two clients; target 6. A large object stays still with one carrier. Second joins; first steers/rotates, second follows. Separate too far: movement stops or the distant claim releases. Small items reject a second claimant. |
| Four movers | Four clients; target 10. Two independent teams carry large objects while two claim the same small object. No duplicate claims/credits; all clients see the same furniture and shared meter. |
| Distance/rate checks | Try a prompt from beyond 9 studs or through a wall, including a locally modified prompt range. No pickup. Press rotate/drop rapidly against a wall: bump noise is limited to once per item per 1.4 seconds. |
| Noise/atmosphere | Stage 2/3. Walking alone decays toward quiet. Sprinting is louder. Drop and bump increase noise. At 40+, creaks/steps/flicker. Stop moving: noise declines. No microphone permission is requested. |
| Monster | Reach 100 noise. Hunt begins. It navigates from upstairs, investigates a noisy room, sees/chases movers, and warns before grabbing. Dodge during the warning. Go behind a wall and enter a wardrobe; hiding while seen is rejected. Hunt ends after 32 seconds. |
| Rescue | Two clients: let one be caught. It freezes with a rescue prompt. Other player puts down furniture, starts rescue and stays close for 3 seconds. Walking away cancels. A wall blocks the rescue. Revived player has five seconds to get clear. |
| Solo recovery/defeat | One client: first two catches recover after 9 seconds; third ends the round. Reset is disabled; forcibly respawning in a test must preserve downed status. |
| Disconnect | Disconnect either carrier. Object is released safely; no stale claim. If one mover remains, large furniture allows slow dragging. A selected supplier leaving before start spends nothing; an already active boost remains for the team. |
| Late join | Join during a hunt. Wait outside without changing the quota or earning attempt credit; participate normally next round. |
| Win | Deliver the quota and leave one upright mover outside the truck: no win yet. Bring everyone aboard: victory exactly once, results, then fresh lobby. |
| Lose | Temporarily shorten RoundSeconds in a test copy to exercise timeout, then restore 420. Also down all multiplayer movers. Results should give a clear reason and a free retry. |
| Replay | Complete three rounds, including win and loss. Fresh furniture, cargo, timers, noise, hiding slots and monster each time. No duplicate prompts/HUD, stale carriers or extra reward credits. |
| Touch/viewport | Test phone portrait and landscape plus tablet. Default movement stays usable. Tap prompts, turn/drop/sprint/light, scroll shop, change reward, close shop. No clipped prices or unreachable buttons. Verify on a real phone before release. |

## Shop and persistence checks you need to run

The default Studio demo needs no account configuration. Persistence and normal
Robux confirmation checks require the **separate test experience and real IDs**
described in [README.md](README.md). Demo balances reset when its server stops.

| Check | Steps and expected result |
|---|---|
| Zero IDs | Default IDs=0. Live purchase buttons are disabled; Studio clearly says demo/no Robux. The free core game still runs. |
| Canceled purchase | With real test IDs and persistent mode, note stock, intentionally click Buy, then cancel Roblox's prompt. Stock/selection/progress remain unchanged. Repeat for the pass; it stays unowned. Never prompt automatically on capture or timeout. |
| Successful product | Complete one intentional product purchase. Exactly 3 uses appear after the server receipt is durably saved. Nothing activates until you offer one use and start. Rejoin a different server: stock persists. |
| Duplicate receipt | Run the regression suite's duplicate, cross-server, replay and ambiguous-write cases; already executed offline. For platform integration, observe a genuine retried receipt in the test environment and verify the same PurchaseId remains a single grant. Never forge receipts against production data. |
| Failed save/load | Run the injected failure cases in the regression suite; already executed offline. In a separate Studio test place with persistent mode, disable API access and restart. Purchases/boosts wait for a successful load, gameplay remains available, and existing saved records must not become zero defaults. Restore access and refresh. |
| Disconnect during purchase | In a controlled test, leave after an intentional purchase confirmation. Rejoin and let Roblox retry pending receipts. Stock is 3 once, never 6. The offline disconnected-grant case already passes. |
| Simultaneous offers | Two clients each have uses. Offer different boosts at nearly the same time. One supplier is displayed. Canceling from the other client does nothing. Start: only winner loses 1; effect is shared and exactly 10%, never 20%. |
| Activation save outage | Use the offline failed/ambiguous-save and refund tests. In the isolated persistent test, interrupt storage before start. No unconfirmed boost is announced as active. Refresh after recovery: any aborted reservation is refunded once. |
| Free reward | Select Padding. Complete one qualifying loss and one qualifying win; stock gains one Padding, progress resets to 0/2. Standing idle or disconnecting before completion earns nothing. Rejoining keeps stock and progress. |
| Owned pass | Use an owning and non-owning test account. Only the owner can persist/apply three uniforms, three light colors and supporter tag. Light brightness/range/cone remain identical. Rejoin/respawn: selection persists and ownership is checked again on the server. |
| Price accuracy | Compare each displayed Robux price with the Roblox confirmation. Exercise Dynamic Price Check for managed pricing. Failed price lookup disables Buy instead of showing 10/15/49 as a fallback. |
| Full free run | A non-paying account completes the whole map, recovers/rescues, wins, loses and retries without buying anything. |

Beyond the limited startup observation above, no complete gameplay/physics test,
multiplayer session, mobile device test, real DataStore
transaction, actual purchase, real owned-pass check or Roblox publication was
performed during implementation. The offline tests demonstrate logic under
mocks; they do not establish platform integration or game feel.

## Living-house update validation (2026-11-02)

Implemented source: [LIVING-HOUSE.md](LIVING-HOUSE.md). All 11 shipped Luau files
compile; 34 offline regression cases pass. New cases execute the actual Furniture
pickup/release/lift/bump methods against controlled world doubles, plus departure
validation, awareness/assignment rules, earned badge authorization and atomic
reward retries. Existing receipt, free-use, concurrent activation and inventory
cases continue to pass. Roblox-aware type analysis, StyLua and Rojo assembly pass.
These are code/build checks, not physics, replication, player-path or live-sale proof.

Studio was found and restored. Its file dialog repeatedly returned stale/unavailable
UI element indexes; attempts to open the generated place did not produce a verified
new play session. No fresh Studio, recording, audio-quality, touch or multiplayer
PASS is claimed for this update. Earlier startup observations above apply only to
the earlier revision. No real products were purchased or created.

Required manual checks in the new build:

1. Solo: clock in, read exact CONTRACT labels, carry/turn/lift/set down, deliver an
   optional keepsake without increasing required count; try dolly and stuck recovery.
2. Two clients: claim opposite handles simultaneously, reject a third claim, turn
   through a door, require both lift votes, disconnect one carrier, then solo drag.
3. Four clients: ten named objectives, two optional keepsakes, clear mobile controls,
   departure requires all four approvals; stepping out cancels that mover's vote.
4. House: walk both floor routes; induce 35/70/100 awareness, local darkness and
   doors; make sure doors never push/trap a player or furniture. Wedge, reopen,
   and verify the 45s expiration. Check decoy cooldown survives equipment swaps.
5. Each complication: replay until selected, read its hint, trigger it after 40s,
   use its countermeasure. No watched-object return; no carried/delivered return.
6. Pursuer: hear/see warning, break sight, hide, rescue, use solo recoveries; verify
   quiet breathing room after a hunt and nearby mirror warning. Never test by
   teleporting the player and call that real-input proof.
7. Win with required items and unanimous departure; leave early with fewer stamps;
   lose on timer/downed team; replay and inspect clean slots, votes, doors, lights,
   furniture, inventories and no duplicate event subscriptions.
8. Shop: canceled prompts grant nothing; repeated receipts grant once; failed and
   ambiguous saves remain retryable; pass ownership is server-checked. Rejoin in a
   separate published test experience to verify uses, stamps and badge persist.
9. Accessibility: phone portrait/landscape, subtitles/direction cues, brightness,
   shake OFF/LOW/FULL, wardrobe/help prompts and tool scrolling. Check audio and
   frame cost on target mobile hardware. No performance measurements exist yet.

## Vale house environment audit (2026-11-03 UTC)

Implemented original procedural furniture, family-house dressing, kitchen/utility
wing, cellar, sealed family room, garden return route, truck detail, animated
quilted pursuer, positional ambience and reduced-flashing control. See ENVIRONMENT.md.

Executed checks:
- All 14 shipped Luau files compile; all 35 mocked regression cases pass.
- Roblox-aware static analysis, StyLua, Rojo build and whitespace checks pass.
- Workflow helper tests: 8 pass. Agent-skill tests: 6 pass. Privacy scan clean.
- Studio 0.745 solo engine fixture: 37 checks pass, zero assertion failures.
  Covers twelve spawn bounds and sampled swept delivery routes, five real engine
  pathfinding requests, range rejection, pickup/release, delivery deduplication,
  boost consumption, hunt reset, timeout defeat, replay and contract departure.
  Scene count: 883 parts and five shadow-casting environment lights.
- Earlier fixture runs exposed blocked upstairs routes and a real dropped-delivery
  bug. Widened/rearranged routes; delivery now checks fully contained dropped loads
  and credits their last carriers exactly once. Added an offline regression.
- That solo run emitted a test-only completion-marker error after its 37 checks;
  corrected world:SetAttribute to world.Folder:SetAttribute. No production code
  uses this marker. Multiplayer startup also exceeded the original 40-second
  fixture allowance; increased it to 180 seconds. Neither issue is hidden by the
  assertion totals.

These fixtures reposition avatars/items and shorten deadlines. They do not prove
natural carrying, chase fairness, real-input rounds, mobile usability or frame rate.
Real multiplayer/disconnect play, physical mobile performance, canceled purchases,
owned passes and cross-server live DataStore persistence still need the manual
checklist above. Existing mocked receipt/save checks are not live commerce tests.
Product IDs remain disabled; no Robux was spent and no live inventory was changed.

Legacy repository-wide docs lint has three existing missing-target findings
(localize skill, release workflow and workflow-helper README), outside this change.

Four-client attempt: Studio started a local server and client windows, but only
one client reached the fixture before its deadline. Opening the rebuilt fixture
then produced Studio's Low System Resources warning. Multiplayer is NOT passed.
The longer-startup harness and corrected completion marker are built/compiled;
those two harness edits have not yet received a complete engine rerun.
