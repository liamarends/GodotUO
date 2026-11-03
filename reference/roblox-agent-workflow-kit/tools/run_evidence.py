"""Create an evidence run and optionally log a bounded command. Does not drive Studio."""
import argparse, datetime, json, os, pathlib, re, subprocess, time, uuid

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--root', default=os.getenv('ROBLOX_RUNS_DIR'))
    p.add_argument('--scenario', required=True)
    p.add_argument('--revision', required=True, help='Exact revision plus dirty state if applicable')
    p.add_argument('--timeout', type=float, default=120)
    p.add_argument('command', nargs=argparse.REMAINDER)
    a = p.parse_args()
    if not a.root: p.error('Set ROBLOX_RUNS_DIR or --root outside your checkout')
    if not re.fullmatch(r'[a-z0-9][a-z0-9._-]{0,79}', a.scenario): p.error('Invalid scenario id')
    if a.timeout <= 0: p.error('timeout must be positive')
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')
    run = pathlib.Path(a.root).resolve() / (stamp + '_' + a.scenario + '_' + uuid.uuid4().hex[:8])
    for name in ('logs', 'data', 'stills', 'clips'): (run / name).mkdir(parents=True, exist_ok=False)
    manifest = {'run_id':run.name, 'scenario':a.scenario, 'revision':a.revision,
                'started_utc':stamp, 'status':'NOT_RUN', 'scope':'command only; no gameplay inference'}
    command = a.command[1:] if a.command[:1] == ['--'] else a.command
    code = 0
    start = time.monotonic()
    if command:
        # Never pass secrets as arguments. Child output must be safe before using this logger.
        with (run/'logs/command.log').open('w', encoding='utf-8') as log:
            try:
                result = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, timeout=a.timeout)
                code = result.returncode
                manifest['status'] = 'PASS' if code == 0 else 'FAIL'
                manifest['exit_code'] = code
            except subprocess.TimeoutExpired:
                code = 124
                manifest['status'] = 'FAIL'
                manifest['error'] = 'command timeout; inspect any child processes before continuing'
            except OSError as error:
                code = 2
                manifest['status'] = 'BLOCKED'
                manifest['error'] = str(error)
    manifest['duration_s'] = round(time.monotonic()-start, 3)
    (run/'data/run.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
    print(run)
    return code
if __name__ == '__main__': raise SystemExit(main())
