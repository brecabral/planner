---
id: "TASK-026"
status: "planned"
execution_level: "standard"
execution_rationale: "Integra seleção múltipla e criação de labels ao formulário e cadastro atômico existentes."
specs: ["SPEC-004", "SPEC-006"]
depends_on: ["TASK-006"]
provides: ["task-label-form"]
consumes: ["task-live-scaffold", "task-create-with-labels", "user-label-catalog"]
write_scope: ["lib/planner_web/live/task_live/form.ex", "priv/gettext/", "test/planner_web/live/task_live_test.exs"]
blockers: []
---

# 026 — Adicionar múltiplas labels ao formulário gerado

## Entrada e limite

[SPEC-006](../specs/006-labels.md) CA-006-01 a CA-006-04; consumir task-live-scaffold e task-create-with-labels. Referências formulários e LiveView.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Estender formulário gerado com seleção de labels próprias e nomes de novas labels, enviando uma única chamada ao cadastro atômico. Reusar to_form e componentes existentes. Não criar tela separada de CRUD de labels.

## Aceite e teste de intenção

1. Selecionar várias existentes e criar novas funciona; erro não deixa registros parciais.
2. Formulário não lista labels alheias; ID forjado é rejeitado pelo contexto.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit e CI com cobertura mínima de 70%, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
