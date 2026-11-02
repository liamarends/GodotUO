# Roblox coding standards

Use Luau and Roblox services. Keep authoritative state and persistence on the server.
Validate and rate-limit client-triggered actions at the server boundary.
ReplicatedStorage holds public shared modules, not secrets.

Use --!strict and useful exported types; narrow untrusted values before use.
Follow the current code's module style without imposing a framework.
Make initialization order explicit; avoid dependency cycles and indefinite waits
for objects that may never replicate. Clean connections/resources up on lifecycle changes.

Test the behavior and relevant failures, not assertion counts or method lengths.
Format with the pinned StyLua. Use Studio Script Analysis for Roblox-aware diagnostics.
A Rojo build only checks assembly of the place; do not call it a gameplay test.

Use Conventional Commits. Link real task/design decisions when they exist;
small changes do not require creating a studio planning hierarchy.
Preserve licences and asset provenance. Read AGENTS.md for authority and release scope.
