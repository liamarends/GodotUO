# What to preserve and what to replace

| GUO practice | Roblox implementation |
|---|---|
| C# build and Godot import | Rojo place build if the project uses Rojo; Luau lint/type checks and actual Studio load |
| GUO MCP state/input/screenshot | Trusted Studio integration or local plugin adapter with explicit capabilities |
| Scenario JSON + observable expectations | Engine-neutral steps, Roblox adapter, server and client assertions |
| Shard + several clients | Studio server/client tests; isolated test data, one controller per instance |
| Godot MovieWriter | Real-time Studio-window capture; record wall time, dropped frames and capture overhead |
| Screenshot parity | Approved Roblox visual baselines at fixed viewport/camera/lighting; inspect differences |
| Endurance probe | Repeated gameplay cycles; compare warmed-up memory/frame time and connection/instance trends |
| Doctor and launcher pairs | Local doctor/build/test/play/record commands, with documented prerequisites and exit codes |
| Evidence + handoff | Run manifest, step log, raw output, stills/video and reproduction instructions |

GUO's original capture.py implements MovieWriter and transcoding. Its README also describes future OBS work.
Do not treat those design examples as tested implementations. The bridge is coupled to GUO protocol and input.
Keep its separation of concerns, timeout behavior and observation-based checks; replace its engine calls.

Start with a vertical slice: spawn → move → interact → server changes state → UI updates → respawn.
Build a small dependable loop before creating a large command catalog. Store generated art with provenance;
verify asset rights and Roblox asset permissions. A local asset preview does not prove it loads for players.
