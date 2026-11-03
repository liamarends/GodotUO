# Roblox Agent Workflow Kit integration

The supplied kit is integrated into Don't Wake the House's existing development
workflow. Its original bytes, manifest, sources and licences are preserved under
[reference/roblox-agent-workflow-kit](../reference/roblox-agent-workflow-kit/START-HERE.md).
All 49 manifest entries were hash-verified on import. That folder is reference
material: its bootstrap prompt is an example assignment, and its GUO skills,
launchers and engine-specific runner are not active Roblox instructions.

## Active workflow

Use `dev-story` for implementation, `roblox-test` for checks, `roblox-evidence` for
recorded/reproducible runs, and `test-evidence-review` to assess the result.
`AGENTS.md` and the canonical `.claude/skills` route future project work through
this workflow. Run `python tools/agent_skills/run.py` once in each checkout to
expose the same skills through `.agents/skills` for Codex.

The game remains mapped by `roblox/default.project.json`. The kit's isolated
starter/plugin is outside that tree and must never be synced into the game.
No new plugin, remote-code service, global skill, recording or publishing job is
installed by importing these instructions.

## Commands (from repository root)

```text
python tools/roblox_workflow/doctor.py
python tools/roblox_workflow/doctor.py --tool-dir PATH_TO_ROJO --tool-dir PATH_TO_LUAU --tool-dir PATH_TO_STYLUA --tool-dir PATH_TO_LSP
python tools/roblox_workflow/doctor.py --require-recording
python -m unittest discover -s tools/roblox_workflow -p "test_*.py"
python tools/roblox_workflow/run_evidence.py --root ../roblox-runs --scenario house.logic --revision COMMIT-clean -- python roblox/tests/run.py
python tools/roblox_workflow/run_evidence.py --root ../roblox-runs --scenario house.play --revision COMMIT-dirty
python tools/roblox_workflow/record_window.py --title "EXACT CURRENT STUDIO TITLE" --seconds 30 --run PATH_PRINTED_ABOVE
```

Replace revision labels with the actual commit and dirty state. `ROBLOX_RUNS_DIR`
can supply the default evidence directory; `ROBLOX_BUILD_DIR` can hold separately
built places. Use absolute external paths when running from different directories.
Helpers refuse evidence inside the checkout, create unique run folders, retain
logs, and never upload them. Commands and output are logged verbatim: never pass
credentials. The recorder needs FFmpeg/ffprobe and Windows, captures no audio,
requires a visible/unminimized exact window, and refuses overwriting a capture.
Review the clip even if ffprobe succeeds. Doctor discovers tools; its success
does not assert runtime, input, capture or visual-test success.

`run_evidence` exits with the child exit code, 124 on timeout or 2 for a missing
program. A manifest-only invocation creates NOT_RUN, not PASS. Its timeout bounds
the immediate child, not a general process tree. Do not use it as a Studio session
supervisor; use supported app/Studio tools with an owned-session watchdog.

## Project player-path scenario

Use [the game checklist](../roblox/TESTING.md): start outside, clock in, walk to a
small item, pick up through E/touch, rotate, carry into the bay, and observe one
server delivery plus matching HUD. Keep state mutation confined to fixture setup.
Follow with two-carrier, disconnect, hide/rescue, round replay and mobile cases
when relevant. The game disables the Reset button intentionally; test respawn
through a controlled fixture rather than expecting a normal player reset action.
Use Studio demo/mock inventory; live products and persistent storage require the
separate test experience described in the game guide.

The kit's [test guide](../reference/roblox-agent-workflow-kit/guides/03-testing.md),
[recording guide](../reference/roblox-agent-workflow-kit/guides/04-recording.md),
[capability matrix](../reference/roblox-agent-workflow-kit/templates/capability-checklist.md)
and [handoff](../reference/roblox-agent-workflow-kit/templates/handoff.md) provide
templates for new runs. Populate actual evidence, never upgrade copied NOT_RUN rows.

## Validation and remaining capabilities

Integration checks: archive hashes, helper success/failure/missing-program/timeout
paths, non-finite timeout rejection, checkout-output rejection, skill discovery,
documentation links and runtime mapping separation. CI repeats helper tests.
The existing game has prior build/type/regression and limited Studio startup
evidence recorded in its test guide; importing this kit does not expand that proof.

The optional StudioTestService plugin is preserved as supplied but not installed
or executed in this integration. No automated Studio RPC adapter, recorded player
path, multiplayer capture, visual baseline, or five-minute soak is newly verified.
Those are future capability-validation runs, not blockers to using the integrated
instructions and command helpers today. Follow the adapter contract if implementing
such an integration; do not infer working APIs or permissions from the sample.

Active helper files are adapted from the kit: added external-path enforcement and
finite timeout validation. The immutable reference copies retain their original
hashes and attribution. Existing Godot/UO source and game source are unchanged.
