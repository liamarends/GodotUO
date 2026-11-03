---
name: dev-story
description: "Implement a GodotUO story or scoped change, preserve port and ADR constraints, and verify the acceptance criteria. Use for requested code or tooling changes, not review-only work."
---

# Implement a GUO change

Read `AGENTS.md`, `.claude/docs/technical-preferences.md` and
`docs/fork-workflow.md`. Work in the user's fork.

1. Read the supplied story or request and its acceptance criteria. If no story
   exists, use the request as the brief; do not manufacture sprint infrastructure.
   If the task itself is unspecified, ask what to implement.
2. Inspect relevant code, applicable rules and actual ADRs. For a story with
   TR IDs, resolve them in the existing registry. Missing or contradictory
   referenced requirements need resolution; absence of optional template
   scaffolding does not block an otherwise specified task.
3. Check real dependencies. Do not mark a dependency done simply because its
   status is inconvenient. Separate stale bookkeeping from missing implementation.
4. Classify the feature layer. Route port work through `port-file`; read the
   matching role for rendering, network, file-format, editor or platform work.
   Follow `.claude/docs/coordination-rules.md` for single-session execution
   and explicitly requested delegation.
5. Implement in small batches in existing project locations. Preserve ported
   names and behavior. Keep GUI authoring behind TOOLS and AI behind AiFeatures.
   Necessary local edits and tests are included in the user's implementation request.
6. Run the checks appropriate to the touched area. Fix failures caused by the
   change; report pre-existing failures and unavailable prerequisites. For a
   behavior fix, add a focused regression test in the existing harness when feasible.
   Configuration and prose edits need relevant validation, not artificial unit tests.
7. Review the diff for scope, credentials, proprietary data and accidental port
   drift. Map each acceptance criterion to the actual evidence or remaining gap.
   Do not equate compiling with working on a shard.

If using an existing story, update its status consistently with the evidence.
Keep open criteria open; never invent QA or maintainer sign-off. A short local
handoff can go in `production/session-state/active.md`. Return the changes,
checks, limitations and next required action. Do not publish a release or merge
a PR unless that is part of the authorized task.
