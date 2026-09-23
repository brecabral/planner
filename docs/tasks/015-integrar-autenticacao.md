---
id: "TASK-015"
status: "planned"
execution_level: "advanced"
execution_rationale: "Sessão e invalidação de processos conectados são fronteiras sensíveis de autorização."
specs: ["SPEC-001", "SPEC-005"]
depends_on: ["TASK-009"]
provides: ["authenticated-user-scope"]
consumes: ["auth-scaffold", "interface-locale-switching"]
write_scope: ["lib/planner/accounts*", "lib/planner_web/user_auth.ex", "lib/planner_web/live/user_live/", "lib/planner_web/controllers/user_session_controller.ex", "lib/planner_web/router.ex", "priv/gettext/", "test/planner/accounts*", "test/planner_web/"]
blockers: []
---

# 015 — Adequar sessões e telas de autenticação

## Entrada e limite

[SPEC-005](../specs/005-contas-e-acesso.md) CA-005-01/03/04/05 e mecanismo aprovado; consumir auth-scaffold. Referências Phoenix, LiveView e Gettext.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Ajustar somente diferenças entre fluxo gerado e política de entrada aprovada. Conectar hook de locale; traduzir textos. Verificar logout/expiração em LiveView conectada e troca de conta sem reaproveitar dados. Publicar o contrato Accounts.Scope e guardas de autenticação para produtoras.

## Aceite e teste de intenção

1. Entrada/confirmação/recuperação conforme decisão e logout têm testes de sucesso e rejeição.
2. Conexão anterior não opera após logout; duas contas mantêm scopes independentes e locale correto.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
