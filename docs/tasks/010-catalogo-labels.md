---
id: "TASK-010"
status: "planned"
execution_level: "standard"
execution_rationale: "Restringe catálogo gerado ao proprietário e oferece criação componível em transação."
specs: ["SPEC-006"]
depends_on: ["TASK-016"]
provides: ["user-label-catalog"]
consumes: ["default-user"]
write_scope: ["lib/planner/labels.ex", "lib/planner/labels/", "priv/repo/migrations/", "test/planner/labels_test.exs", "test/support/fixtures/labels_fixtures.ex"]
blockers: []
---

# 010 — Gerar o catálogo de labels do usuário padrão

## Entrada e limite

[SPEC-006](../specs/006-labels.md) RN01 e RN03; consumir default-user. Referências Phoenix e Ecto.

## Scaffold

```sh
mix phx.gen.context Labels Label labels name:string user_id:references:users --no-scope
```

Consultar `mix help` antes de executar. O comando pertence à implementação desta tarefa; não foi executado no planejamento.

## Ajustes desta entrega

Manter schema, migration, criação/consulta e fixtures com proprietário explícito gerados. Ajustar trim e validação de nome. Retirar update/delete não previstos; não criar interface CRUD de labels. Oferecer operação componível em transação externa, sem commit independente.

Na migration gerada, exigir proprietário e texto obrigatório não nulos; adaptar as APIs/fixtures para receber o usuário padrão e atribuir user_id no servidor, fora do cast de attrs.

## Aceite e teste de intenção

1. Nome vazio falha; listar/buscar retorna só labels próprias, sem aceitar proprietário vindo de attrs.
2. Reverter transação externa remove nova label e preserva anteriores.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit e CI com cobertura mínima de 70%, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
