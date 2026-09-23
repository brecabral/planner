---
id: "TASK-020"
status: "planned"
execution_level: "advanced"
execution_rationale: "Define bloqueio e contrato atômico reutilizado por todos os comandos; erro compromete cota e isolamento."
specs: ["SPEC-002", "SPEC-003"]
depends_on: ["TASK-019"]
provides: ["daily-quota-transaction"]
consumes: ["current-day", "task-scaffold", "default-user"]
write_scope: ["lib/planner/tasks/daily_plan.ex", "lib/planner/user_transaction.ex", "priv/repo/migrations/", "test/planner/user_transaction_test.exs"]
blockers: []
---

# 020 — Criar cota diária e fronteira transacional

## Objetivo e entrada

[SPEC-002](../specs/002-planejamento-diario.md) RN06/RN07 e [SPEC-003](../specs/003-dia-e-historico.md) RN01/RN03. Usar current-day e default-user. Ajustar migration: proprietário/data únicos, consumo 0–3, zero inicial e campos obrigatórios. Bloquear a linha do usuário antes de obter a cota da data capturada, protegendo também o conjunto vazio. Publicar fronteira para seleção, devolução, ordem e conclusão; não expor CRUD do contador nem implementar política de fuso.

## Scaffold

```sh
mix phx.gen.schema Tasks.DailyPlan daily_plans day:date used_choices:integer user_id:references:users --no-scope
```

Consultar `mix help` antes de executar; adaptar o resultado conforme o contrato acima.

## Aceite

1. Transações concorrentes serializam criação da cota vazia; rollback reverte consumo.
2. Reinício não zera registros; valores fora de 0–3 são rejeitados.

## Evidência e revisão

Pendentes. Registrar teste de intenção, precommit e CI com cobertura mínima de 70%, revisor independente, alvo/base, critérios, achados e integração.
