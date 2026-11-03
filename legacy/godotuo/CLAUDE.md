@AGENTS.md

## Claude Code only

`AGENTS.md` above is the project's one set of instructions, shared with Codex,
GitHub Copilot and Cursor. Change rules there, not here. This section holds
only what is specific to Claude Code:

- Skills in `.claude/skills/` are slash commands here (`/port-status`, ...).
- The roles in `.claude/agents/` run as subagents.
- `.claude/hooks/` and `.claude/settings.json` add session hooks and the
  status line; other tools rely on the git hooks and CI instead.

## When compacting, keep

Current task and its PR or branch, decisions already made, files in flight, and the next command to run. Drop tool
output and exploration. Keep useful handoffs in the gitignored
`production/session-state/active.md`; re-read it when resuming work.
Compaction settings belong to the current runtime, not an assumed upstream fleet.

## Evidence

Follow AGENTS.md: generated evidence goes under an externally configured
`UO_BUILD_DIR/runs/<run-id>/`. No upstream shared folder is required.
