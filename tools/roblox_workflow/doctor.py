"""Report build/capture dependencies without installing or launching Studio."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]

def inspect_tool(name, directories):
    executable = shutil.which(name, path=os.pathsep.join([*directories, os.environ.get('PATH', '')]))
    if not executable:
        source = 'ffmpeg.org' if name in ('ffmpeg', 'ffprobe') else 'roblox/tool-versions.json'
        return {'status': 'BLOCKED', 'reason': f'{name} not found; install from {source} or add its directory with --tool-dir'}
    try:
        result = subprocess.run([executable, '-version' if name in ('ffmpeg','ffprobe') else '--version'],
                                capture_output=True, text=True, timeout=10)
        output = (result.stdout + result.stderr).splitlines()
        return {'status': 'PASS' if result.returncode == 0 else 'FAIL',
                'version': output[0] if output else '', 'path': executable}
    except (OSError, subprocess.SubprocessError) as error:
        return {'status': 'BLOCKED', 'reason': str(error)}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--tool-dir', action='append', default=[])
    parser.add_argument('--require-recording', action='store_true')
    args = parser.parse_args()
    checks = {'python': {'status': 'PASS' if sys.version_info >= (3,12) else 'BLOCKED', 'version': sys.version.split()[0]}}
    for name in ['rojo', 'stylua', 'luau', 'luau-lsp', 'ffmpeg', 'ffprobe']:
        # Luau has no reliable --version flag: availability is separate from compilation proof.
        if name == 'luau':
            path = shutil.which(name, path=os.pathsep.join([*args.tool_dir, os.environ.get('PATH','')]))
            compiler = shutil.which('luau-compile', path=os.pathsep.join([*args.tool_dir, os.environ.get('PATH','')]))
            checks[name] = {'status': 'PASS' if path and compiler else 'BLOCKED', 'reason': 'Executable discovery only; run roblox/tests/run.py to prove compilation and behavior'}
        else:
            checks[name] = inspect_tool(name, args.tool_dir)
    pins = json.loads((ROOT / 'roblox/tool-versions.json').read_text(encoding='utf-8'))
    for name in ['rojo','stylua','luau-lsp']:
        if checks[name]['status'] == 'PASS' and pins[name]['version'] not in checks[name]['version']:
            checks[name]['status'] = 'FAIL'
            checks[name]['reason'] = 'Version differs from roblox/tool-versions.json'
    studio_root = Path(os.environ.get('LOCALAPPDATA', '')) / 'Roblox/Versions'
    try:
        studios = sorted(studio_root.glob('*/RobloxStudioBeta.exe')) if studio_root.is_dir() else []
    except OSError:
        studios = []
    checks['studio'] = {'status': 'DISCOVERED' if studios else 'BLOCKED',
                        'reason': 'Installation discovery only; test current session/sign-in with supported app tools' if studios else 'Studio installation absent or inaccessible to this process; no session proven'}
    checks['automation_adapter'] = {'status': 'NOT_RUN', 'reason': 'No tested Studio RPC adapter is installed by this kit. Use trusted available tools; see automation contract.'}
    required = ['python','rojo','stylua','luau','luau-lsp'] + (['ffmpeg','ffprobe'] if args.require_recording else [])
    code = 0 if all(checks[name]['status'] == 'PASS' for name in required) else 2
    print(json.dumps({'scope':'local tooling discovery only', 'checks':checks, 'exit_code':code}, indent=2))
    return code

if __name__ == '__main__':
    raise SystemExit(main())
