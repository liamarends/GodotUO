# Capability acceptance — fill with actual runs

Status starts NOT RUN. Add run id, revision, evidence path and reviewer for each row.

| Capability | Required proof | Status |
|---|---|---|
| Doctor | Missing dependency produces actionable nonzero result | NOT RUN |
| Build | Clean build opens in Studio | NOT RUN |
| Logic | Meaningful assertion passes; deliberate defect fails | NOT RUN |
| Studio test | Plugin receives server result, negative case and timeout work | NOT RUN |
| Agent control | Agent starts/stops owned session without user driving every step | NOT RUN |
| Input | Real input changes gameplay and held inputs are released | NOT RUN |
| Observation | Server change and visible UI agree | NOT RUN |
| Multiplayer | Two clients observe intended replicated behavior | NOT RUN |
| Recording | Playable correct-window clip, inspected motion and final state | NOT RUN |
| Screenshots | Actual scene at known viewport; reviewed | NOT RUN |
| Soak | Warmed-up first/last metrics with repeated gameplay | NOT RUN |
| Device | Touch/controller/layout tested for target platform | NOT RUN |
| Recovery | Hung test exits boundedly; failed evidence retained | NOT RUN |
| Production separation | Test fixtures/bridge absent from publish build | NOT RUN |
| Handoff | Another person reruns from documented commands | NOT RUN |

Only claim “agents can build/test/record this project” when the applicable rows have direct proof.
