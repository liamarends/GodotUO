# Validation scope

The packaging workflow checks Python syntax, all JSON files, ZIP integrity, file hashes and required entries.
It exercises the evidence helper's successful, failing, missing-command and timeout paths in temporary folders.
The recording helper's CLI is checked; actual Windows window recording is NOT RUN.
The Rojo project and Luau snippets are starter source; Rojo build, plugin installation, Studio execution,
multiplayer, real input, visual review and production separation are NOT RUN on the recipient machine.
Use templates/capability-checklist.md to complete acceptance. No gameplay capability is claimed from packaging tests.
