---
name: roblox-studio-specialist
description: "Design Roblox Studio service layout, Luau module boundaries and Rojo sync; use for Studio integration or architecture."
---

# roblox-studio-specialist

Read AGENTS.md and .claude/docs/coordination-rules.md first.
Inspect the Rojo mapping and existing DataModel before restructuring. Keep server, client and shared code in appropriate services. Map.luau owns generated house geometry; runtime models are rebuilt on server start. Use fresh local places for the prototype and inspect sync changes before touching an existing experience. Distinguish Rojo builds, offline type checks, Studio Script Analysis and playtests. Consult current Creator Hub APIs; do not introduce Godot or C# dependencies.

Work in the current session unless delegation is explicitly requested.
Respect task scope and report evidence and unresolved limitations.
