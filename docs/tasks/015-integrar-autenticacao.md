---
id: "TASK-015"
status: "in_review"
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


## Entrega — 12/10/2026

Implementador `/root/implement_task015`, capacidade herdada suficiente para advanced; base `dedddb9e19418efcf087c2c100ad618a38d31ada`, branch `feat/ux`. TASK-044 integrada em `5f8049d`, conclusão operacional em `dedddb9`; SPEC-005 pronta e ausência de bloqueios conferidas. Retomado e preservado o scaffold local não commitado de Accounts/User/auth/tokens/notifier/telas/migration/fixtures. Não houve nova geração nem sobrescrita de identidade ou migrations anteriores.

Auth reutiliza os templates instalados Phoenix 1.8.13: token de e-mail aleatório com hash SHA-256 persistido, destinatário conferido, validade de 15 minutos, confirmação com revogação dos tokens anteriores, sessão de 14 dias e renovação gerada. A confirmação e o login serializam o consumo por lock de usuário e revalidam o token dentro da transação; apenas uma tentativa autentica. Cadastro normaliza espaços externos/caixa e aplica unicidade no changeset e banco. Não há senha/settings/alteração de e-mail expostos; mecanismos internos de scope, sessão e reautenticação foram preservados.

| Aceite | Evidência e resultado |
| --- | --- |
| 1 — cadastro/token/confirmação | `accounts_auth_test.exs` cobre normalização, unicidade, hash persistido, confirmação, revogação, expiração de 15 minutos, destinatário errado e reuso. `accounts_auth_concurrency_test.exs` força contenção PostgreSQL em conexões distintas, verifica o lock e comprova consumo único tanto de primeira confirmação quanto de login posterior, sem sleeps. |
| 2 — superfícies autorizadas | Router contém apenas cadastro, solicitação/consumo de magic link e logout. Testes web verificam ausência de campo de senha e rejeição de parâmetros de senha sem criar sessão. Nenhuma dependência de senha adicionada. |
| 3 — sessão/CSRF/tradução | `user_auth_test.exs` cobre renovação/limpeza de sessão e CSRF, remember-me, reemissão, plugs, hooks, scope e disconnect/logout. `authentication_flow_test.exs` cobre cadastro/login/confirmação, token usado/inválido, submissão ao controller, CSRF obrigatório, feedback genérico e e-mails/validação pt-BR. Catálogos default e errors completos para as mensagens novas. |
| 4 — migration/legado/fixtures | `accounts_auth_migration_test.exs` aplica todas as migrations anteriores em schema PostgreSQL descartável, insere default/tarefas/histórico/labels/vínculos/cota, aplica auth e compara todos os registros/IDs/timestamps. Duas contas reais distintas não herdam identifier; legado fica sem e-mail ou token. Testes legados e fixtures independentes continuam passando. |

Correções na retomada: alias User antes do primeiro uso (scaffold local não compilava), ajustes de Credo, traduções default/errors e metadado reverso `from` da nova migration. A migration original users já permitia identifier nulo; o `from: null: true` agora descreve esse estado real. Essa correção não altera o SQL de subida anteriormente aplicado; não houve rollback ou edição de migrations históricas. A versão final foi aplicada novamente em schema descartável no teste de preservação.

TDD/evidências iniciais: após correção do setup/alias, teste existente de flash revelou tradução ausente; teste específico de validação do e-mail falhou por mensagem em inglês antes da entrada pt-BR. Ambos passaram após completar os catálogos. Os demais testes de contratos do scaffold preservado passaram na primeira execução; não foi removido comportamento para fabricar fase vermelha. Conflito inicial da porta 5432 foi resolvido pela parada do container anterior pelo responsável, e o Compose do projeto iniciou/ficou saudável. Não houve alteração de infraestrutura do repositório.

Validações via RTK com ajuda Mix consultada: `mix test` direcionado (38 testes de auth/contexto/web e 2 de concorrência/migration aprovados naquele estágio); `mix gettext.extract --merge --no-fuzzy --locale pt_BR`; `mix precommit` final (**222 testes aprovados**, sem warnings). Gate final `mix ci`: **222 testes aprovados**, cobertura total **92,81%** (mínimo 70% preservado), Accounts **90,00%**, UserAuth **98,11%**, UserToken/Scope/notifier/login/controller **100%**; Credo estrito sem achados, assets compilados e npm audit sem vulnerabilidades. Cobertura anterior registrada na TASK-044: 93,77%; o conjunto cresceu com scaffold e helpers de testes; caminhos críticos de consumo, revogação e concorrência têm testes diretos. Cobertura de linhas não prova todos os ramos. `git diff --check` aprovado.

Autoavaliação pelo fluxo de review sobre alterações locais contra a base acima: contratos e diff inspecionados, sem achados bloqueantes no escopo TASK-015; **approved no escopo técnico validado**, com gates finais aprovados. Não é revisão independente e não avança o marco de review independente. Não houve validação em navegador real; LiveViewTest comprova HTML/eventos/submissão, não comportamento do navegador. Nenhum hook alterado. A entrega prepara auth nas rotas próprias: proteção do painel, destino `/tasks`, redirecionamentos globais e isolamento nas entradas de planejamento pertencem à TASK-045; operação de mailbox/README à TASK-046. Esta etapa intermediária não deve ser publicada.

Estado `in_review`: aguarda conferência operacional e commit de integração pelo coordenador. Sem staging, commit ou publicação pelo implementador.
