"""Exercise actual command outcomes, isolation and failure preservation."""
import json
import hashlib
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

HERE = Path(__file__).resolve().parent

class EvidenceTests(unittest.TestCase):
    def test_reference_integrity(self):
        root = HERE.parents[1] / 'reference/roblox-agent-workflow-kit'
        manifest = json.loads((root/'MANIFEST.json').read_text(encoding='utf-8'))
        for entry in manifest['files']:
            data = (root/entry['path']).read_bytes()
            self.assertEqual(len(data), entry['bytes'], entry['path'])
            self.assertEqual(hashlib.sha256(data).hexdigest(), entry['sha256'], entry['path'])

    def run_case(self, args, expected, status):
        with tempfile.TemporaryDirectory() as directory:
            result = subprocess.run([sys.executable, str(HERE/'run_evidence.py'), '--root', directory,
                                     '--scenario','unit.smoke','--revision','test-dirty', *args], capture_output=True, text=True, timeout=15)
            self.assertEqual(result.returncode, expected, result.stderr)
            manifests = list(Path(directory).glob('*/data/run.json'))
            self.assertEqual(len(manifests), 1)
            self.assertEqual(json.loads(manifests[0].read_text())['status'], status)
            return json.loads(manifests[0].read_text())

    def test_success(self):
        self.run_case(['--',sys.executable,'-c','print("verified command")'],0,'PASS')
    def test_failure(self):
        self.run_case(['--',sys.executable,'-c','raise SystemExit(7)'],7,'FAIL')
    def test_missing_program(self):
        self.run_case(['--','missing-roblox-tool-37a1'],2,'BLOCKED')
    def test_timeout(self):
        self.run_case(['--timeout','0.1','--',sys.executable,'-c','import time; time.sleep(5)'],124,'FAIL')
    def test_no_command(self):
        self.run_case([],0,'NOT_RUN')
    def test_invalid_timeout(self):
        for timeout in ['nan','inf','-1']:
            result = subprocess.run([sys.executable,str(HERE/'run_evidence.py'),'--root',tempfile.gettempdir(),
                                     '--scenario','unit.smoke','--revision','test','--timeout',timeout],capture_output=True,timeout=10)
            self.assertEqual(result.returncode,2)
    def test_checkout_rejected(self):
        result = subprocess.run([sys.executable,str(HERE/'run_evidence.py'),'--root',str(HERE),
                                 '--scenario','unit.smoke','--revision','test'],capture_output=True,timeout=10)
        self.assertEqual(result.returncode,2)

if __name__ == '__main__':
    unittest.main()
