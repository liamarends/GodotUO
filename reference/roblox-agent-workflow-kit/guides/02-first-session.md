# First session and build setup

1. Inventory existing project instructions, source control, place files, Studio plugins and agents' tools.
   Record versions. Do not run an unknown downloaded plugin or overwrite the current place.
2. Map ownership: which Instances are managed by Rojo, which remain Studio-authored, and how maps are saved.
   Back up the place before the first sync. Choose the current project's toolchain where possible.
3. Install/locate Roblox Studio and sign in interactively if necessary. Install a compatible Rojo CLI/plugin
   only if adopting Rojo. Use official installation docs; pin the versions actually validated.
4. Set ROBLOX_RUNS_DIR and ROBLOX_BUILD_DIR outside the checkout. Python 3.12+ runs the included helpers.
   FFmpeg and ffprobe must be on PATH for the optional Windows recorder. Never store passwords in config.
5. For the isolated starter, from `starter`, run `rojo build default.project.json -o <external-build>/smoke.rbxlx`.
   The output parent must already exist. Open that place in Studio. Do not sync the starter into an existing game.
6. Install `starter/plugin/WorkflowSmoke.plugin.lua` as a local Studio plugin using Studio's local plugin
   workflow (create a Script with this source and save as local plugin). It is deliberately outside the Rojo tree.
   Inspect its source first. Click Workflow QA → Spawn test. Save the complete Studio Output and result.
7. Expected: one character with HumanoidRootPart, then a structured result with ok=true. The plugin invokes
   StudioTestService; the server ends the test. Test with an intentionally wrong expected condition as a
   separate local variant and verify failure. Revert the mutation. Also test the watchdog/timeout path.

The included scripts are starter source, not a signed or preinstalled plugin. Installed Studio permissions
and API availability must be checked. Do not invent a universal headless Studio CLI. Pure Luau tests on a
CLI cannot prove Instances, physics, replication, GUI input or rendering. Use Studio for those checks.

Deliver project-specific doctor/build/test/play/record launchers after the above works. Each must print
what failed and the install/fix command, propagate nonzero exit codes, and avoid interactive stdin in CI.
CI can run static checks/builds; interactive Studio tests need a supported runner/session and separate evidence.
