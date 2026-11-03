# Record, inspect and keep evidence

The included `tools/record_window.py` records one named Windows window with FFmpeg gdigrab.
It has a fixed duration, writes a capture log, refuses overwrite, checks the video stream with ffprobe,
and creates a first-frame still. It captures NO audio. For audio, use a separately validated OBS scene.
Keep the target visible and unminimized; test a short capture before a long run. A valid MP4 can still be
black, frozen, obscured or the wrong window, so visual inspection is mandatory.

Example (replace the exact current window title and existing run path):
```
python tools/record_window.py --title "Your Place - Roblox Studio" --seconds 30 --run "C:/evidence/run-001"
```
Launch the recorder, then drive the test in the existing Studio session while recording runs.
The eventual adapter should start capture, confirm it is active, then begin the scenario; stop/finalize on
completion or failure. This helper does not itself drive Studio or correlate exact action times.

For OBS automation, verify the installed OBS WebSocket API/client before implementing start/stop/status.
Use a dedicated window scene and a local password stored outside Git. Wait for recording-start confirmation,
log monotonic event offsets, wait for recording-stopped/file-finalized confirmation, then ffprobe the output.
Do not claim OBS is implemented merely because the GUO README includes an example.

Evidence layout: logs/, data/, clips/, stills/. Keep a run.json, events.jsonl, full raw output, original clip
and key stills. Correlate action timestamps with the recording start. Don't trim away the failing action.
Review start, each important action, transitions and end; watch the full short smoke clip for motion.
Check viewport, labels, HUD overlap, animation, camera, error output and the visible result of each action.
Save a review note distinguishing observed behavior from telemetry claims. Retain failure + fixed rerun.

Exclude private notifications/account screens from capture. Never upload evidence automatically.
Set retention limits after review; do not delete the only unreviewed failure evidence.
