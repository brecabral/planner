---
id: "TASK-020"
status: "planned"
execution_level: "advanced"
execution_rationale: "Define bloqueio e contrato atômico reutilizado por todos os comandos; erro compromete cota e isolamento."
specs: ["SPEC-002", "SPEC-003"]
depends_on: ["TASK-019"]
provides: ["daily-quota-transaction"]
consumes: ["user-day-contract", "task-scaffold", "authenticated-user-scope"]
write_scope: ["lib/planner/tasks/daily_plan.ex", "lib/planner/user_transaction.ex", "priv/repo/migrations/", "test/planner/user_transaction_test.exs"]
blockers: []
---

# 020 — Criar cota diária e fronteira transacional

## Entrada e limite

[SPEC-002](../specs/002-planejamento-diario.md) RN06/RN07 e [SPEC-003](../specs/003-dia-e-historico.md) RN03; consumir user-day-contract e task-scaffold. Referência Ecto.

## Scaffold

```sh
mix phx.gen.schema Tasks.DailyPlan daily_plans day:date used_choices:integer --scope user
```

Consultar `mix help` antes de executar. O comando pertence à implementação desta tarefa; não foi executado no planejamento.

## Ajustes desta entrega

Ajustar migration: unicidade usuário/data, contador entre 0 e 3 e inicial zero. Criar fronteira interna que bloqueie a linha do usuário antes de reler fuso/dia e localizar/criar a cota, protegendo também dia sem registro. Publicar operação transacional comum para seleção, retorno, ordem, conclusão e mudança de fuso. Não expor CRUD livre do contador.

## Aceite e teste de intenção

1. Transações concorrentes do mesmo usuário serializam mesmo com plano vazio; usuários diferentes mantêm cotas independentes.
2. Rollback reverte contador; reinício não zera consumo; restrições rejeitam valores fora do intervalo.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
