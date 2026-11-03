"""Compile every shipped Luau source; run actual rule/service code against bounded mocks.

Usage: python roblox/tests/run.py --luau PATH/luau --compiler PATH/luau-compile
This does NOT emulate Roblox physics, replication, UI, or the live purchase platform.
"""
from pathlib import Path
import argparse
import subprocess

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--luau', default='luau')
parser.add_argument('--compiler', default='luau-compile')
args = parser.parse_args()
files = sorted(root.joinpath('src').rglob('*.luau'))
subprocess.run([args.compiler, '--null', *map(str, files)], check=True)
print(f'Compiled {len(files)} shipped Luau files.', flush=True)
fixture = root.joinpath('tests/Regression.luau').read_text(encoding='utf-8')
for token, path in {
    'CONFIG': 'shared/GameConfig.luau',
    'RULES': 'shared/Rules.luau',
    'INVENTORY': 'server/Inventory.luau',
    'GAME': 'server/Game.luau',
    'FURNITURE': 'server/Furniture.luau',
}.items():
    source = root.joinpath('src', path).read_text(encoding='utf-8')
    fixture = fixture.replace(f'-- INSERT_{token}', source)
out = root.parent.joinpath('build')
out.mkdir(exist_ok=True)
generated = out.joinpath('regression.generated.luau')
generated.write_text(fixture, encoding='utf-8')
subprocess.run([args.luau, str(generated)], check=True)
