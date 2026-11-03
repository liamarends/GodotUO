# Paste this into the agent working on my Roblox project

Adapt this kit to my existing Roblox project so you can build, run repeatable automated tests,
play the real game, record runs, inspect screenshots/video, fix failures, and deliver evidence like GUO does.
Read START-HERE.md first. Inspect my project and installed tools before choosing versions or changing structure.
Preserve existing files and Studio-authored content. Merge instructions; do not replace my AGENTS.md wholesale.

Work in these milestones:
1. Inventory Studio, source ownership, Rojo, test framework, agent UI/MCP capabilities, Python, FFmpeg/OBS,
   output locations and version control. Produce a doctor command and explain missing dependencies.
2. Prove an isolated build, the supplied Studio spawn test, an intentional failing assertion, and a timeout.
3. Connect an available trusted Studio automation integration, or implement the bounded plugin adapter described
   in guides/05-automation-contract.md. Never pretend ordinary Luau scripts have plugin-only permissions.
4. Implement one real game scenario through player input, assert the authoritative result, capture the run,
   and inspect the resulting recording. Keep direct state mutation confined to fixture setup.
5. Add two-player, respawn/reset, mobile input/layout, and a five-minute soak test as applicable.
6. Deliver working local launchers and a capability checklist with evidence and honest remaining gaps.

Use tests to prove behavior, not just script execution. Repeat after fixes; keep the failing evidence too.
Use bounded waits, per-run IDs and machine-readable outcomes. A skipped/missing visual or multiplayer test
must remain skipped/missing. Do not claim the whole game works from the scaffold's spawn test.
Keep generated outputs outside the checkout and secrets out of logs. Use private test places and mock data.
Do not publish, spend Robux, change production data, or send messages to anyone unless I authorize that action.
If Studio sign-in, installation, or a missing tool needs me, report that exact dependency while completing
independent work. Do not ask permission again for reversible local work I already requested.
