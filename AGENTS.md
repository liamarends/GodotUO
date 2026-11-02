# Roblox Studio project — liamarends

## Scope and ownership

The active target is **Roblox Studio + Luau**, maintained in liamarends/GodotUO.
The repository name is inherited. Work in `roblox/` for experience source.
This setup adapts development agents and workflows; it does not port the
ClassicUO C# client to Roblox or include an existing published experience.

Godot/C# source, UO tooling and historical docs remain as reference.
`legacy/godotuo/` preserves the old agent configuration and GitHub workflows.
Do not apply their engine pins, L0–L4 layers, shard tests or release commands to
Roblox work. Keep licences and attribution. Changes to legacy code require a
task explicitly targeting it; consult its archived AGENTS first.

## Working agreement

Read `docs/roblox-workflow.md` and `.claude/docs/technical-preferences.md`.
A scoped implementation request includes necessary local edits and checks.
Respect review-only and planning-only requests. Resolve routine choices from
the project; ask about product decisions that cannot be inferred.

Use one session unless the user explicitly requests delegation. Role files
provide expertise, not a required hierarchy of subagents. Use the selected
runtime/model and available tools; do not assume Claude Task or Roblox MCP exists.
Never claim Studio interaction, testing, a human sign-off or publication without evidence.

Target this fork's branch/PR, not DatMoshu's repository. Do not publish an
experience, alter production data or upload assets unless the task authorizes it.

## Roblox boundaries

- ServerScriptService owns authoritative gameplay, rewards and persistence.
  Clients handle input, camera and presentation. ReplicatedStorage is visible
  to clients: shared code/config is not secret.
- Validate every client-triggered server action: types, finite numeric bounds,
  sizes, permissions, ownership, state/distance and rate limits as applicable.
  Client cooldowns and UI state are not authorization.
- Keep DataStore calls server-side. Handle failure without overwriting valid data
  with defaults; use appropriate concurrent updates and schema migration.
  Use a separate test experience for persistence tests, not live player data.
- Define developer-product fulfillment through server receipt processing with
  duplicate-receipt protection. Never grant products from a client purchase signal.
- Clean up connections and per-player state. Account for respawn, late join,
  streaming and instance lifetime when relevant.
- Use `--!strict` for new Luau modules/scripts. Consult current Roblox APIs;
  do not substitute Lua, C#, Godot signals or .NET packages.
- Record origins/permissions for assets. No proprietary UO game data,
  credentials, Roblox session cookies or private machine paths in Git.

## Layout and checks

`roblox/default.project.json` maps:
- `roblox/src/server` → ServerScriptService.Server
- `roblox/src/client` → StarterPlayer.StarterPlayerScripts.Client
- `roblox/src/shared` → ReplicatedStorage.Shared

The starter builds a local place with a baseplate and spawn. It has no place ID,
monetization, remotes or persistence. Rojo manages mapped source; Studio authors
scene content. Inspect the sync diff before connecting to an existing place.

From the repository root:
```text
python tools/agent_skills/run.py --validate-only
python -m unittest discover -s tools/agent_skills -p "test_*.py"
stylua --check --config-path roblox/stylua.toml roblox/src
rojo build roblox/default.project.json -o build/roblox-starter.rbxlx
```

Create `build/` before building. Tool versions are in `roblox/tool-versions.json`.
Rojo builds the place hierarchy; StyLua parses/formats source. Neither runs
Roblox or proves Luau type correctness. Inspect Script Analysis and Output in
Studio; use Test and Server & Clients (at least two clients for replicated changes).
Use device emulation for UI/input. Record unavailable checks honestly.

## Agents and skills

Active roles and skills are only under `.claude/agents/` and `.claude/skills/`.
Archived files under `legacy/` are not active skills. Historical studio
templates in that archive are optional references, not prerequisites for a Roblox task.

Run `python tools/agent_skills/run.py` once per checkout to expose the active
skills to Codex through `.agents/skills/`; `--check` verifies discovery.
Claude reads the same canonical skills. For onboarding read
`.claude/skills/roblox-workflow/SKILL.md`.

Use roblox-studio-specialist for architecture/sync, roblox-server-engineer for
server/network/data, roblox-client-ui-engineer for presentation/input,
roblox-qa for tests, lead-programmer for review, and game-designer for design.
Applicable code rules are in `.claude/rules/roblox-luau.md`.

Keep concise handoffs in ignored `production/session-state/active.md`.
Generated places, logs and captures go in ignored `build/` or a task-provided
external folder. Reviewed source assets and fixtures keep their own paths.
