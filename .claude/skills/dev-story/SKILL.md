---
name: dev-story
description: "Implement a scoped Roblox Studio/Luau feature or bug fix with relevant checks; use for implementation, not review-only requests."
---

# dev-story

Read AGENTS.md and the task or story. Use the request as the brief if no story
exists. Confirm testable outcomes and inspect the service mapping and callers.
Choose the server, client/UI or Studio role based on the changed behavior.
Implement inside roblox/ using existing modules and conventions. Keep authoritative
rules on the server; define and validate the remote contract when one is needed.
Do not add a remote, datastore or framework to a change that does not need one.
Run formatting/build checks and relevant automated tests, then use roblox-test
for Studio-dependent evidence when available. Add regression tests for behavior
fixes using an existing runner; do not invent results when Studio is unavailable.
Self-review the diff and map criteria to evidence or open gaps. Update an existing
story honestly. Do not publish the experience as part of routine implementation.

Use roblox-evidence for reproducible logs or player-path recordings relevant to the change. See docs/roblox-agent-kit.md; report unavailable capabilities without blocking unrelated work.
