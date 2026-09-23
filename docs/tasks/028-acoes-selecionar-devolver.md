---
id: "TASK-028"
status: "planned"
execution_level: "standard"
execution_rationale: "Integra duas transições existentes ao painel com tratamento de limite, conflito e falha."
specs: ["SPEC-002", "SPEC-004"]
depends_on: ["TASK-027"]
provides: ["planning-selection-ui"]
consumes: ["planning-panel-read", "select-today", "return-to-backlog"]
write_scope: ["lib/planner_web/live/task_live/index.ex", "priv/gettext/", "test/planner_web/live/task_live_test.exs"]
blockers: []
---

# 028 — Ligar seleção e devolução no painel

## Entrada e limite

[SPEC-002](../specs/002-planejamento-diario.md) CA-002-02/03/05 e [SPEC-004](../specs/004-experiencia-e-acesso.md) RN03–RN05; consumir planning-panel-read, select-today e return-to-backlog.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Adicionar ações trazer para hoje no backlog/retry e devolver ao backlog em hoje. Recarregar snapshot após sucesso/conflito; mostrar processamento, limite e falha sem falso sucesso. IDs em eventos não substituem scope.

## Aceite e teste de intenção

1. Selecionar consome; devolver libera uma vez e volta ao backlog. Retry só recebe virada automática.
2. Quarta escolha e evento forjado falham sem estado visual incorreto.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
