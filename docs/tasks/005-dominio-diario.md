---
id: "TASK-005"
status: "planned"
execution_level: "standard"
execution_rationale: "Adapta cadastro e consulta scoped do gerador, restringindo campos controlados pelo servidor."
specs: ["SPEC-002"]
depends_on: ["TASK-010"]
provides: ["task-scaffold"]
consumes: ["authenticated-user-scope", "experimental-crud-removed", "clean-database"]
write_scope: ["lib/planner/tasks.ex", "lib/planner/tasks/task.ex", "priv/repo/migrations/", "test/planner/tasks_test.exs", "test/support/fixtures/tasks_fixtures.ex"]
blockers: []
---

# 005 — Gerar tarefas com cadastro simples no backlog

## Entrada e limite

[SPEC-002](../specs/002-planejamento-diario.md) RN01/RN02/RN06; consumir authenticated-user-scope. Referências Phoenix e Ecto.

## Scaffold

```sh
mix phx.gen.context Tasks Task tasks title:string kind:enum:backlog:today:retry scheduled_for:date position:integer completed_on:date --scope user
```

Consultar `mix help` antes de executar. O comando pertence à implementação desta tarefa; não foi executado no planejamento.

## Ajustes desta entrega

Reusar contexto/schema/fixtures scoped. Ajustar validate_required gerado: só título é obrigatório na entrada; datas/posição são opcionais no backlog. Inicializar kind=backlog no servidor; não permitir cast de proprietário, kind, datas ou posição vindos do usuário. Restringir CRUD público a cadastro/consulta/changeset, removendo edição/exclusão genéricas. Não implementar seleção ou conclusão aqui.

Na migration gerada, exigir proprietário e texto obrigatório não nulos; no changeset, atribuir proprietário a partir do scope.

## Aceite e teste de intenção

1. CA-002-01: cadastro apenas por título persiste backlog sem datas; inválido não persiste.
2. CA-002-08 parcial: cadastro/consulta não atravessa conta, mesmo com attrs forjados.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
