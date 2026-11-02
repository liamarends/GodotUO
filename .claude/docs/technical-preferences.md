# Technical preferences — Roblox Studio

- **Engine**: Roblox Studio. Studio updates separately; record its version in test evidence.
- **Language**: Luau with strict type checking for new code.
- **Source**: roblox/src/server, client and shared; service mapping in roblox/default.project.json.
- **Sync/build**: Rojo 7.7.1, optional Studio plugin from the same release.
- **Formatter**: StyLua 2.6.0 with Luau syntax, roblox/stylua.toml.
- **Version source**: roblox/tool-versions.json; update its versions/digests and CI together.
- **Physics/rendering**: Roblox engine services and Instances; no Godot shaders or .NET runtime.
- **Input**: Design for keyboard/mouse and touch; verify gamepad if included by the feature.
  No claim of device support until tested.
- **Authority**: Server owns shared game rules and saved state. Shared modules are client-readable.
- **Persistence**: No persistence library or datastore schema selected by this starter.
  Add only when needed; isolate test experience data from live data.
- **Dependencies**: No gameplay framework selected. Do not add Knit, networking wrappers
  or a datastore package merely to satisfy a template.
- **Naming**: PascalCase ModuleScript names; descriptive camelCase locals/functions;
  Rojo .server.luau / .client.luau entry points; existing public APIs take precedence.
- **Performance**: Measure before assigning budgets. Test client and server costs separately,
  including low-end/mobile targets when in scope. No invented FPS or memory claims.
- **Testing**: Script Analysis, Test, Server & Clients, device emulation;
  targeted automated tests when a runner exists. CI currently checks setup/format/build only.
- **Specialists**: roblox-studio-specialist, roblox-server-engineer,
  roblox-client-ui-engineer, roblox-qa and lead-programmer.
- **Documentation**: docs/roblox-workflow.md. Historical Godot ADRs do not govern Roblox design.
