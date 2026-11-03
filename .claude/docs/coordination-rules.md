# Roblox coordination

The maintainer is liamarends. Work in liamarends/GodotUO and target its PRs.
Roblox is the default; legacy/godotuo is historical reference only.

A scoped request includes the necessary local changes and relevant verification.
Do not add per-file approval loops. Ask when a decision materially changes the
user's intended feature or requires missing experience/asset information.
Read-only review does not authorize fixes or publication.

Work in the current session by default. Use role files as domain guidance.
Spawn agents only if explicitly requested and supported; partition files and
collect findings before dependent work. Do not require a studio director hierarchy.
Never claim an independent review, Studio run or human sign-off that did not happen.

MCP availability is discovered from the current environment, not assumed.
The empty MCP configuration intentionally starts no Godot or unverified Roblox service.
Read current Roblox documentation for APIs and permissions.

Keep local handoffs in production/session-state/active.md, and generated evidence
in ignored build/ or a specified external location. Shared fleet paths are not required.
