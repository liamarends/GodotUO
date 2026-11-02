# Roblox Studio workflow

## What this adaptation provides

The active project is `roblox/`, a small Luau starter with server/client/shared
source. It is not a port of the inherited C# game. The original Godot code and
documentation remain reference material; the former automation is archived in
`legacy/godotuo/`. The repository name can stay GodotUO without affecting Studio.

## Setup

1. Install [Roblox Studio](https://create.roblox.com/docs/studio/setup).
2. Install Rojo **7.7.1** from [its official release](https://github.com/rojo-rbx/rojo/releases/tag/v7.7.1)
   and StyLua **2.6.0** from [its official release](https://github.com/JohnnyMorganz/StyLua/releases/tag/v2.6.0).
   Versions and Windows/Linux archive checksums are in
   [tool-versions.json](../roblox/tool-versions.json). Put the executables on PATH.
3. For Codex skill selection, run from the repository root:
   `python tools/agent_skills/run.py`, then
   `python tools/agent_skills/run.py --check` (Python 3.12+).
   The local link exposes six canonical skills to Codex; Claude uses them directly.
4. Create a `build` directory and run:
   `rojo build roblox/default.project.json -o build/roblox-starter.rbxlx`.
5. Open the generated place in Studio. It contains a baseplate and spawn;
   Test should show server/client readiness messages in their respective Output views.

Studio installation/sign-in, live sync and playtesting must be reported separately
from offline build checks. Do not claim they happened from CI alone.

## Source and Studio ownership

| Source | Roblox container | Responsibility |
|---|---|---|
| roblox/src/server | ServerScriptService.Server | Private server logic |
| roblox/src/client | StarterPlayer.StarterPlayerScripts.Client | Input and presentation |
| roblox/src/shared | ReplicatedStorage.Shared | Public shared modules/config |

The starter does not configure remote calls, datastores, products or place IDs.
Introduce those only for the requested feature.

For live sync, install the matching Rojo Studio plugin from its official release
and run `rojo serve roblox/default.project.json`. The project binds to loopback.
Connect a fresh/local place first and inspect the plugin's change list.
For an existing experience, back up the place, inspect its current hierarchy and
choose mappings that preserve its content before syncing. Set `servePlaceIds`
only after the actual allowed IDs are known.

Edit mapped scripts in source; avoid simultaneous Studio edits to those scripts.
Rojo does not capture arbitrary scene edits back into the project. Save authored
maps/models in an appropriate Studio or source asset workflow with permission and
provenance; rebuilding the minimal starter does not preserve unexported scene edits.

See [Rojo project format](https://rojo.space/docs/v7/project-format/) and
[building a place](https://rojo.space/docs/v7/getting-started/new-game/).

## Development loop

Use `roblox-workflow` to orient, `dev-story` to implement, `code-review`
to review, `roblox-test` to test, `test-evidence-review` to assess proof,
and `roblox-release` only for release work. In Codex these can be selected as
dollar-prefixed skills; Claude uses slash commands.

A direct task can serve as the brief. Describe observable outcomes and who owns
each state change. Use the server/client/Studio specialist as needed in the
current session. Optional studio templates do not require a GDD or sprint before
fixing a bug. New architectural decisions can be recorded separately from legacy
Godot ADRs under `docs/roblox/` when needed.

Keep shared state authoritative on the server. Check untrusted input before
using it, limit costly requests, and clean up player/character resources.
For persistence, define load/save failure behavior before wiring live storage.
For paid products, handle receipts server-side and prevent duplicate grants.
Use [Roblox's server-boundary guidance](https://create.roblox.com/docs/scripting/security/client-server-boundary).

## Verification

From the repository root:

```text
python tools/agent_skills/run.py --validate-only
python -m unittest discover -s tools/agent_skills -p "test_*.py"
stylua --check --config-path roblox/stylua.toml roblox/src
rojo build roblox/default.project.json -o build/roblox-starter.rbxlx
```

Create build/ first. Use `stylua --config-path roblox/stylua.toml roblox/src`
to apply formatting when implementing a change.

These commands validate setup, parse/format source and assemble a DataModel.
They do not run gameplay, validate Roblox API usage/types or establish multiplayer correctness.
In Studio:
- Inspect Script Analysis and both client/server Output.
- Run Test and check the requested behavior and failure cases.
- Use Server & Clients with two clients for replicated changes; check isolation,
  late join, leave and respawn when affected.
- Use device emulation for UI and input; verify actual target hardware when needed.
- Test persistence against a separate test experience. Studio API access can touch
  live data; do not enable it on a production experience as a shortcut.
  See [Data stores](https://create.roblox.com/docs/cloud-services/data-stores).

See [Studio testing modes](https://create.roblox.com/docs/studio/testing-modes).
When Studio is unavailable, complete offline checks and list the specific unrun
checks. Do not silently mark a story done based solely on a build.

Record source commit, Studio version, local/test place, mode/client count, steps,
expected/actual result and errors. Save generated places/captures in ignored
build/ or a provided external folder; keep credentials and private logs out of Git.

## GitHub workflows and release

`agent-setup` validates skills, tests the discovery helper and checks active docs
on Windows/Linux. `roblox-ci` downloads pinned, checksum-verified tools, checks
formatting and builds the local place on Windows/Linux. Neither publishes.

The inherited Godot CI/build/Pages/Wiki/release files are archived outside
.github/workflows and do not run. Existing licences and game sources remain.

Use a focused branch and a PR into liamarends/GodotUO. Before a Roblox release,
identify the actual owner/group, experience/place, source commit, test results,
asset rights and rollback path. Publishing requires explicit authorization for
the destination and an available Studio/Creator Hub workflow. This repository
contains no Roblox credentials and no automatic upload workflow.
