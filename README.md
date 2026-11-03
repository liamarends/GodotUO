# Don't Wake the House — Roblox Studio

Agents, skills and workflows for **liamarends' Roblox Studio / Luau project**,
adapted from [DatMoshu/GodotUO](https://github.com/DatMoshu/GodotUO) and its
Claude Code Game Studios foundation.

The active game is **Don't Wake the House**, a 1–4 player horror comedy about
moving furniture without waking The Duvet. Start with the
[game, Studio setup and shop guide](roblox/README.md) and
[test checklist](roblox/TESTING.md). Developer agents use the
[Roblox workflow guide](docs/roblox-workflow.md).

## What is ready

- Six focused roles for Studio, server logic, client/UI, QA, design and review.
- Six skills for onboarding, implementation, review, testing, evidence and releases.
- A full prototype in [roblox/](roblox/README.md): generated house/truck, carrying,
  noise, monster, round resets, keyboard/touch HUD and fair optional shop.
- Saved consumables/free rewards, receipt deduplication, one team boost per round,
  server-verified cosmetic pass. Real product/pass IDs default to zero.
- CI for skill discovery, formatting, Luau compilation/type analysis, inventory
  regression cases and a local place build on Windows/Linux.
- Publication is manual; no Roblox credentials or live place IDs are configured.

## Quick start

Install Roblox Studio and the pinned CLI tools listed in
[roblox/tool-versions.json](roblox/tool-versions.json) from their official releases.
From this repository root:

```text
python tools/agent_skills/run.py
python tools/agent_skills/run.py --check
```

Create a `build` directory, then:

```text
rojo build roblox/default.project.json -o build/dont-wake-the-house.rbxlx
```

Open that file in Studio and press Play; the server creates the house. The default
Studio shop demo uses temporary stock and never spends Robux. The optional Rojo plugin supports live sync; see the
guide before connecting an existing place. A build is not a Studio playtest.

## Legacy and provenance

The inherited Godot/UO game code has **not** been converted to Roblox. It remains
for reference under its original directories. The previous agent definitions
and workflows are archived in [legacy/godotuo/](legacy/godotuo/README.md).
Historical game docs under `docs/wiki/` describe GodotUO, not this Roblox game.

Keep the [licence](LICENSE) and [upstream notices](docs/upstream/LICENSE-Claude-Code-Game-Studios-MIT).
UO game data is proprietary and is not part of the Roblox workspace.
