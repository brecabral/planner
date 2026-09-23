---
id: "TASK-009"
status: "planned"
execution_level: "standard"
execution_rationale: "Integra o scaffold de autenticação, migrations e scope do Phoenix ao projeto existente."
specs: ["SPEC-005"]
depends_on: ["TASK-014", "TASK-012"]
provides: ["auth-scaffold"]
consumes: ["clean-database", "interface-locale-switching"]
write_scope: ["lib/planner/accounts*", "lib/planner_web/user_auth.ex", "lib/planner_web/controllers/user_session_controller.ex", "lib/planner_web/live/user_live/", "lib/planner_web/router.ex", "lib/planner_web/components/layouts*", "priv/repo/migrations/", "config/", "mix.exs", "mix.lock", "test/"]
blockers: ["Resolver mecanismo e política de cadastro na SPEC-005; o comando pressupõe a base de autenticação por e-mail do Phoenix."]
---

# 009 — Gerar a base de autenticação Phoenix

## Entrada e limite

[SPEC-005](../specs/005-contas-e-acesso.md) RN01–RN04; base limpa e locale integrado. Referências Phoenix, Ecto e LiveView.

## Scaffold

```sh
mix phx.gen.auth Accounts User users --live --scope user
```

Consultar `mix help` antes de executar. O comando pertence à implementação desta tarefa; não foi executado no planejamento.

## Ajustes desta entrega

Integrar instruções emitidas pelo gerador, dependências exigidas, rotas e mailer existente. Preservar User, UserToken, Accounts.Scope, helpers e testes gerados. Configurar user como scope padrão; não duplicar user_id manualmente nas próximas gerações. Não customizar fuso nem criar tarefas/labels.

## Aceite e teste de intenção

1. Migrations em base limpa e testes gerados passam; sessão entrega current_scope com usuário autenticado.
2. Visitante não entra nas rotas geradas de gerenciamento. Scaffold não aprova publicação do cadastro.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
