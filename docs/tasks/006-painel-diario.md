---
id: "TASK-006"
status: "planned"
execution_level: "standard"
execution_rationale: "Integra LiveViews geradas a APIs existentes e remove superfícies CRUD fora do escopo."
specs: ["SPEC-002", "SPEC-004"]
depends_on: ["TASK-025"]
provides: ["task-live-scaffold"]
consumes: ["task-scaffold", "authenticated-user-scope", "interface-locale-switching"]
write_scope: ["lib/planner_web/live/task_live/", "lib/planner_web/router.ex", "lib/planner_web/controllers/page*", "priv/gettext/", "test/planner_web/live/task_live_test.exs"]
blockers: []
---

# 006 — Gerar LiveViews e expor cadastro simples

## Entrada e limite

[SPEC-004](../specs/004-experiencia-e-acesso.md) RN01/RN04, [SPEC-002](../specs/002-planejamento-diario.md) RN01; consumir task-scaffold e authenticated-user-scope. Referências Phoenix, LiveView, HEEx e Gettext.

## Scaffold

```sh
mix phx.gen.live Tasks Task tasks title:string --no-context --scope user
```

Consultar `mix help` antes de executar. O comando pertence à implementação desta tarefa; não foi executado no planejamento.

## Ajustes desta entrega

Reusar TaskLive.Index/Form como base, rotas dentro da sessão autenticada e locale hook. --no-context preserva schema/migrations/contexto existentes. Retirar Show/edição/exclusão e handlers/testes gerados correspondentes; manter listagem de backlog e cadastro só de título, trocando chamadas pelo contrato existente. Não expor CRUD genérico nem deixar testes gerados falhando. Traduzir apenas textos desta entrega.

## Aceite e teste de intenção

1. Conta autenticada cadastra título e vê backlog; visitante não entra.
2. Recarga e erro de título funcionam; não há rotas/controles de edição ou exclusão.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
