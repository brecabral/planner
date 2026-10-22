#!/usr/bin/env bash
set -euo pipefail

export MIX_ENV=test
export POSTGRES_USER=planner_test POSTGRES_PASSWORD=local_test_only
export POSTGRES_DB=planner_test POSTGRES_TEST_DB=planner_test
export POSTGRES_HOST=127.0.0.1 POSTGRES_PORT="${PLANNER_TEST_PORT:-55432}"
exec "$@"
