---
id: "TASK-015"
status: "planned"
execution_level: "advanced"
execution_rationale: "Concilia scaffold com identidade e dados existentes, tokens e sessão sem sobrescrever a base."
specs: ["SPEC-005"]
depends_on: ["TASK-044"]
provides: ["authenticated-user-scope"]
consumes: ["pending-task-deletion-ui"]
write_scope: ["lib/planner/accounts.ex", "lib/planner/accounts/", "lib/planner_web/user_auth.ex", "lib/planner_web/live/user_live/", "lib/planner_web/controllers/user*", "lib/planner_web/router.ex", "lib/planner_web/components/", "config/", "priv/repo/migrations/", "priv/gettext/", "test/planner/accounts*", "test/planner_web/", "test/support/", "mix.exs", "mix.lock", "docs/tasks/015-integrar-autenticacao.md"]
blockers: []
---

# 015 — Gerar e adaptar autenticação Phoenix por magic link

## Objetivo e entradas

Produzir auth/scope/tokens/notifier e telas de cadastro/login do Phoenix com magic link, exclusivamente uma vez. Ler SPEC-005 RN08–RN09/RN13, CA-005-07–08/11, design D17, Accounts/User, migration de users, config e referências Phoenix/Ecto/LiveView/Gettext/testes.

## Scaffold e adaptação

Ajuda `mix help phx.gen.auth` consultada em 11/10/2026. Comando de geração: `mix phx.gen.auth Accounts User users --live`. Revisar conflitos antes de aceitar sobrescrita; obter o scaffold em cópia de trabalho isolada se necessário e integrar deliberadamente ao contexto/schema existentes. Não apagar banco, regenerar tarefas/labels, substituir IDs ou editar migrations aplicadas. Converter a migration gerada para alteração aditiva de `users` e criação da tabela de tokens; acomodar `identifier` legado e e-mail ausente só no legado, sem criar e-mail falso.

## Aceite e testes

1. Cadastro aberto cria conta por e-mail normalizado único; link confirma posse e autentica. Tokens seguem hash/validade de 15 minutos/revogação do template instalado; reuso, expiração e consumo concorrente são testados.
2. Gerador pode produzir senha/settings; remover rotas/telas/API web de senha e funcionalidades fora de SPEC-005, preservando as proteções do fluxo magic link. Não criar protocolo próprio.
3. Logout, sessão renovada, CSRF e helpers/scope gerados têm testes pertinentes. Login/cadastro/e-mails traduzidos via Gettext.
4. Migration sobre base legada preserva IDs, FKs e dados; contas novas não compartilham default. Fixtures não dependem de seed global. Entrega valida auth em rotas próprias; proteção do painel e redirecionamentos globais são da TASK-045. Não publicar esta etapa intermediária.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.
