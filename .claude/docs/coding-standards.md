# Coding and verification standards

## ClassicUO port

`AGENTS.md` and the governing ADR define the port contract. Keep upstream
structure and behavior, including naming, static APIs and allocation patterns,
unless the task explicitly changes them. Mark unavoidable deviations with
`PORT DEVIATION (GUO)`. Do not apply generic line-length, method-size,
dependency-injection or documentation rewrites to ported code.

## GUO-owned code and tools

Follow the surrounding code and document non-obvious contracts. Keep runtime,
editor, packs and Labs in their defined layers. Share Python configuration
through `tools/guo`; new launchers need .bat/.sh pairs. Personal paths and
credentials belong only in local configuration.

Use Conventional Commits. Reference a real story or ADR when one applies;
do not fabricate IDs to satisfy a template.

## Design and architecture

Use existing design documents and accepted ADRs. New mechanics may use the
studio templates when useful. A small repair, tooling change or documentation
edit does not require inventing a GDD, TR registry entry or sprint first.
Record meaningful architectural changes in the existing ADR structure.

## Verification

Use the repository's actual Python tests, C# test programs, Godot probes and
launchers. See `docs/fork-workflow.md` for the command matrix.

- Test observable behavior and failure cases; use focused regression tests for fixes.
- Follow the existing test suite's naming and fixtures. Temporary filesystem
  integration tests and fixed random seeds are valid when isolated and reproducible.
- Judge assertions by what they prove, not how many there are.
- Visual changes need relevant visual evidence; a headless success cannot prove
  rendering parity or input feel. Do not invent a playtest or sign-off.
- Record failed and unavailable checks separately from passed checks.
- Hosted tests use synthetic data; users supply legally obtained UO data for live tests.
- Keep required checks enabled. Do not weaken tests to hide failures.
