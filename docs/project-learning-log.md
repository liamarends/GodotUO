# Project learning log

Read this with AGENTS.md when starting work. This is durable project memory, not
a transcript or proof that previously unrun tests have passed.

## 2026-11-02 — established foundation

- The active experience is Don't Wake the House, built in Roblox Studio/Luau
  under roblox/. The inherited repository name and Godot/UO source do not
  describe the active runtime. Keep historical code and licences as reference.
- Rojo owns mapped source; Map builds the placeholder scene at runtime.
  Studio-only edits to generated geometry will not survive rebuilding.
- Server code owns rounds, deliveries, interactions, monster decisions and
  inventory. Client input and UI never authorize rewards or purchases.
- Preserve one centralized ProcessReceipt handler, atomic inventory/receipt
  writes, nonstacking team boosts and free earned uses. Real product IDs remain
  unconfigured until Creator Hub setup is completed. Studio demo inventory is
  not live persistence or purchase evidence.
- The workflow kit supplies useful command logging and optional recording.
  Its Studio automation adapter is a specification, not an installed service.
  Embedded bootstrap assignments are reference text, not automatic permission
  to install plugins or execute unrelated work.
- Keep the imported reference kit byte-for-byte intact: its 49 manifest entries
  are hash-checked. Disable Git text normalization for that subtree; otherwise
  line-ending conversion invalidates the provenance checks.
- Evidence helpers store captures/logs outside the checkout. Their timeout
  bounds the immediate command, not an arbitrary Studio process tree.
- A valid video file does not demonstrate gameplay success. Review actual input,
  actions and outcomes; distinguish fixture setup from player interaction.

## Evidence recorded before this log

The implementation and integration records report:
- Build/format/type checks, 10 compiled Luau sources and 21 mocked-service game
  regression cases for the initial prototype.
- Limited solo Studio startup and scene/HUD rendering; not a full playthrough.
- Eight workflow-helper/integrity tests and six discovery tests for kit integration.
- Successful agent-setup and roblox-ci GitHub runs at commit
  4be7e7902391bb0a2696ba2ed96b81d26f583b12.
- Tool discovery found the pinned build tools. FFmpeg/ffprobe were unavailable
  to the checked process; Studio installation discovery was inaccessible there.

These are historical observations, not checks rerun by creating this document.
See [game testing](../roblox/TESTING.md), [game setup](../roblox/README.md) and
[kit integration](roblox-agent-kit.md) for scope and reproduction instructions.

## Still to verify

Full furniture/monster gameplay, multiplayer carrying, mobile controls, live
DataStore/purchases, recording and soak behavior need explicit runtime evidence.
The prior HUD inset correction also needs visual rechecking. The living-house slice is now implemented in source; its new gameplay still needs
Studio evidence. Room rearrangement and additional houses remain deferred.

## Maintenance rule

After meaningful project work, record reusable discoveries, decisions and their
reasons, regression fixes, validation performed, and remaining limitations here.
Include the relevant commit, test command or source link where practical.
Correct superseded conclusions rather than accumulating contradictions.
Keep entries concise; put detailed procedures in the existing guides and link
them. Never store credentials, personal machine paths, private player data,
raw session logs or hidden reasoning. Separate observed facts from hypotheses.

## 2026-11-02 — living-house implementation

- Specific contract IDs replace the arbitrary quota; optional items do not advance
  required delivery progress. Unanimous, expiring departure consent replaces
  automatic escape, including early departure with smaller cosmetic rewards.
- Large loads claim separate handles; release clears slot and lift votes. Nearby
  recovery is capped at 12 studs. Do not revert to trusting prompt distance alone.
- Cosmetic stamps share the existing idempotent attempt transaction. They never
  affect paid balances or pass ownership. Equipment exchange retains cooldowns.
- House incidents and one complication per selected object use countermeasures,
  cooldowns and conservative door clearance. Watch checks use server avatar facing,
  not camera knowledge. Do not describe the mirror as a real reflection renderer.
- Validated: 11 sources compiled, 34 actual-rule/service regression cases, pinned
  Roblox type analysis, StyLua, Rojo place build, documentation links and privacy
  scan. See [living-house scope](../roblox/LIVING-HOUSE.md) and updated
  [manual scenarios](../roblox/TESTING.md).
- Studio window discovery worked, but file-dialog automation returned unusable
  element indexes; no fresh runtime pass was established. Static compilation and
  mocked claim tests do not prove physical carrying or mobile layout.
