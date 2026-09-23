---
id: "TASK-032"
status: "planned"
execution_level: "standard"
execution_rationale: "Ajusta foco, layout e traduções do painel sem modificar regras de domínio."
specs: ["SPEC-001", "SPEC-004"]
depends_on: ["TASK-031"]
provides: ["accessible-planner-ui"]
consumes: ["live-day-refresh", "interface-locale-switching"]
write_scope: ["lib/planner_web/live/task_live/", "assets/css/", "priv/gettext/", "test/planner_web/live/task_live_test.exs"]
blockers: []
---

# 032 — Ajustar teclado, responsividade e mensagens do painel

## Entrada e limite

[SPEC-004](../specs/004-experiencia-e-acesso.md) CA-004-01 a CA-004-06 e [SPEC-001](../specs/001-idiomas.md) CA-I05/I06; consumir live-day-refresh. Referências interface, HEEx e Gettext.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Corrigir foco após ações, nomes acessíveis, apresentação em 360px e mensagens/plurais ausentes do painel. Preservar componentes gerados e dados digitados. Não mudar regras de domínio ou redesenhar autenticação.

## Aceite e teste de intenção

1. Fluxo principal opera por teclado em 360px e desktop, nos dois idiomas.
2. Falhas e estados vazios são anunciados e não escondem ações; conteúdo do usuário permanece igual.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
