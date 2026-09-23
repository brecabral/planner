---
id: "TASK-031"
status: "planned"
execution_level: "standard"
execution_rationale: "Gerencia timer e reconexão LiveView usando o snapshot e contrato de dia existentes."
specs: ["SPEC-003", "SPEC-004"]
depends_on: ["TASK-030"]
provides: ["live-day-refresh"]
consumes: ["history-ui", "planning-snapshot", "user-day-contract"]
write_scope: ["lib/planner_web/live/task_live/index.ex", "test/planner_web/live/task_live_test.exs"]
blockers: []
---

# 031 — Atualizar o painel na virada e reconexão

## Entrada e limite

[SPEC-003](../specs/003-dia-e-historico.md) RN07, CA-003-01/02/04; consumir history-ui e planning-snapshot. Referência LiveView.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Adicionar verificação periódica somente na montagem conectada, no prazo aprovado. Reconsultar snapshot/dia após timer e reconexão; não implementar transição no processo web. Não duplicar timers.

## Aceite e teste de intenção

1. Relógio controlado atravessa virada: pendências aparecem em retry e cota da data nova é exibida.
2. Reconexão/troca de fuso segue contrato e não interfere no locale ou usuário de outra sessão.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
