# agent_skills

Makes the project's skills visible to every coding agent from one copy in git.

| Tool | Reads skills from |
|---|---|
| Claude Code | `.claude/skills/` |
| GitHub Copilot, Cursor | `.claude/skills/` (also `.agents/skills/`) |
| Codex | `.agents/skills/` only |

The skills live in `.claude/skills/<name>/SKILL.md` (the open Agent Skills
format). `run.py` links `.agents/skills` to that folder. The link is gitignored,
so nothing is duplicated: a directory junction on Windows, a relative symlink
elsewhere.

```
launchers\dev\agent_skills.bat            create or repair the link
launchers\dev\agent_skills.bat --check    validate every SKILL.md and report the link
python tools/agent_skills/run.py --validate-only   manifests only, no link needed
launchers\dev\agent_skills.bat --remove   remove the link only (never the skills)
```

`--check` fails for invalid manifests **or a missing/wrong discovery link**.
`--validate-only` checks the manifests without needing a link and changes nothing.
Missing/empty source collections, missing SKILL.md files, mismatched names and
empty descriptions fail validation. Options are mutually exclusive.

Run the Python helper directly on a fresh clone: it needs Python 3.12+, but no
Godot, local game config or UO installation. The launcher wrappers use the shared
game configuration and are intended for an already configured development machine.
A real `.agents/skills` folder is never overwritten. Python standard library only.

Regression checks (also run by the agent-setup workflow on Windows/Linux):

```text
python -m unittest discover -s tools/agent_skills -p "test_*.py"
```
