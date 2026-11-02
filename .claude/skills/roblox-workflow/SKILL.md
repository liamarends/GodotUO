---
name: roblox-workflow
description: "Set up this fork's Roblox Studio/Luau workflow and route tasks to its active skills; use for onboarding or Studio source setup."
---

# roblox-workflow

Read AGENTS.md and docs/roblox-workflow.md.
1. Identify whether the task uses the starter or an existing Roblox place.
   Do not infer a place ID or upload to an existing experience.
2. Check Python 3.12+, the pinned Rojo/StyLua versions and Studio availability.
   Skill discovery needs only Python:
   `python tools/agent_skills/run.py`, then `--check`.
3. For the starter, create build/, build with the command in AGENTS, and open
   the output in Studio when available. Optional live sync uses the matching
   Rojo plugin; inspect its proposed changes before applying them.
4. Route implementation to dev-story, review to code-review, testing to
   roblox-test, evidence assessment to test-evidence-review and an explicitly
   requested release to roblox-release.
Report what is ready and exactly what was verified. Never install Godot/UO data
or activate legacy hooks for Roblox work.
