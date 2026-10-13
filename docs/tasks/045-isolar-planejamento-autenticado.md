---
id: "TASK-045"
status: "done"
execution_level: "advanced"
execution_rationale: "Integra identidade em HTTP, LiveView e comandos, com risco transversal de acesso entre usuários."
specs: ["SPEC-005", "SPEC-002", "SPEC-004", "SPEC-006"]
depends_on: ["TASK-015"]
provides: ["private-user-planning"]
consumes: ["authenticated-user-scope"]
write_scope: ["lib/planner/", "lib/planner_web/", "config/config.exs", "config/dev.exs", "priv/repo/seeds.exs", "priv/gettext/", "test/", "README.md", "docs/tasks/045-isolar-planejamento-autenticado.md"]
blockers: []
---

# 045 — Proteger dashboard e isolar dados por conta

## Objetivo e entradas

Aplicar SPEC-005 RN10–RN13/CA-005-09–11 a todas as entradas do planejamento; SPEC-004 RN20. Ler scope/auth da TASK-015, router, TaskLive.Index/Form, Tasks/Labels/UserTransaction, seeds e referências Phoenix/LiveView/Ecto/testes. Consumir o scaffold, não executar phx.gen.auth novamente.

## Aceite e testes

1. `/` leva visitante a `/users/log-in` e autenticado a `/tasks`; login de autenticado também leva a `/tasks`. Link concluído abre dashboard; logout retorna ao login, sem redirect externo controlado por params.
2. `/tasks` e `/tasks/new` exigem sessão no HTTP e no mount/reconexão LiveView. Derivar usuário de current_scope no servidor; remover fallback público/auto-criação default em todos os ambientes. Preservar legado isolado e não reassociar dados.
3. A/B têm catálogo, tarefas, histórico e cotas independentes. Testes exercitam leitura, cadastro, labels alheias, seleção, retorno, retry → backlog, reordenação, arraste, conclusão e exclusão com IDs forjados, inclusive formulário acessado diretamente.
4. Fixture autenticada adapta testes do painel sem perder regressões funcionais. Seeds não criam acesso compartilhado em produção. Atualizar README para descrever autenticação implementada, sem antecipar instruções de e-mail ainda não entregues pela TASK-046.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.


## Entrega — 12/10/2026

Implementador `/root/implement_task015`, capacidade herdada suficiente para advanced; base `2f956ecb14d4bd2948fc324a4280ecbb95845afa`, branch `feat/ux`, árvore inicialmente limpa. TASK-015 integrada em `d36fed4` e encerrada operacionalmente em `2f956ec`; specs e ausência de bloqueios conferidas. Scaffold consumido sem regeneração.

Router aplica `require_authenticated_user` às entradas `/tasks` e `/tasks/new`, com live_session que exige autenticação novamente no mount/reconexão. TaskLive.Index deriva o usuário de `current_scope.user`; formulário e operações existentes recebem essa identidade do servidor. Tasks/Labels/UserTransaction já filtravam por usuário explícito e preservam seus contratos. Não houve necessidade de alterar suas regras ou persistência.

Home e login de autenticado redirecionam ao dashboard; visitantes vão ao login. Magic link usa `/tasks` como destino padrão, logout retorna ao login e navegação oferece “Sair”. Somente `/tasks` e `/tasks/new` são aceitos como retorno pós-login; URLs externas, protocol-relative, destinos desconhecidos e query strings arbitrárias são descartados. Não se deriva destino de parâmetros recebidos no login.

Removidos resolver automático e configurações de auto-criação default em dev/configuração geral. Seeds não criam contas nem alteram o legado; helpers de preparação explícita permanecem internos para compatibilidade/fixtures e não são chamados por rotas. Registros antigos permanecem intactos, sem transferência de propriedade ou e-mail inventado. README descreve autenticação/isolamento implementados e reserva procedimento de e-mail local à TASK-046.

