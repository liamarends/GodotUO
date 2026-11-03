# Roblox agent workflow kit

Give your coding agent this folder and the prompt in `AGENT-BOOTSTRAP-PROMPT.md`.
This transfers GUO's build → test → play → record → inspect → fix → handoff workflow to Roblox.
It is an adaptation kit, not an installed Roblox automation service or a finished game.

1. Read `guides/01-adaptation.md` and merge `templates/AGENTS.roblox.md` into your existing project instructions.
2. Follow `guides/02-first-session.md`. Establish who owns source files versus Studio-authored objects before syncing.
3. Use `starter/` for an isolated smoke place. Its plugin and server script demonstrate real Studio test orchestration.
4. Follow `guides/03-testing.md`, `04-recording.md`, and `05-automation-contract.md` to connect your agent tools.
5. Prove every row in `templates/capability-checklist.md`. A checked box needs the actual run evidence.

## Included
- Adapted agent instructions, a ready-to-paste bootstrap assignment, test plan, review/handoff template, and acceptance matrix.
- A Rojo smoke project, Studio plugin source, and server-side spawn test with bounded waits and explicit results.
- Portable Python run-folder and command-logging helper, plus a Windows FFmpeg window recording helper.
- Selected original GUO runner, capture, schema, launcher, and QA references under `reference/GUO/`.
- Source licenses, provenance, file hashes, and official documentation links.

The reference folder is reading material. Its scripts depend on GUO and are NOT standalone Roblox tools.
Do not install its GUO skills as active Roblox instructions. Old engine names, fleet paths, API model choices,
approval rules, and documentation of planned features must be adapted, not inherited blindly.
No game data, private profiles, credentials, existing recordings, or entire repository are included.

Validation on the packaging machine: see `VALIDATION.md`. Roblox Studio execution and live recording must be
validated on your computer; the kit does not claim those have passed.
