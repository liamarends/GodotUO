---
name: roblox-test
description: "Run or plan Roblox Studio Script Analysis, playtests, multi-client and device checks for a scoped change."
---

# roblox-test

Read docs/roblox-workflow.md and the acceptance criteria. Run only relevant checks.
1. Verify source formatting and Rojo build. Report these as static/assembly checks.
   Run `python roblox/tests/run.py` for the house game's receipt, inventory and
   activation regression cases; Luau and luau-compile must be on PATH. These use
   service doubles, not live purchases. Follow roblox/TESTING.md for game criteria.
2. If Studio is available, open the correct local/test place. Inspect Script Analysis
   and Output. Run Test; check both server and client views.
3. For replicated behavior, use Server & Clients with at least two clients.
   Check join/leave, respawn and player isolation when relevant.
4. For UI/input, use device emulation and the intended input methods.
   Persistence tests need a separate test experience; do not enable API access
   against a live experience just to make a test pass.
5. Record commit/place, Studio version, test mode/client count, steps, expected
   outcome, actual outcome and errors. Never treat a build as a playtest.
If Studio or a connector is unavailable, finish offline checks and provide the
specific manual checks still needed. Do not fabricate screenshots or run status.

Use the doctor and evidence helpers in docs/roblox-agent-kit.md. Real input should demonstrate the player path; fixture setup alone is not gameplay proof.
