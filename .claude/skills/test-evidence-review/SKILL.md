---
name: test-evidence-review
description: "Assess whether tests and runtime evidence prove a GodotUO change's acceptance criteria. Use for evidence review or QA readiness, including stale, missing or incomplete proof."
---

# Review test evidence

Read the task/story and `AGENTS.md`. Locate evidence from the supplied paths,
the changed tests and the configured output location. Tests normally live
under `tools/`; do not assume a generic `tests/unit/` layout.

For each acceptance criterion:
1. Identify the observable behavior and relevant success/failure cases.
2. Read the test or run record and check what it actually asserts. One strong
   assertion can be sufficient; many vacuous assertions are not evidence.
   Parameterized tests, exception expectations and standalone exit-code test
   programs count when they establish the contract.
3. Check the recorded command, result, commit/configuration and platform.
   If freshness is unknown, state that; file existence or a timestamp alone
   does not prove a run against the current change.
4. Distinguish compilation, synthetic behavior, engine probes, visual parity
   and shard playtests. None automatically substitutes for the others.
5. Verify referenced captures exist and are relevant without copying private
   logs, credentials or proprietary game data into the repository.

Return a criterion-to-evidence table with **verified**, **incomplete** or
**missing** for each item and the specific check needed to resolve a gap.
State whether you ran tests or only inspected records. Human decisions and
sign-offs must be attributed to real people; do not fabricate a department
approval for this solo-maintained fork.

Do not modify tests, close stories or run a live shard/device operation as
part of a read-only evidence review. Save a report only when requested; the
conversation report is sufficient otherwise.
