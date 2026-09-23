---
id: "TASK-013"
status: "planned"
execution_level: "standard"
execution_rationale: "Aplica locale por processo LiveView na montagem e reconexão, sem estado global."
specs: ["SPEC-001"]
depends_on: ["TASK-001"]
provides: ["liveview-locale"]
consumes: ["http-locale"]
write_scope: ["lib/planner_web/live/locale_hook.ex", "test/planner_web/live/locale_hook_test.exs", "test/support/"]
blockers: []
---

# 013 — Aplicar locale na montagem e reconexão LiveView

## Entrada e limite

[SPEC-001](../specs/001-idiomas.md) RN03/RN04; consumir http-locale. Referências Gettext e LiveView.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Adicionar on_mount reaproveitável que leia o locale da sessão e o aplique ao processo. Usar LiveView de teste; não gerar tela de produto para testar o hook.

## Aceite e teste de intenção

1. CA-I02/03: montar, reconectar e manter duas sessões com locales diferentes sem interferência.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
