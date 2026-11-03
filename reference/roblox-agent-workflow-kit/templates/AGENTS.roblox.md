# Project agent instructions — merge with existing rules

Goal: build a playable Roblox game with repeatable tests and reviewable recordings.
Use Luau and Roblox's client/server model. Keep server authority for rewards, inventory, damage and persistence.
Validate remote payloads, permissions and rate limits. Client UI success alone is not proof of a server change.

Before edits, read the design, architecture decisions and source ownership map. Use small focused changes.
Code changes belong in version control. Do not overwrite Studio-only maps/assets with a new Rojo tree.
Keep src/shared, src/server, src/client, tests, tools, launchers and docs responsibilities explicit.
Keep fixtures and automation hooks out of production builds; also guard Studio-only scripts with IsStudio().
One controller owns each Studio instance. Use separate ports/output folders for concurrent runs.

For each feature: write acceptance criteria, implement, build, run targeted logic tests, run a player-path
scenario, capture stills/video, inspect evidence, fix and rerun, then summarize. Test the negative case too.
Run the project smoke command before commit; run multiplayer/device checks when the change affects them.
Never substitute teleporting or editing a value for proving movement, clicking or gameplay actually works.
Use stable UI identifiers and current bounds. Release held inputs in finally/cleanup. Reinspect after layout changes.
Wait for observable conditions with deadlines rather than relying on arbitrary sleeps.

Every run records scenario/version, source revision and dirty state, Studio/tool versions, seed/fixture,
device/viewport, number of clients, timestamps, step outcomes, errors and relative evidence paths.
Keep logs, data, clips and stills outside the repository. Never print session tokens or account credentials.
Report PASS, FAIL, BLOCKED and SKIPPED accurately. Building a place is not running it; passing a mock is
not passing Studio; a green test is not visual review. No missing check silently becomes PASS.

Keep an ADR for major architecture changes. Keep a short project journal: decision, change, evidence,
remaining work. Handoffs identify the exact revision and how to reproduce. Independent review should
inspect the actual code and recording, not repeat the author's summary.

Use my installed agent's supported tools. Do not assume your agent has GUO's private fleet or services.
No public publishing, external messaging, production data changes or purchases without owner authorization.
