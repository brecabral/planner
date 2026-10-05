---
id: "TASK-037"
status: "in_review"
execution_level: "standard"
execution_rationale: "Integra configuração por ambiente, resolução no contexto e duas entradas LiveView, reutilizando criação idempotente existente."
specs: ["SPEC-005"]
depends_on: ["TASK-008"]
provides: ["dev-default-user-bootstrap"]
consumes: ["default-user", "task-live-scaffold"]
write_scope: ["config/config.exs", "config/dev.exs", "lib/planner/accounts.ex", "lib/planner_web/live/task_live/index.ex", "lib/planner_web/live/task_live/form.ex", "test/planner/accounts_test.exs", "test/planner_web/live/task_live_test.exs", "README.md", "docs/tasks/037-usuario-padrao-dev.md"]
blockers: []
---

# 037 — Criar usuário padrão no primeiro acesso em desenvolvimento

## Objetivo e entrada

Permitir abrir o painel ou cadastro em desenvolvimento, com banco migrado mas sem seeds, criando o usuário `default` automaticamente. Implementar SPEC-005 RN05–RN07 e CA-005-04–CA-005-06, preservando RN01–RN04 e CA-005-01–CA-005-03.

Entradas: `Planner.Accounts.ensure_default_user!/0`, consulta estrita `get_default_user!/0`, `priv/repo/seeds.exs`, resolução em `TaskLive.Index` e `TaskLive.Form`, configuração por ambiente e testes existentes de Accounts/LiveView. Consultar referências de Elixir, Ecto, Phoenix, LiveView e testes. A dependência TASK-008 serializa este incremento após o aceite integrado do MVP anterior, incluindo as produtoras de contexto e interface; não reabrir evidências históricas de tarefas concluídas.

## Escopo e limites

- Reutilizar contexto, schema e índice único existentes. Editar a resolução nas duas telas para garantir `default` somente quando a configuração de desenvolvimento estiver habilitada; manter a consulta estrita existente para consumidores e testes que exigem preparação.
- Configuração desabilitada por padrão, habilitada em `config/dev.exs`; não consultar `Mix.env()` no runtime, aceitar parâmetros do navegador ou introduzir variável `ENV` alternativa.
- Não criar usuários no boot da aplicação. Banco/migrations são pré-requisitos, erros continuam visíveis e os seeds explícitos permanecem disponíveis nos ambientes existentes.
- Não criar autenticação, tela de contas, senha, dependência, migration, tarefa Mix ou dados demonstrativos. Não selecionar usuário arbitrário nem sobrescrever identidade, timestamps, tarefas ou labels.
- Atualizar instruções operacionais somente no README após implementar. Não alterar a execução humana de validação visual.

## Aceite e testes de intenção

1. Sem `default`, configuração de desenvolvimento habilitada e banco migrado: abrir `/tasks` cria a identidade e permite usar o painel. Em teste independente, acessar `/tasks/new` diretamente produz o mesmo resultado. Remontagem/conexão e novos acessos mantêm o mesmo ID e um único registro.
2. Com `default` e dados existentes, os acessos preservam identidade, timestamps, tarefas e labels. Com apenas outra identidade, criam `default` sem alterar ou assumir a outra.
3. Com configuração desabilitada, a resolução sem preparação mantém erro de ausência e não insere usuário; com fixture preparada, ambas as telas continuam funcionando. Conferir configuração desabilitada por padrão e não habilitada em `test`/`prod`.
4. A resolução reutiliza a criação idempotente com conflito tratado pelo índice único, inclusive para acessos simultâneos; preservar testes de seeds e consulta estrita. Cobrir convergência de chamadas concorrentes sem depender de seeds globais ou modificar banco de desenvolvimento.
5. Testes que alternam configuração global restauram o valor ao terminar e não concorrem com consumidores dessa configuração. Usar a infraestrutura existente, sem navegador ou novas dependências.

Aplicar TDD enxuto, reaproveitando testes pertinentes. Executar autoavaliação pelo fluxo de review, `mix precommit` e CI com cobertura mínima de 70%, consultando a ajuda antes de usar tarefas Mix.

## Evidência e integração

Implementada em 05/10/2026 sobre a base `2af94b6`; aguardando conferência operacional e commit de integração pelo coordenador.

- Entrega: `resolve_default_user!/0` reutiliza `ensure_default_user!/0` somente com `:auto_create_default_user` habilitado. As duas LiveViews usam o resolver; a consulta estrita e os seeds foram preservados. Configuração geral false e dev true; nenhuma criação no boot, migration, dependência ou parâmetro de navegador acrescentado.
- Arquivos: os nove arquivos do `write_scope`, incluindo este registro e instruções no README. Alterações documentais preexistentes fora desse escopo foram preservadas.
- TDD: antes da implementação, `rtk mix test test/planner_web/live/task_live_test.exs` apresentou 24/27 testes aprovados e três falhas `Ecto.NoResultsError` esperadas: primeiro acesso independente às duas telas e acesso com somente outra identidade. Após implementação, `rtk mix test test/planner/accounts_test.exs test/planner_web/live/task_live_test.exs` aprovou 36 testes.
- CA-005-04: testes independentes começam sem usuários, fazem GET desconectado, conexão LiveView e novo acesso; conferem o mesmo usuário, registro único e ausência de tarefas/labels demonstrativas.
- CA-005-05: testes preservam identidade, timestamps, tarefa e associação com label; outra identidade permanece intacta. Disputa de resolução usa conexões PostgreSQL distintas, uma inserção ainda sem commit e espera comprovada em `pg_blocking_pids` antes de liberar o commit; ambas retornam o mesmo usuário. A limpeza encerra trabalhadores e remove somente a identidade criada no banco de testes.
- CA-005-06: configuração efetiva carregada para dev/test/prod; resolver sem configuração ou com false mantém erro sem inserir. Ambas as telas rejeitam ausência mesmo com flag forjada no navegador; testes existentes com fixture continuam funcionando. Suites que alteram configuração são síncronas e restauram valor anterior ou ausência via `on_exit`.
- Gates: ajuda de test/precommit/ci consultada antes do uso. `rtk mix precommit` aprovado com 136 testes; `rtk mix ci` aprovado com 136 testes, Credo sem achados e cobertura total 92,16% (mínimo 70% preservado). Accounts 100%, Index 97,66%, Form 97,73%. Primeiro CI apontou três sugestões de alias no teste, corrigidas antes da repetição dos gates. `rtk git diff --check` sem erros.
- Autoavaliação pelo implementador `/root/implement_037`, fluxo de review: alvo é o diff local dos arquivos acima contra `2af94b6`, sem alterações documentais alheias; critérios satisfeitos, sem achados bloqueantes. Configuração só no servidor, índice único e preparação idempotente reutilizados; nenhuma captura de erros de persistência nem `Mix.env()` no runtime. Esta é autoavaliação, não aprovação independente nem avanço do marco de revisão.
- Limitações: execução pelo LiveViewTest e banco de testes; banco de desenvolvimento não alterado. Validação visual humana permanece fora desta tarefa. Não se inferiu aceite deste incremento a partir da TASK-008. Commit e conferência operacional pendentes do coordenador.
