---
name: roblox-release
description: "Prepare or carry out an explicitly requested Roblox experience release with the correct target and verification evidence."
---

# roblox-release

Read AGENTS.md and docs/roblox-workflow.md. Identify the authorized owner/group,
experience and place, the source commit, asset permissions and rollout intent.
Missing target identity is a blocker for publication, not permission to pick one.
Check relevant Studio and multiplayer results, remaining defects and data/schema
compatibility. Ensure a recoverable previous place version and migration plan
where needed. Do not copy Roblox cookies or secrets into files.
Prepare concise release notes and a concrete target/build summary. Publish only
when publication to that target is explicitly authorized and an appropriate
Studio/Creator Hub tool is available. Otherwise report release readiness and
the exact remaining manual step. Confirm actual published version after a publish;
a successful Rojo build or GitHub merge is not a Roblox release.
