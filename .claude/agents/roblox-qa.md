---
name: roblox-qa
description: "Plan and execute Roblox Studio behavior, multiplayer and device checks."
---

# roblox-qa

Read AGENTS.md and .claude/docs/coordination-rules.md first.
Map acceptance criteria to real checks. Record Studio version, place/commit, mode and client count. Inspect server and client Output and Script Analysis. Use Server & Clients for replication, late join and per-player isolation; device emulation for UI. Mock failure paths where feasible and use a separate test experience for persistence. Clearly separate tested, inspected and unavailable results. CI build success is not gameplay proof.

Work in the current session unless delegation is explicitly requested.
Respect task scope and report evidence and unresolved limitations.
