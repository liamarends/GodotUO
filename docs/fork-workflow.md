# Working in liamarends/GodotUO

This is liamarends' fork of [DatMoshu/GodotUO](https://github.com/DatMoshu/GodotUO).
It remains the same Godot .NET ClassicUO port. Keep upstream copyright,
licences, pins and historical attribution. Fork decisions belong to liamarends;
upstream acceptance is a separate process.

## Start once per checkout

Read [AGENTS.md](../AGENTS.md). With Python 3.12+ available, run from the repo root:

```text
python tools/agent_skills/run.py --validate-only
python tools/agent_skills/run.py
python tools/agent_skills/run.py --check
```

These commands require neither Godot nor game data. They expose the canonical
`.claude/skills/` through a gitignored `.agents/skills/` junction on Windows
or symlink elsewhere. Never commit the link or duplicate the skill collection.
The helper refuses to overwrite a real folder. Run setup again in each clone
or worktree. This deliberate skill link is separate from engine/upstream
worktree setup, which needs no manual directory links.

Codex can then select `$guo-workflow`, `$dev-story`, `$code-review` or an
existing UO skill. Claude uses the same names with slash syntax.
If the selector does not update, restart the session. Before link setup, an
agent can still read the canonical SKILL.md directly as AGENTS instructs.

Official references:
[skill discovery](https://learn.chatgpt.com/docs/build-skills) and
[AGENTS discovery](https://learn.chatgpt.com/docs/agent-configuration/agents-md).

For building the actual client, follow [Getting Started](wiki/Getting-Started.md).
Use your own local config, legal UO installation and an external UO_BUILD_DIR.
Agent setup alone does not install or validate the game.

## Daily workflow

| Request | Starting point | Evidence |
|---|---|---|
| Small fix or feature | dev-story; request or existing story | Focused checks and criteria coverage |
| Port a file/subsystem | port-file and docs/port_plan.md | Build, current audit, relevant parity proof |
| Rendering change | uo-render-engineer and governing ADR | Matched captures plus relevant probes |
| Review a diff | code-review | Findings and remaining verification gaps |
| Assess QA readiness | test-evidence-review | Criterion-to-evidence mapping |
| Editor, data, Android or web | Matching existing skill | Its scoped tests and target-specific evidence |

The shared [technical preferences](../.claude/docs/technical-preferences.md)
describe the actual stack. The
[coordination rules](../.claude/docs/coordination-rules.md) apply to all inherited
roles and skills. The studio phase catalog is optional planning guidance; do
not restart an existing port at the concept phase because template files are absent.
A direct, scoped task does not require a fictional story ID or director meeting.

## Checks

Run commands from the repository root. Use the .sh launcher twins off Windows.

| Scope | Command |
|---|---|
| Skill manifests without local setup | `python tools/agent_skills/run.py --validate-only` |
| Codex discovery after setup | `python tools/agent_skills/run.py --check` |
| Skill helper regression tests | `python -m unittest discover -s tools/agent_skills -p "test_*.py"` |
| Markdown links | `python tools/docs_lint/run.py` |
| Launcher consistency | `python tools/launcher_lint/run.py` |
| Privacy scan | `python tools/privacy_scan/run.py` |
| Python behavior | `python -m pytest -q tools/<affected-tool>` |
| Client compilation | `dotnet build godot/GUO/GUO.csproj` |
| Full local smoke | `launchers/dev/smoke.bat` |
| Port progress | `launchers/pipeline/03_port_audit.bat` |

Full smoke remains the pre-commit check in AGENTS. If required prerequisites
are unavailable, record the attempted check and exact blocker; do not say it
passed. A tooling/docs PR may be prepared with this limitation disclosed for
maintainer review. Runtime acceptance still needs its relevant real evidence.

The lightweight **agent-setup** workflow checks manifests, helper behavior and
skill discovery on Windows and Linux without a UO installation. Existing CI
continues to cover the client and tools; a green setup job is not game certification.

## Branches and publishing

Use a focused `work/<topic>` branch and target PRs at
`liamarends/GodotUO:main`. Check the actual remote before pushing.
Do not send a PR to DatMoshu by default. CODEOWNERS identifies liamarends.

Publishing workflows are opt-in on this fork:
- Pages: configure GitHub Pages for Actions, then set repository variable
  `GUO_ENABLE_PAGES` to `true`.
- Wiki: create the first Wiki page, then set `GUO_ENABLE_WIKI` to `true`.
- Release exports: set `GUO_ENABLE_RELEASES` to `true` after checking platform
  requirements and any signing secrets. Tag runs create drafts, not published releases.

The variables gate jobs, including manual dispatch. Leaving them unset skips
publishing. No secrets, signing identities or deployment settings are copied
from upstream by this adaptation. Ordinary build/CI checks remain enabled.

## Handoffs

Use the existing gitignored `production/session-state/active.md` for a concise
task, branch, decisions, files changed, check results and next action when needed.
Generated evidence belongs under an externally configured UO_BUILD_DIR, for
example its `runs/<run-id>/` subfolder. An upstream shared fleet is not required.
Review logs before sharing them and retain useful results in the PR without secrets.

## Adaptation provenance

Based on DatMoshu/GodotUO commit
`1c80eca2b8dd97e3734f18783b0402cad1cfdc0c`.
The existing UO specialist roles and skills remain available. This fork updates
ownership, technical preferences, the lead-programmer role, daily implementation
and review skills, and cross-agent coordination. Historical studio documents are
retained for optional specialist workflows under the fork rules.
See [upstream notices](upstream/LICENSE-Claude-Code-Game-Studios-MIT).
