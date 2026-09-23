---
id: "TASK-022"
status: "planned"
execution_level: "standard"
execution_rationale: "Aplica seleção e limite na fronteira transacional com revalidação da data corrente."
specs: ["SPEC-002", "SPEC-003"]
depends_on: ["TASK-021"]
provides: ["select-today"]
consumes: ["planning-snapshot", "daily-quota-transaction"]
write_scope: ["lib/planner/tasks.ex", "test/planner/tasks_test.exs"]
blockers: []
---

# 022 — Selecionar tarefa e consumir uma escolha

## Objetivo e entrada

[SPEC-002](../specs/002-planejamento-diario.md) RN03/RN06/RN07. Consumir planning-snapshot e daily-quota-transaction. Implementar backlog/retry → hoje com débito atômico e última posição. Repetição em hoje não debita. Data e proprietário vêm do servidor. CA-002-02 completo, com conclusão, pertence à TASK-007.

## Aceite

1. Três seleções pendentes impedem uma quarta; disputa pela última vaga com conexões distintas tem um vencedor.
2. Falha reverte movimento/contador; repetição não duplica consumo.
3. Mudança de data entre tela e comando normaliza pendências e usa cota corrente sem reutilizar indevidamente escolhas anteriores.

## Evidência e revisão

Pendentes. Registrar teste de intenção, precommit e CI com cobertura mínima de 70%, revisor independente, alvo/base, critérios, achados e integração.
