---
id: "TASK-018"
status: "planned"
execution_level: "standard"
execution_rationale: "Modela vínculos muitos-para-muitos com unicidade e compatibilidade de proprietário."
specs: ["SPEC-006"]
depends_on: ["TASK-005"]
provides: ["task-label-storage"]
consumes: ["task-scaffold", "user-label-catalog"]
write_scope: ["lib/planner/tasks/task_label.ex", "lib/planner/tasks/task.ex", "lib/planner/labels/label.ex", "priv/repo/migrations/", "test/planner/task_label_test.exs"]
blockers: []
---

# 018 — Criar a relação muitos-para-muitos de labels

## Entrada e limite

[SPEC-006](../specs/006-labels.md) RN02/RN03; consumir task-scaffold e user-label-catalog. Referência Ecto.

## Scaffold

```sh
mix phx.gen.schema Tasks.TaskLabel task_labels task_id:references:tasks label_id:references:labels user_id:references:users --no-scope
```

Consultar `mix help` antes de executar. O comando pertence à implementação desta tarefa; não foi executado no planejamento.

## Ajustes desta entrega

Ajustar associação gerada para many_to_many e constraints: vínculo único, FKs válidas e proprietário compatível nos dois lados. Se usar FKs compostas, criar índices necessários nesta migration. Não criar CRUD público de vínculo nem formulário.

## Aceite e teste de intenção

1. Persistir duas labels próprias para uma tarefa funciona; repetição não duplica vínculo.
2. Constraints/validações impedem associação com tarefa ou label de outro proprietário.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit e CI com cobertura mínima de 70%, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
