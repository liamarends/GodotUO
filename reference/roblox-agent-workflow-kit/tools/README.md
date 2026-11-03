# Local helpers

Python 3.12+, standard library only. Run from the kit folder.
```
python tools/run_evidence.py --root C:/RobloxEvidence --scenario smoke --revision abc123-clean
python tools/run_evidence.py --root C:/RobloxEvidence --scenario build --revision abc123-clean --timeout 120 -- rojo build starter/default.project.json -o C:/RobloxBuild/smoke.rbxlx
```
Use the printed run folder with record_window.py as explained in guides/04-recording.md.
The build output parent must exist. A command exit of zero only proves that command, not gameplay.
No-command mode creates a NOT_RUN manifest. Finish gameplay results through your adapter after checking evidence.
The command helper bounds its immediate child; it is not a general Windows process-tree supervisor.
For Studio use the adapter's owned-session watchdog and cleanup, not this generic command wrapper.
Do not send commands with secrets to this logger; child output is preserved verbatim, not automatically redacted.
