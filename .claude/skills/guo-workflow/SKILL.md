---
name: guo-workflow
description: "Set up or navigate the liamarends/GodotUO fork's agent workflow, choose the relevant GUO skill, and check Codex skill discovery. Use for fork onboarding or workflow setup."
---

# GodotUO fork workflow

Read `AGENTS.md` and `docs/fork-workflow.md`. Confirm the working repository
is liamarends/GodotUO before writing remotely. Preserve upstream provenance.

For setup, inspect prerequisites and run the engine-independent skill helper:

```text
python tools/agent_skills/run.py --validate-only
python tools/agent_skills/run.py
python tools/agent_skills/run.py --check
```

The helper creates a local link to the canonical skills, not a second copy.
If a real `.agents/skills` directory exists, leave its contents intact and
report the collision. Do not enable publishing or install the engine merely
to expose skills.

For ongoing work, use the shortest relevant path:
- Scoped implementation or bug fix: `dev-story`.
- ClassicUO port: `port-file`; progress: `port-status`; visual parity: `parity-check`.
- Review: `code-review`; proof assessment: `test-evidence-review`.
- Editor/data/platform task: read the matching existing specialist skill.

Apply `.claude/docs/coordination-rules.md` before inherited studio instructions.
User requests and the fork's AGENTS rules take precedence over template
approval loops, mandatory agent tiers or missing template artifacts.
Finish with what is configured, checks actually run, and any prerequisites still
missing. Do not claim a game build or playtest from skill validation.
