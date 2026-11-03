---
name: code-review
description: "Review a Roblox Luau diff for correctness, authority, persistence, lifecycle and replication; use for read-only code review."
---

# code-review

Read AGENTS.md, the exact diff and affected callers. If scope is not supplied,
inspect local changes; ask for a target only if none exists.
Use the relevant Roblox role. Check server/client placement, remote validation
and rate limits, async/yield behavior, state ownership, connection cleanup,
respawn/streaming, persistence failures and device UI where affected.
Do not impose UO port parity rules or generic assertion/method-size quotas.
Return actionable findings with location, trigger, consequence and suggested
correction. Separate confirmed defects from questions and missing evidence.
Do not edit files, close stories or claim an independent approval.
