---
id: "TASK-029"
status: "planned"
execution_level: "standard"
execution_rationale: "Converte ações de teclado em permutações e recupera a lista após conflito."
specs: ["SPEC-002", "SPEC-004"]
depends_on: ["TASK-028"]
provides: ["planning-order-ui"]
consumes: ["planning-selection-ui", "reorder-today"]
write_scope: ["lib/planner_web/live/task_live/index.ex", "priv/gettext/", "test/planner_web/live/task_live_test.exs"]
blockers: []
---

# 029 — Adicionar subir e descer prioridades

## Entrada e limite

[SPEC-002](../specs/002-planejamento-diario.md) CA-002-04/06 e [SPEC-004](../specs/004-experiencia-e-acesso.md) RN03; consumir planning-selection-ui e reorder-today.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Adicionar controles acessíveis de subir/descer que enviem permutação completa ao contexto. Recarregar conjunto após conflito de outra aba. Não usar drag-and-drop como única operação.

## Aceite e teste de intenção

1. Teclado reordena três tarefas e recarga preserva ordem; extremidades não oferecem movimento impossível.
2. Conjunto antigo é rejeitado e atualizado sem alterar cota.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
