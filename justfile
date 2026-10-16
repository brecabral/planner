set shell := ["bash", "-euo", "pipefail", "-c"]
set positional-arguments

# List local developer and agent commands.
default:
    @just --list

# Start the persistent development database.
db-up:
    docker compose up --wait --wait-timeout 60 postgres

# Stop development services, preserving data.
db-down:
    docker compose down

# Delete development database data (explicit confirmation required).
[confirm("Delete all local development database data?")]
db-clean:
    docker compose down --volumes

# Inspect development database health.
db-status:
    docker compose ps

db-logs:
    docker compose logs --tail 100 postgres

# Start a separate disposable database for ExUnit.
db-test-up:
    docker compose --env-file /dev/null -f compose.test.yaml -p planner-test up --wait --wait-timeout 60

db-test-down:
    docker compose --env-file /dev/null -f compose.test.yaml -p planner-test down --volumes

db-test-clean: db-test-down

setup: db-up
    mix setup

run: db-up
    mix phx.server

console: db-up
    iex -S mix

migrate: db-up
    mix ecto.migrate

# Run ExUnit against the dedicated test database.
test *args: db-test-up
    bash scripts/test-env.sh mix test "$@"

# Elixir/Phoenix quality, JavaScript tests and dependency audit.
ci: db-test-up tooling-test
    bash scripts/test-env.sh mix ci
    just js-test
    npm --prefix assets audit --audit-level=high

precommit: db-test-up
    bash scripts/test-env.sh mix precommit

js-test:
    npm --prefix assets ci
    node --test assets/test/task_drag.test.mjs assets/js/account_theme.test.mjs

tooling-test:
    python3 scripts/test_compose_test.py
    python3 scripts/e2e_runner_test.py

# Build, run, collect evidence and clean isolated E2E resources.
e2e:
    bash scripts/e2e.sh

# Complete local code assessment, including browser tests.
check: ci e2e

# Read-only commands for every agent profile.
status:
    git status --short

diff:
    git diff --check
    git diff --stat
    git diff

tasks:
    rg -n '^(id|status|execution_level|depends_on|blockers):' docs/tasks

# Commit explicitly staged changes; never stages unrelated work.
commit message:
    git diff --cached --check
    git commit -m "$1"
