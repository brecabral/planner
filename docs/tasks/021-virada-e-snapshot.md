---
id: "TASK-021"
status: "planned"
execution_level: "advanced"
execution_rationale: "Virada, normalização e snapshot precisam compartilhar atomicidade e data com comandos concorrentes."
specs: ["SPEC-002", "SPEC-003"]
depends_on: ["TASK-017"]
provides: ["planning-snapshot"]
consumes: ["user-day-contract", "daily-quota-transaction", "timezone-settings"]
write_scope: ["lib/planner/tasks.ex", "lib/planner/user_transaction.ex", "test/planner/tasks_test.exs"]
blockers: []
---

# 021 — Normalizar a virada e consultar o planejamento

## Entrada e limite

[SPEC-003](../specs/003-dia-e-historico.md) RN02/RN03 e [SPEC-002](../specs/002-planejamento-diario.md) RN02/RN07; consumir timezone-settings e daily-quota-transaction. Referência Ecto.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Na fronteira transacional, mover pendências vencidas para retry e limpar posições correntes. Entregar snapshot scoped de backlog/hoje/retry, dia e cota, sem histórico ainda. A normalização é reutilizada pelos próximos comandos e não depende de timer. Comandos de tela antiga recebem conflito quando aplicável.

## Aceite e teste de intenção

1. CA-003-01/04/06: virar o dia move somente pendências daquele usuário para retry sem conclusão; nova leitura é idempotente.
2. Parada/reinício e datas já usadas preservam cota; snapshot não mostra task em duas coleções.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
