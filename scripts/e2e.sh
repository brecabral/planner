#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
mkdir -p tmp/e2e
artifacts=$(mktemp -d "$PWD/tmp/e2e/run-XXXXXXXX")
project="planner-e2e-$(basename "$artifacts" | tr '[:upper:]' '[:lower:]')"
compose=(docker compose --env-file /dev/null -p "$project" -f compose.e2e.yaml)
printf '%s\n' "$project" > "$artifacts/project.txt"
printf 'E2E artifacts: %s\n' "$artifacts"
tests_started=false

cleanup() {
  result=$?
  trap - EXIT INT TERM
  set +e
  "${compose[@]}" logs --no-color > "$artifacts/containers.log" 2>&1
  collect_status=$?
  if "$tests_started"; then
    "${compose[@]}" cp playwright:/e2e/playwright-report "$artifacts/playwright-report"
    report_status=$?
    "${compose[@]}" cp playwright:/e2e/test-results "$artifacts/test-results"
    results_status=$?
    if (( report_status != 0 || results_status != 0 )); then collect_status=1; fi
  fi
  "${compose[@]}" down --volumes --remove-orphans --timeout 10 > "$artifacts/cleanup.log" 2>&1
  cleanup_status=$?
  if (( result == 0 && (collect_status != 0 || cleanup_status != 0) )); then result=1; fi
  printf '%s\n' "$result" > "$artifacts/exit-code.txt"
  printf 'E2E exit code: %s; artifacts: %s\n' "$result" "$artifacts"
  exit "$result"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

"${compose[@]}" build 2>&1 | tee "$artifacts/build.log"
"${compose[@]}" up -d --wait --wait-timeout 180 app 2>&1 | tee "$artifacts/startup.log"
tests_started=true
timeout --signal=TERM --kill-after=30s 10m "${compose[@]}" up --no-deps --abort-on-container-exit --exit-code-from playwright playwright 2>&1 | tee "$artifacts/tests.log"
