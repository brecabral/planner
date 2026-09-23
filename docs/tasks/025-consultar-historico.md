---
id: "TASK-025"
status: "planned"
execution_level: "standard"
execution_rationale: "Consulta conclusões do proprietário com preload e desempate estável."
specs: ["SPEC-003", "SPEC-006"]
depends_on: ["TASK-007"]
provides: ["history-query"]
consumes: ["complete-task", "task-label-storage"]
write_scope: ["lib/planner/tasks.ex", "test/planner/tasks_test.exs"]
blockers: []
---

# 025 — Consultar conclusões com labels e ordem estável

## Entrada e limite

[SPEC-003](../specs/003-dia-e-historico.md) RN06 e [SPEC-006](../specs/006-labels.md) RN05; consumir complete-task e task-label-storage. Referência Ecto.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Adicionar consulta histórica com proprietário explícito com preload de labels e ordenação por data/ID decrescentes. Não criar edição/reabertura/exclusão nem recalcular datas originais de conclusão.

## Aceite e teste de intenção

1. CA-003-06: recarga/reinício mantém registros, datas e desempate.
2. CA-006-05: labels preservadas; uma conta nunca recebe histórico de outra.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit e CI com cobertura mínima de 70%, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
