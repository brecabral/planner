---
id: "TASK-033"
status: "planned"
execution_level: "standard"
execution_rationale: "Integra configuração externa e mailer de produção ao fluxo de autenticação aprovado."
specs: ["SPEC-005"]
depends_on: ["TASK-011"]
provides: ["production-runtime"]
consumes: ["release-scaffold", "authenticated-user-scope"]
write_scope: ["config/runtime.exs", ".env.example", "README.md", "test/planner/"]
blockers: []
---

# 033 — Configurar runtime e entrega de e-mail de produção

## Entrada e limite

[SPEC-005](../specs/005-contas-e-acesso.md) mecanismo de entrada aprovado e PRD CA12; consumir release-scaffold e authenticated-user-scope.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Ajustar variáveis obrigatórias para endpoint, banco e mailer exigido pelo fluxo aprovado; não fixar segredos. Documentar nomes/exemplos no README e .env.example. Não criar nova autenticação nem configurar hospedagem.

## Aceite e teste de intenção

1. Ausência de configuração obrigatória falha explicitamente sem revelar valores.
2. Mailer em teste envia confirmação/entrada conforme mecanismo aprovado; runtime usa configuração externa.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
