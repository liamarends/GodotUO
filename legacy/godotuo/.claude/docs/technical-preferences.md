# Technical Preferences — liamarends/GodotUO

Verified against the project files at fork baseline
`1c80eca2b8dd97e3734f18783b0402cad1cfdc0c`. Read current project files when pins change.
This is an existing ClassicUO port, not an unconfigured game template.

## Engine & Language

- **Engine**: Godot 4.7.2 .NET; pin in `launchers/_shared/config.bat`.
- **Language**: C#; desktop net8.0, Android and community web net9.0
  in `godot/GUO/GUO.csproj`. Python 3.12+ for tools.
- **Rendering**: Godot-hosted ClassicUO rendering; production Depth World with
  canvas recovery. Preserve nearest-neighbour native art. Consult the applicable
  rendering ADR before changing semantics.
- **Physics**: Preserve ClassicUO movement/collision rules; do not introduce
  Godot physics to replace them as incidental cleanup.

## Input & Platform

- **Target Platforms**: Windows first; Linux/Steam Deck, Android ARM64 and
  community-engine web have separate export paths and verification requirements.
- **Input Methods**: Keyboard/mouse, controller and touch.
- **Primary Input**: Desktop keyboard/mouse; preserve current input-mode switching.
- **Gamepad Support**: Existing implementation; consult ADR-0025 and ADR-0040.
- **Touch Support**: Existing implementation; verify affected behavior on a device.
- **Platform Notes**: Exportability is not proof of gameplay or device support.
  Official Godot web builds are not the project's C# web target.

## Naming Conventions

For ported files, preserve upstream names, layout, APIs and copyright headers.
For GUO-owned code, follow neighboring files: C# PascalCase types/methods,
existing member conventions, Python snake_case modules/functions. Do not rename
ported events, signals, files, scenes or constants to satisfy generic templates.

## Performance Budgets

- **Target Framerate / Frame Budget / Memory Ceiling**: No new global numeric
  target is established by this fork. Use the applicable ADR and measured baseline.
- **Draw Calls**: Existing perf gate allows at most +5% per comparable scene;
  batcher items may not increase. Frame-time results are advisory.
- Read `tools/perf_probe/README.md` for valid measurement conditions.
  Synthetic CI results do not establish runtime performance.

## Testing

- **Framework**: Python pytest and standalone scripts under `tools/`;
  engine-free C# test projects and Godot probes listed in CI and smoke launchers.
- **Minimum Coverage**: No invented percentage; verify changed behavior and
  relevant regressions with the existing test harness.
- **Required Tests**: Use the applicable commands from `docs/fork-workflow.md`.
  Never scaffold a second GDScript test framework for this C# port by default.

## Forbidden Patterns

The L0–L4 boundaries in `AGENTS.md` govern. In particular: no edits under
`sources/`, engine behavior in Compat, unmarked port drift, client-side
generation services, exported editor/Labs code, or committed proprietary data.

## Allowed Libraries / Addons

Use dependencies already declared in project files and existing tooling.
A template's empty dependency list is not permission to replace the stack.

## Architecture Decisions Log

Existing decisions live in `docs/architecture/`; consult its README and the
actual ADR status. Do not bootstrap a competing architecture or infer approval
from an index entry alone.

## Engine Specialists

These names refer to role files in `.claude/agents/`, not guaranteed runtime
subagents. Apply them in the current session unless delegation is authorized.

- **Primary**: godot-specialist
- **Language/Code Specialist**: godot-csharp-specialist
- **Shader Specialist**: godot-shader-specialist
- **UI Specialist**: ui-programmer
- **Additional Specialists**: uo-port-strategist, fna-migration-specialist,
  uo-fileformat-engineer, uo-network-engineer, uo-render-engineer,
  uo-editor-engineer, mobile-web-engineer
- **Routing Notes**: GUO port constraints take precedence over generic style advice.

### File Extension Routing

| File / area | Role |
|---|---|
| C# game code | godot-csharp-specialist plus the relevant UO specialist |
| Render, shaders, input or audio | uo-render-engineer; godot-shader-specialist for shaders |
| Game UI and gumps | ui-programmer |
| Godot scenes and lifecycle | godot-specialist |
| Editor add-on and authoring | uo-editor-engineer |
| Python tools | tools-programmer |
| Android and web exports | mobile-web-engineer |
| Architecture review | lead-programmer |
