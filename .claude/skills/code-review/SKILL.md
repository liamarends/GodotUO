---
name: code-review
description: "Review a GodotUO diff for correctness, port parity, feature-layer boundaries and test coverage. Use for review requests; report actionable findings without changing files."
---

# Review a GUO change

Read `AGENTS.md`, `.claude/docs/coding-standards.md` and the applicable ADRs.
Identify the exact diff/base and requested scope. If no diff or files are
specified, inspect local changes; if none exist, ask for the review target.

Inspect changed code and relevant callers. Use the appropriate role guidance
in the current session. Delegation follows `.claude/docs/coordination-rules.md`;
do not claim independent review when performing it yourself.

Prioritize:
- Regressions in packet framing, readers, state transitions, input, rendering,
  cleanup and error handling when affected.
- L0 parity and marked deviations; Compat must not acquire engine behavior.
- L1 off-state behavior; L2 typed non-executable packs; TOOLS/AiFeatures gates
  for editor work; opt-in Debug-only Labs and export exclusion.
- Configuration consistency, platform guards and public API compatibility.
- Tests that exercise the changed contract and meaningful failures. Treat
  missing runtime or visual evidence as a gap, not a passed check.

Do not impose generic method-length, assertion-count, singleton or DI rules on
faithfully ported code. Do not invent a requirement for missing studio templates.
For a referenced ADR, read its decision and status; report actual contradictions.

Report actionable findings in severity order with file/line, triggering
conditions, consequence and a suggested correction. Distinguish confirmed bugs
from unresolved questions. If no issues are found, say so and name remaining
verification gaps. This workflow is read-only; fixes require an implementation
request. Do not silently close stories or fabricate approval.