| Aceite | Evidência e resultado |
| --- | --- |
| 1 — entrada/saída/destinos | `private_planning_test.exs` verifica redirecionamentos de visitantes/autenticados; `authentication_flow_test.exs` verifica destino após confirmação e logout; `user_auth_test.exs` aceita retorno interno autorizado e rejeita destinos externos/desconhecidos. Logout real por controller emite disconnect para o tópico da sessão e reconexão é rejeitada. |
| 2 — HTTP/mount/legado | Testes acessam ambas as rotas anonimamente e com token revogado. Revogação entre renderização HTTP e conexão LiveView impede o mount. Hooks existentes cobrem sessão ausente/inválida. Formulário direto com user_id/default forjados não revela dados legados nem troca proprietário; dados/timestamps legados permanecem iguais. Nenhuma identidade é criada por acesso anônimo. |
| 3 — isolamento A/B | Duas contas autenticadas com backlog/retry/hoje/histórico e labels distintos: presença dos elementos próprios e ausência dos alheios em todas as listas; catálogo privado; seleção, retorno de hoje/retry, conclusão, exclusão, reordenação e arraste com IDs alheios preservam snapshots completos de A/B e cotas. Cadastro com label alheia não persiste tarefa/label parcial. A esgota três escolhas e B ainda escolhe. Testes de domínio anteriores continuam verificando equivalência entre IDs inexistentes/alheios e consultas próprias. |
| 4 — regressões/fixtures/seeds | Painel usa fixture autenticada; reloads preservam a sessão de teste. Todos os testes funcionais de cadastro, cota, histórico, menu, exclusão, arraste e falhas permanecem. Apenas aceites históricos de bootstrap público/home sem login foram substituídos pelos contratos atuais. Seeds repetidos não criam default e preservam registros previamente existentes. |

TDD: quatro testes novos de entrada, autenticação, revogação e isolamento falharam inicialmente (home pública, mount ainda dependente de default e dados legados visíveis); passaram após a integração. Expansão de isolamento A/B passou com as operações existentes. Ajustes de regressão adequaram retornos e fixtures ao novo contrato, sem remover casos funcionais. Teste de logout foi corrigido para usar sessão real do controller e observar broadcast/reconexão: LiveViewTest não implementa transporte de navegador e não permite comprovar fechamento real de websocket por monitorar a LiveView de teste.

Validação via RTK, ajudas Mix previamente consultadas na sessão: testes direcionados, `mix gettext.extract --merge --no-fuzzy --locale pt_BR` (uma mensagem nova, “Sair”), `mix precommit` e `mix ci` finais com **223 testes aprovados**, sem warnings, Credo estrito sem achados, assets compilados e npm audit sem vulnerabilidades. Cobertura total **93,75%** (anterior TASK-015 **92,81%**, mínimo **70%** preservado); UserAuth **98,18%**, TaskLive.Index **98,59%**, Form **97,26%**, Tasks **97,94%**, Login/PageController **100%**. `git diff --check` aprovado.

Autoavaliação pelo fluxo de review: **approved no escopo técnico validado**, sobre alterações locais contra a base acima; sem achados bloqueantes. Não é revisão independente nem avança seu marco. Nenhum hook/JavaScript alterado; testes não validam layout, interação real com navegador ou fechamento do transporte WebSocket. Sem publicação. Estado `in_review`, aguardando conferência operacional e commit de integração pelo coordenador; implementador não realizou staging/commit nem iniciou consumidoras.

### Conferência operacional — 12/10/2026

Coordenador `/root`: entrega integrada em `800b2d3` na branch `feat/ux`. Conferidos escopo, autoavaliação, gates relatados aprovados (223 testes, cobertura 93,75%) e ausência de impedimentos. Sem reprodução de testes ou revisão independente. Estado anterior histórico; conclusão operacional libera TASK-046. Limites de validação em navegador preservados.

### Revisão independente — 13/10/2026

Revisor `/root`, alvo `b0810ba49cf6049c7d5aac49960950a5236be22b`, base reconstruída `367bf3555bc2b06e5ce90aedc2118e46e00986de`. Isolamento sem achado bloqueante identificado; R4 aponta descrição desatualizada dos seeds no README. `mix ci`: 240 testes aprovados, cobertura 94,08%; testes JavaScript de arraste/tema: 9 aprovados. Escopo, reprodução adicional com falha, achados documentais e limites em [docs/review.md](../review.md#revisão-das-últimas-entregas-e-documentação--13102026). Sem correção de produto ou mudança do estado operacional nesta revisão.
