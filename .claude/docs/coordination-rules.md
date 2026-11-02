# Fork coordination rules

This fork is maintained by **liamarends**. Read `AGENTS.md` and
`docs/fork-workflow.md` before applying an inherited studio role or skill.

## Ownership and scope

- Work on `liamarends/GodotUO`. Verify the repository and branch before a push
  or PR. DatMoshu/GodotUO is upstream reference, not the default write target.
- An implementation request authorizes the necessary local edits and checks.
  Do not repeat "May I write this file?" for each edit within that request.
- Clarify material ambiguity or a change to an accepted architectural decision.
  Respect explicit planning-only and review-only requests.
- Release publication, deployment and upstream submissions are separate tasks;
  a code change does not authorize them.

## Roles and delegation

Default to one session applying the relevant specialist's guidance. The role
files supply expertise; their organizational hierarchy is not a mandatory
chain of agents or a substitute for the maintainer's decisions.

Spawn subagents only when the user or applicable instructions explicitly request
delegation and the runtime supports it. Never infer authorization merely from
an inherited "spawn via Task" step. When delegation is requested, assign
non-overlapping files, inputs, expected evidence and a completion condition.
Collect results before dependent work; report failures without hiding partial work.

Claude tool names such as Task, Read, Bash and AskUserQuestion are examples.
Use the current runtime's equivalent, or do the work in the current session.
Claude model names, memory fields and maxTurns are Claude metadata, not Codex
configuration. Use the session's selected model; do not silently change it.

## Review and evidence

Use relevant role perspectives for review, not ceremonial sign-offs. Never
claim an independent reviewer or human approval that did not occur.
Preserve the accepted ADRs and port parity; assess tests by behavior, not line
counts or assertion quotas. A build, a synthetic test, a screenshot and a real
shard playtest prove different things.

Keep concise task state in gitignored `production/session-state/active.md`
when a handoff is useful. Store generated captures/logs under an externally
configured `UO_BUILD_DIR`, following `AGENTS.md`. No shared fleet is required.
