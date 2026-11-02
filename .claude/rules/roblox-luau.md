---
paths:
  - "roblox/**/*.luau"
  - "roblox/**/*.lua"
---

# Luau and Roblox

Read AGENTS.md and the service mapping before editing.
Use --!strict; validate untrusted input at the server, including non-finite numbers.
Keep private/server state out of replicated containers.
Choose RemoteEvent or RemoteFunction based on whether a response is needed;
avoid server-to-client blocking calls for authoritative decisions.
Use bounded work and clean up per-player resources.
DataStore errors are failures, not evidence that a player has no saved data.
Check replication, respawn, late join and streaming where they affect the change.
Format with StyLua; run Script Analysis and appropriate Studio tests when available.
