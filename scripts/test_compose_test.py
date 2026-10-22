"""Exercise the real Just recipes with intercepted commands, never real Docker."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


class TestComposeTest(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        source = Path(__file__).resolve().parent.parent
        shutil.copy(source / "justfile", self.root / "justfile")
        (self.root / "scripts").mkdir()
        shutil.copy(source / "scripts/test-env.sh", self.root / "scripts/test-env.sh")
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.log = self.root / "calls.jsonl"
        for command in ("docker", "mix", "npm", "node", "python3"):
            executable = self.bin / command
            executable.write_text('''#!/bin/bash
printf '%s\\0' "${0##*/}" "$@" >> "$CALL_LOG"
printf '\\n' >> "$CALL_LOG"
if [[ "${0##*/}" == "$FAIL_COMMAND" ]]; then exit 23; fi
''')
            executable.chmod(0o755)

    def run_recipe(self, recipe, project=None, fail=""):
        self.log.unlink(missing_ok=True)
        env = {**os.environ, "PATH": f"{self.bin}:{os.environ['PATH']}",
               "CALL_LOG": str(self.log), "FAIL_COMMAND": fail}
        env.pop("COMPOSE_PROJECT_NAME", None)
        if project is not None:
            env["COMPOSE_PROJECT_NAME"] = project
        result = subprocess.run(["just", recipe], cwd=self.root, env=env,
                                capture_output=True, text=True, timeout=20)
        calls = [line.rstrip("\0").split("\0")
                 for line in self.log.read_text().splitlines()]
        return result, calls

    def assert_isolated(self, calls, action):
        docker_calls = [call for call in calls if call[0] == "docker"]
        self.assertEqual(len(docker_calls), 1)
        args = docker_calls[0][1:]
        self.assertEqual(args[0], "compose")
        self.assertIn("-p", args, "Compose must override inherited project identity")
        self.assertEqual(args[args.index("-p") + 1], "planner-test")
        self.assertEqual(args[args.index("-f") + 1], "compose.test.yaml")
        self.assertEqual(args[args.index("--env-file") + 1], "/dev/null")
        self.assertIn(action, args)
        if action == "down":
            self.assertIn("--volumes", args)

    def test_lifecycle_ignores_inherited_project(self):
        for project in (None, "planner", "unrelated-project"):
            for recipe, action in (("db-test-up", "up"), ("db-test-down", "down"),
                                   ("db-test-clean", "down")):
                with self.subTest(project=project, recipe=recipe):
                    result, calls = self.run_recipe(recipe, project)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assert_isolated(calls, action)

    def test_test_commands_use_isolated_startup(self):
        for recipe in ("test", "ci", "precommit"):
            with self.subTest(recipe=recipe):
                result, calls = self.run_recipe(recipe, "planner")
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assert_isolated(calls, "up")
                self.assertIn(["mix", recipe], calls)

    def test_tooling_failure_stops_complete_gate(self):
        for recipe in ("tooling-test", "ci", "check"):
            with self.subTest(recipe=recipe):
                result, calls = self.run_recipe(recipe, "planner", "python3")
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(["python3", "scripts/test_compose_test.py"], calls)
                self.assertFalse(any(call[0] == "mix" for call in calls))


if __name__ == "__main__":
    unittest.main()
