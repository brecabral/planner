---
id: "TASK-014"
status: "planned"
execution_level: "standard"
execution_rationale: "Integra seletor, sessão protegida, redirecionamento e catálogos da interface base."
specs: ["SPEC-001"]
depends_on: ["TASK-013"]
provides: ["interface-locale-switching"]
consumes: ["http-locale", "liveview-locale"]
write_scope: ["lib/planner_web/controllers/locale_controller.ex", "lib/planner_web/router.ex", "lib/planner_web/components/layouts*", "priv/gettext/", "test/planner_web/"]
blockers: []
---

# 014 — Adicionar seletor e traduções da interface base

## Entrada e limite

[SPEC-001](../specs/001-idiomas.md) CA-I01 a CA-I06; consumir http-locale e liveview-locale. Referências HEEx, formulários e Gettext.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Adicionar seletor, atualização de sessão protegida por CSRF, redirecionamento interno seguro e lang correspondente. Traduzir apenas interface existente; telas futuras traduzem seus próprios textos.

## Aceite e teste de intenção

1. Teclado permite mudar idioma; navegação/recarga/reconexão preservam preferência.
2. Locale inválido mantém fallback; erros e plural usados na base passam nos dois idiomas.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
