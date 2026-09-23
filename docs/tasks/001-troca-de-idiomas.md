---
id: "TASK-001"
status: "planned"
execution_level: "standard"
execution_rationale: "Integra sessão e Gettext no ciclo HTTP, com fallback e isolamento definidos."
specs: ["SPEC-001"]
depends_on: ["TASK-002"]
provides: ["http-locale"]
consumes: ["experimental-crud-removed"]
write_scope: ["lib/planner_web/plugs/locale.ex", "lib/planner_web/router.ex", "config/config.exs", "test/planner_web/plugs/locale_test.exs"]
blockers: ["Confirmar padrão, persistência em sessão e fallback da SPEC-001."]
---

# 001 — Aplicar locale na sessão HTTP

## Entrada e limite

[SPEC-001](../specs/001-idiomas.md) RN02–RN05; entrada: base sem CRUD. Referência Gettext.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Criar plug de locale usando Gettext existente. Ler preferência de sessão, validar allowlist e aplicar fallback aprovado. Não criar seletor nem hook LiveView.

## Aceite e teste de intenção

1. CA-I01/03/04 no HTTP: padrão, duas sessões independentes e locale inválido sem erro 500.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
