"""Exercise runner failure propagation and evidence ordering without Docker."""

import concurrent.futures
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


class RunnerTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        (self.root / "scripts").mkdir()
        shutil.copy(Path(__file__).with_name("e2e.sh"), self.root / "scripts/e2e.sh")
        docker = self.root / "docker"
        docker.write_text('''#!/usr/bin/env python3
import json, os, pathlib, signal, sys
args = sys.argv[1:]
project = args[args.index("-p") + 1]
with open(pathlib.Path(__file__).parent / (project + ".jsonl"), "a") as log:
    log.write(json.dumps(args) + "\\n")
phase = "build" if "build" in args else "startup" if "--wait" in args else "tests" if "up" in args else "copy" if "cp" in args else "cleanup" if "down" in args else "logs"
if os.environ.get("FAIL_PHASE") == phase:
    sys.exit(23)
if phase == "copy":
    pathlib.Path(args[-1]).mkdir(exist_ok=True)
if phase == "build" and os.environ.get("INTERRUPT"):
    os.kill(os.getppid(), signal.SIGTERM)
''')
        docker.chmod(0o755)

    def run_runner(self, **options):
        return subprocess.run(
            ["bash", "scripts/e2e.sh"], cwd=self.root,
            env={**os.environ, "PATH": f"{self.root}:{os.environ['PATH']}", **options},
            capture_output=True, text=True, timeout=20,
        )

    def evidence(self):
        artifacts = next((self.root / "tmp/e2e").iterdir())
        project = (artifacts / "project.txt").read_text().strip()
        calls = [json.loads(line) for line in (self.root / f"{project}.jsonl").read_text().splitlines()]
        self.assertIn("down", calls[-1])
        self.assertTrue((artifacts / "containers.log").exists())
        return artifacts, calls

    def test_success_collects_before_cleanup(self):
        self.assertEqual(self.run_runner().returncode, 0)
        artifacts, calls = self.evidence()
        self.assertEqual(sum("cp" in call for call in calls), 2)
        self.assertTrue((artifacts / "playwright-report").is_dir())
        self.assertEqual((artifacts / "exit-code.txt").read_text(), "0\n")

    def test_failures_are_not_hidden_by_cleanup(self):
        for phase in ("build", "startup", "tests", "copy", "logs", "cleanup"):
            with self.subTest(phase=phase):
                result = self.run_runner(FAIL_PHASE=phase)
                self.assertEqual(result.returncode, 23 if phase in ("build", "startup", "tests") else 1)
        for path in (self.root / "tmp/e2e").iterdir():
            self.assertNotEqual((path / "exit-code.txt").read_text(), "0\n")

    def test_termination_cleans_resources(self):
        self.assertEqual(self.run_runner(INTERRUPT="1").returncode, 143)
        self.evidence()

    def test_concurrent_runs_do_not_share_resources(self):
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
            results = list(pool.map(lambda _: self.run_runner(), range(2)))
        self.assertTrue(all(result.returncode == 0 for result in results))
        paths = list((self.root / "tmp/e2e").iterdir())
        self.assertEqual(len(paths), 2)
        projects = {(path / "project.txt").read_text() for path in paths}
        self.assertEqual(len(projects), 2)


if __name__ == "__main__":
    unittest.main()
