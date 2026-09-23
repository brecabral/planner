---
id: "TASK-016"
status: "planned"
execution_level: "standard"
execution_rationale: "Converte instante em data por fuso com relógio isolado nos testes e contrato de erro definido."
specs: ["SPEC-003"]
depends_on: ["TASK-004"]
provides: ["user-day-contract"]
consumes: ["user-timezone-storage"]
write_scope: ["lib/planner/day.ex", "config/config.exs", "mix.exs", "mix.lock", "test/planner/day_test.exs"]
blockers: []
---

# 016 — Calcular a data a partir do fuso do usuário

## Entrada e limite

[SPEC-003](../specs/003-dia-e-historico.md) RN01–RN03; consumir user-timezone-storage. Referências Elixir e testes.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Implementar uma função de cálculo de data por usuário/instante, com relógio controlável por teste sem estado global. Usar suporte de fuso existente; justificar biblioteca somente se necessário. Não alterar tarefas nem adicionar timer.

## Aceite e teste de intenção

1. CA-003-06: mesmo instante produz datas corretas em dois fusos e nas fronteiras UTC.
2. Ausência de fuso segue a política aprovada; testes não dependem da hora real.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
