"""Exercise discovery and preservation of real user folders without Godot."""
import contextlib
import importlib.util
import io
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("agent_skills_run", Path(__file__).with_name("run.py"))
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)


class SkillSetupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="guo-agent-test-")
        self.addCleanup(self.temp.cleanup)
        root = Path(self.temp.name)
        self.source = root / ".claude" / "skills"
        self.link = root / ".agents" / "skills"
        self.skill = self.source / "sample" / "SKILL.md"
        self.skill.parent.mkdir(parents=True)
        self.skill.write_text('---\nname: sample\ndescription: "Test skill"\n---\nInstructions\n', encoding="utf-8")
        for name, value in (("ROOT", root), ("SOURCE", self.source), ("LINK", self.link)):
            scope = patch.object(runner, name, value)
            scope.start()
            self.addCleanup(scope.stop)
        # Unlink before TemporaryDirectory cleanup (including Windows junctions).
        self.addCleanup(self.remove_discovery_link)

    def remove_discovery_link(self):
        if runner.is_link(self.link):
            runner.remove_link()

    def call(self, *args):
        with patch("sys.argv", ["run.py", *args]), contextlib.redirect_stdout(io.StringIO()):
            return runner.main()

    def test_manifests_validate_without_creating_a_link(self):
        self.assertEqual(self.call("--validate-only"), 0)
        self.assertFalse(self.link.exists())
        self.assertEqual(self.call("--check"), 1)

    def test_setup_is_repeatable_and_remove_preserves_source(self):
        original = self.skill.read_bytes()
        self.assertEqual(self.call(), 0)
        self.assertTrue(runner.points_at_source(self.link))
        self.assertEqual((self.link / "sample" / "SKILL.md").read_bytes(), original)
        self.assertEqual(self.call(), 0)
        self.assertEqual(self.call("--check"), 0)
        self.assertEqual(self.call("--remove"), 0)
        self.assertFalse(runner.is_link(self.link))
        self.assertEqual(self.skill.read_bytes(), original)

    def test_real_folder_is_never_replaced_or_removed(self):
        self.link.mkdir(parents=True)
        existing = self.link / "my-skill.txt"
        existing.write_text("user content", encoding="utf-8")
        self.assertEqual(self.call(), 1)
        self.assertEqual(self.call("--check"), 1)
        self.assertEqual(self.call("--remove"), 0)
        self.assertEqual(existing.read_text(encoding="utf-8"), "user content")

    def test_invalid_collection_does_not_get_linked(self):
        for body in ('---\nname: other\ndescription: valid\n---\n',
                     '---\nname: sample\ndescription: ""\n---\n',
                     '---\nname: sample\ndescription:\nmodel: sonnet\n---\n',
                     'no front matter'):
            with self.subTest(body=body):
                self.skill.write_text(body, encoding="utf-8")
                self.assertEqual(self.call("--validate-only"), 1)
                self.assertEqual(self.call(), 1)
                self.assertFalse(self.link.exists())

    def test_missing_and_empty_source_report_failure(self):
        with patch.object(runner, "SOURCE", Path(self.temp.name) / "missing"):
            self.assertEqual(self.call("--validate-only"), 1)
            self.assertEqual(self.call(), 1)
        empty = Path(self.temp.name) / "empty"
        empty.mkdir()
        with patch.object(runner, "SOURCE", empty):
            self.assertEqual(self.call("--validate-only"), 1)

    def test_wrong_link_is_repaired_without_modifying_its_target(self):
        other = Path(self.temp.name) / "other-skills"
        other.mkdir()
        sentinel = other / "keep.txt"
        sentinel.write_text("keep", encoding="utf-8")
        with patch.object(runner, "SOURCE", other):
            runner.make_link()
        self.assertEqual(self.call("--check"), 1)
        self.assertEqual(self.call(), 0)
        self.assertTrue(runner.points_at_source(self.link))
        self.assertEqual(sentinel.read_text(encoding="utf-8"), "keep")


if __name__ == "__main__":
    unittest.main()
