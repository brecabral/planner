---
id: "TASK-023"
status: "planned"
execution_level: "standard"
execution_rationale: "Compõe devolução idempotente, restituição e ordem na mesma fronteira transacional."
specs: ["SPEC-002", "SPEC-003"]
depends_on: ["TASK-022"]
provides: ["return-to-backlog"]
consumes: ["planning-snapshot", "daily-quota-transaction", "select-today"]
write_scope: ["lib/planner/tasks.ex", "test/planner/tasks_test.exs"]
blockers: []
---

# 023 — Devolver ao backlog e restituir uma escolha

## Entrada e limite

[SPEC-002](../specs/002-planejamento-diario.md) RN05/RN07; consumir select-today e fronteira transacional. Referência Ecto.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Implementar hoje → backlog manual, restituição única e compactação das posições. Não enviar retorno manual para retry. Repetição no backlog é sem efeito; seleção vencida não restitui cota do dia novo.

## Aceite e teste de intenção

1. CA-002-05/07: retorno libera uma escolha uma vez; repetição concorrente não libera duas.
2. Disputa retorno/seleção respeita limite; erro reverte estado, posições e contador.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit e CI com cobertura mínima de 70%, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
