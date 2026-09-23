---
id: "TASK-021"
status: "planned"
execution_level: "advanced"
execution_rationale: "Virada, normalização e snapshot precisam compartilhar atomicidade e data com comandos concorrentes."
specs: ["SPEC-002", "SPEC-003"]
depends_on: ["TASK-020"]
provides: ["planning-snapshot"]
consumes: ["current-day", "daily-quota-transaction"]
write_scope: ["lib/planner/tasks.ex", "lib/planner/user_transaction.ex", "test/planner/tasks_test.exs"]
blockers: []
---

# 021 — Normalizar a virada ao consultar ou executar comandos

## Objetivo e entrada

[SPEC-003](../specs/003-dia-e-historico.md) RN02/RN03/RN07 e [SPEC-002](../specs/002-planejamento-diario.md) RN02/RN07. Consumir current-day e daily-quota-transaction. Normalizar pendências vencidas para retry e limpar posições antes do snapshot/comando. Entregar listas de backlog/hoje/retry, data e cota do usuário padrão. Não usar timer, scheduler ou atualização automática de tela.

## Aceite

1. Mudar a data controlada e consultar move pendências anteriores para retry sem concluir; repetição é idempotente.
2. Depois de reinício, snapshot mantém cota e coleções coerentes; comando antigo é revalidado.

## Evidência e revisão

Pendentes. Registrar teste de intenção, precommit e CI com cobertura mínima de 70%, revisor independente, alvo/base, critérios, achados e integração.
