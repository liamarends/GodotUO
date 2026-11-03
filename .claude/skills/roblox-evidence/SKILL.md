---
name: roblox-evidence
description: "Collect reproducible Roblox build/test evidence and review Studio captures for a feature or bug; use for recorded playtests, QA runs, or evidence handoffs."
---

# Roblox evidence workflow

Read [the project integration guide](../../../docs/roblox-agent-kit.md) and the
feature's acceptance criteria. The supplied kit is reference material, not a
request to execute its entire bootstrap assignment or install its old GUO skills.

1. Discover available tools using `python tools/roblox_workflow/doctor.py`.
   Use `--tool-dir` for installed executables outside PATH; consult the pinned
   project versions. Tool discovery does not prove a Studio session or recorder works.
2. Create a run outside the checkout with `tools/roblox_workflow/run_evidence.py`.
   Record exact revision/dirty state, scenario, fixture, device/viewport, client
   count and tool/Studio versions. The command helper only proves the command it runs.
3. Run the relevant existing logic/build checks, then a real player path when
   gameplay changed and a supported Studio controller is available. One controller
   owns each session; use bounded observation waits and release held input during
   cleanup. Never use a teleport or edited reward as evidence that input works.
4. For requested video evidence, use the recording helper only when its dependencies
   and exact target window are verified. Keep account screens/notifications out of
   capture. Read the kit's recording guide for capture limits and inspect start,
   important actions and end. A valid video file alone is not visual approval.
5. Preserve failed evidence and rerun after fixes. Report PASS, FAIL, BLOCKED,
   SKIPPED or NOT_RUN per capability, with actual observations. An unavailable
   Studio adapter, multiplayer session or recording must remain unavailable.

The original [adapter contract](../../../reference/roblox-agent-workflow-kit/guides/05-automation-contract.md)
is a specification, not an installed service. Do not add arbitrary-code remotes
to the shipped game. Any future plugin/bridge belongs only to development fixtures.
Use the kit handoff template for substantial recorded runs; no fictional reviewer
or runtime result is required to complete an ordinary code edit.
