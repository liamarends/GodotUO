# Tests that prove gameplay

Use four layers: fast pure-Luau unit tests; Studio integration tests; real-input player-path tests;
visual/performance review. Keep each result separate. Choose the project's existing framework first.

Each scenario needs id/version, setup fixture/seed, required capabilities, clients/device, step deadlines,
overall deadline, actions, expected observations and cleanup. Log expected versus observed values on failure.
Timeout, absent capability, missing result and process exit must never be success. Retries should be bounded
and recorded as attempts; do not hide flaky failures behind a final green retry.

Minimum smoke suite:
- Spawn: real player, live humanoid, correct spawn region, usable camera and no unexpected Output errors.
- Movement: drive input, observe displacement/collision, release key, verify stopping. Don't teleport as proof.
- Interaction: click/activate through player UI, assert a server-owned state change and resulting client UI.
- Reset: die/respawn, ensure controls and HUD reconnect exactly once; repeat to detect duplicate connections.
- Two clients: one player's action is replicated correctly to the other; private UI/data stays private.
- Negative remote: malformed/out-of-range/duplicate request is rejected by server without granting reward.
- Mobile/controller: test relevant real input and viewport layout. Emulation does not replace final device testing.
- Persistence: mock/unit checks first; use an isolated test experience/data namespace for real save/rejoin tests.
- Soak: warm up, play repeated cycles for 5 minutes, compare first/last windows of frame time, memory,
  instance counts and owned connection counts. Investigate sustained growth; do not fail on one GC spike.

For visual tests fix camera, viewport, graphics quality, fixture and lighting. Mask genuinely variable regions
only with a documented reason. Record input latency/performance in real time; MovieWriter-style output FPS
would not measure runtime FPS. Annotate capture overhead and host load. Don't invent hardware-independent limits.

Use a per-run watchdog outside the Studio test too: a plugin call that never returns cannot enforce its own
outer deadline. Preserve failure logs/captures, end only the session you own, release inputs and close fixtures.
