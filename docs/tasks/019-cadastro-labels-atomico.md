---
id: "TASK-019"
status: "planned"
execution_level: "standard"
execution_rationale: "Compõe tarefa, labels e vínculos em uma transação com rollback integral."
specs: ["SPEC-002", "SPEC-006"]
depends_on: ["TASK-018"]
provides: ["task-create-with-labels"]
consumes: ["task-label-storage", "user-label-catalog"]
write_scope: ["lib/planner/tasks.ex", "test/planner/tasks_test.exs", "test/support/fixtures/tasks_fixtures.ex"]
blockers: []
---

# 019 — Cadastrar tarefa e labels em uma transação

## Entrada e limite

[SPEC-006](../specs/006-labels.md) RN02–RN05, CA-006-01 a CA-006-04; consumir task-label-storage e catálogo transacional. Referência Ecto.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Estender cadastro por título para aceitar IDs próprios e nomes de novas labels. Compor criação de tarefa/labels/vínculos em uma transação; normalizar IDs repetidos. Não criar edição nem seleção para hoje.

## Aceite e teste de intenção

1. Sem labels, com várias existentes e com existentes+novas produz vínculos corretos.
2. Título/nome inválido, ID alheio e falha de persistência revertem toda a tentativa.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
