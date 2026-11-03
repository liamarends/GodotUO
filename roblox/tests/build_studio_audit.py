"""Build an isolated Studio fixture place. Production Rojo mapping stays unchanged."""
import argparse
import json
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--rojo', required=True)
parser.add_argument('--players', type=int, choices=(1, 2, 4), default=1)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
build = root.parent / 'build'
build.mkdir(exist_ok=True)
entry = (root / 'src/server/init.server.luau').read_text()
entry = entry.replace('Game.new(Map.build(), action, event)',
                      'local session = Game.new(Map.build(), action, event)\n'
                      'task.spawn(function() require(script.Audit)(session) end)')
(build / 'audit.server.luau').write_text(entry)
project = json.loads((root / 'default.project.json').read_text())
tree = project['tree']
tree['ReplicatedStorage']['Shared']['$path'] = str(root / 'src/shared')
tree['StarterPlayer']['StarterPlayerScripts']['Client']['$path'] = str(root / 'src/client')
server = {'$path': str(build / 'audit.server.luau'), '$attributes': {'AuditPlayers': args.players}}
for file in (root / 'src/server').glob('*.luau'):
    if file.name != 'init.server.luau':
        server[file.stem] = {'$path': str(file)}
server['Audit'] = {'$path': str(root / 'tests/StudioAudit.luau')}
tree['ServerScriptService']['Server'] = server
project_file = build / 'audit.project.json'
project_file.write_text(json.dumps(project, indent=2))
subprocess.run([args.rojo, 'build', str(project_file), '-o', str(build / 'house-audit.rbxlx')], check=True)
