---
id: "TASK-008"
status: "done"
execution_level: "standard"
execution_rationale: "Consolida critérios do MVP local e evidências de comportamento e cobertura."
specs: ["SPEC-001", "SPEC-002", "SPEC-003", "SPEC-004", "SPEC-005", "SPEC-006"]
depends_on: ["TASK-032"]
provides: ["verified-mvp"]
consumes: ["accessible-planner-ui", "default-user", "github-quality-gate"]
write_scope: ["docs/tasks/008-aceite-mvp.md", "docs/specs/"]
blockers: []
---

# 008 — Executar o aceite do MVP mínimo

## Objetivo e entrada

Conferir PRD CA01–CA13 e CA15 e as evidências das produtoras. Executar fluxo no ambiente de teste com usuário padrão, sem depender de login, fuso, idioma alternativo, publicação ou backup. Não implementar correções aqui; devolvê-las à produtora. Não reabrir o gate humano já aceito. A validação humana da interface descrita no PRD fica fora desta tarefa e não condiciona seu aceite; usar as evidências de comportamento e estrutura dos testes existentes, sem exigir navegador ou nova infraestrutura.

## Aceite

1. Cadastro com labels → selecionar → devolver ao backlog → selecionar → concluir → histórico funciona em pt-BR.
2. Devolução restitui uma vez; conclusão não restitui. Virada é observada após recarga e comandos antigos revalidam data.
3. Reinício mantém dados do usuário padrão, labels e cota. Matriz de critérios aponta evidências; precommit e CI passam com pelo menos 70% de cobertura.

## Evidência e revisão

### Aceite e autoavaliação — 05/10/2026

Implementador `/root/accept_008`; base e código avaliado `137ee5482b983648bdab02b8ae17e2bfacaa4c69`, com TASK-032 integrada em `616b72d`. Alvo documental: somente esta tarefa, preservando a decisão preexistente de validação humana fora dos gates. SPEC-001 a SPEC-006 estão prontas. Nenhuma correção de produto ou teste novo foi necessária; reutilizados testes de intenção existentes. Autoavaliação conforme fluxo de review, sem revisão independente nem avanço do marco independente.

### Matriz do PRD

Todos os testes abaixo foram executados nos gates locais, com resultado aprovado. Caminhos relativos à raiz do repositório.

| Critério | Evidência e resultado |
| --- | --- |
| CA01 | `test/planner_web/live/task_live_test.exs`, testes de painel vazio, cadastro sem login e título vazio; `test/planner/tasks_test.exs`, cadastro de títulos válidos/inválidos. Backlog criado; entradas inválidas não persistem. |
| CA02 | LiveView: `selects backlog and retry, refunds only once and preserves identity and labels`; seleção e remontagem preservam identidade, labels e cota. |
| CA03 | Contexto: `completing one of three selected tasks does not make room for a fourth` e `concurrent selections on separate connections have one winner for the last choice`; LiveView também verifica cota esgotada após três conclusões. |
| CA04 | Contexto: `reorder_today persists an exact permutation without changing quota`, rejeição de conjuntos inválidos, constraints e concorrência; LiveView verifica controles subir/descer, limites e remontagem. |
| CA05 | Contexto: `return_to_backlog refunds once, compacts positions and permits reselection` e devoluções concorrentes; LiveView verifica repetição sem restituição dupla. |
| CA06 | Contexto: conclusão usa data do servidor, preserva resultado sob repetição/concorrência e não restitui; LiveView: `completes once, preserves quota and shows the original date and labels after reload`. |
| CA07 | Ensaio com dois processos BEAM descrito abaixo; testes de reinício real de Repo/pool em `tasks_test.exs` e `user_transaction_test.exs` preservam histórico, labels e consumo por data. |
| CA08 | Contexto: `snapshot rolls expired pending tasks into retry once and preserves identity`, `snapshot survives a repository and connection pool restart across a day change`, comandos antigos de seleção/devolução/reordenação/conclusão. LiveView monta retry após leitura de data atual e rejeita eventos vencidos. Ensaio de reinício também confirmou virada. |
| CA09 | Contexto injeta falhas reais de gravação de cota, posições e vínculos para conferir rollback. LiveView testa falhas de seleção, devolução, conclusão e cadastro com erro visível e estado persistido intacto. |
| CA10 | 21 testes LiveView, testes de locale e componentes: cadastro com labels, seleção, ordem, devolução, conclusão, histórico, alertas, associação dos erros e nomes de controles em pt-BR; conteúdo original preservado. |
| CA11 | `rtk mix precommit` e `rtk mix ci`: 127 testes aprovados em cada execução, cobertura total de 92,12%, limiar de 70% mantido; Credo estrito sem achados. |
| CA12 | Gates executaram aplicação/PostgreSQL no ambiente de teste usando configuração externa existente. Inspeção de `config/database.exs`, `config/runtime.exs`, `.gitignore` e `git ls-files`: `.env` ignorado e não versionado; credenciais do banco e segredos de produção vêm do ambiente. Valores de desenvolvimento/teste do scaffold não são credenciais de produção. |
| CA13 | `test/planner/accounts_test.exs`: preparação e seeds idempotentes; LiveView: abertura sem login e rejeição de proprietário/estado forjados. No ensaio, seeds repetidos após reinício preservaram usuário e dados. |
| CA15 | Contexto e LiveView: cadastro com labels existentes/novas, repetição de IDs, nomes inválidos e IDs alheios/inexistentes; vínculo incompatível rejeita toda a transação, sem labels novas órfãs. |

### Evidência de persistência após reinício

Base dedicada `planner_accept_008_20261005`, criada vazia e migrada com as seis migrations existentes; nenhuma base de uso do usuário foi alterada. Preparação executada com `rtk env MIX_ENV=test POSTGRES_TEST_DB=planner_accept_008_20261005 MIX_TEST_PARTITION= mix ecto.create` e o equivalente `mix ecto.migrate`. A primeira tentativa no sandbox falhou por `:eperm` no lock TCP do Mix; reexecução autorizada fora do sandbox passou.

Ensaio temporário `/tmp/planner_accept_008.exs`, com assertions ExUnit e conexão sem rollback de sandbox. Executados `rtk mix run --no-start /tmp/planner_accept_008.exs write` e, somente após término com código zero, `rtk mix run --no-start /tmp/planner_accept_008.exs read`. O script troca a base do Repo **antes** de iniciar a aplicação e confere seu nome. Esses dois comandos usam compilação Mix de desenvolvimento contra a base isolada de aceite; os gates e testes persistentes usam `MIX_ENV=test`. Não foi criado servidor HTTP ou infraestrutura permanente.

- Processo do sistema `18580`: criou usuário `default` (ID 1), label existente e nova label no cadastro; selecionou, devolveu duas vezes (cota zero), selecionou novamente e concluiu duas vezes (consumo um); cadastrou e selecionou uma segunda tarefa. Salvou snapshot esperado: duas escolhas consumidas, uma conclusão, uma pendência e duas labels. Saída: `WRITE_OK os_pid=18580 user_id=1 choices=2 history=1 labels=2`.
- Processo `18814`, iniciado depois do encerramento do primeiro: confirmou igualdade integral de usuário, catálogo, histórico e snapshot; executou seeds duas vezes sem mudança de identidade/dados. Avançou a data controlada de 05 para 06/10/2026, confirmou uma tarefa em retry, zero escolhas na nova data e preservação das duas escolhas da data anterior. Saída: `READ_OK os_pid=18814 user_id=1 choices=2 history=1 labels=2 next_day_retry=1`.
- Base e arquivos temporários do ensaio permanecem disponíveis para inspeção local. O ensaio reiniciou a aplicação inteira entre processos; não reiniciou PostgreSQL, sistema operacional ou executou recuperação de backup, fora deste aceite.

### Resultado e limites

Critérios 1–3 atendidos pela matriz e pelo ensaio; autoavaliação técnica `approved`, sem achados bloqueantes. `rtk mix precommit` (seed 197296) e `rtk mix ci` (seed 534041) passaram. Cobertura: total 92,12%, Tasks 98,31%, UserTransaction e Accounts 100%, Index 97,66%, Form 97,73%; igual à evidência integrada da TASK-032. Cobertura de linhas não demonstra todos os ramos. Nenhum código foi modificado por esta tarefa.

CI foi reproduzido localmente; não há verificação de execução remota nesta entrega. Gates humanos TASK-003/TASK-012 não foram reabertos. Teclado, foco, layout e anúncios assistivos reais permanecem pendentes da validação humana do PRD, fora dos gates. Tarefa em `in_review`, aguardando conferência operacional e integração pelo coordenador; sem staging/commit pelo implementador.

### Conferência operacional — 05/10/2026

Coordenador `/root`: registro, matriz e resumo conferidos superficialmente, sem impedimentos. Gates locais relatados aprovados: 127 testes e cobertura de 92,12%; persistência demonstrada entre dois processos separados. Evidências integradas na base de trabalho em `d8770e5`, com TASK-032 concluída e integrada. TASK-008 concluída operacionalmente, encerrando a fila autorizada do MVP. Sem revisão independente ou verificação de CI remoto. Evoluções futuras permanecem fora do escopo; validação humana da interface continua pendente conforme PRD.


### Revisão independente de prontidão — 05/10/2026

Revisor `/root`; alvo `ce0f72bb59eb27efa0a60e867f93242c2e805916`, base `aafed16d7b7a09000404e716cc98dcc43763510e`. Achado R1 no cadastro impede o aceite integral do MVP. CI e precommit reproduzidos: 136 testes aprovados; cobertura total 92,16%. Evidências, reprodução, critérios e limites no [relatório de revisão](../review.md#revisão-de-prontidão-do-mvp--05102026). Registro operacional anterior preservado; esta revisão não presume validação humana ou CI remoto.

### Reconciliação anterior ao encerramento de R1 — 05/10/2026

A matriz acima preserva o aceite operacional histórico. Para CA09, a evidência de erro de cadastro não cobre exceções de persistência: R1 demonstrou encerramento da LiveView nesse caminho. O aceite integral permanece pendente; correção e revalidação estão na [TASK-038](038-tratar-falha-cadastro.md), sem invalidar os resultados já reproduzidos nos demais critérios. O estado `done` registra a execução histórica desta tarefa, não aprovação global da revisão.

### Fechamento do MVP local — 05/10/2026

Por solicitação do responsável, MVP local encerrado com base na [revalidação independente aprovada](../review.md#revalidação-de-prontidão-do-mvp--05102026) por `/root/review_mvp_readiness`, alvo integrado `2b8ba19ce2657126423256d3fd2596875c7ca661`. A TASK-038 encerrou R1 e completou o aceite de CA09; a ressalva histórica acima está superada. CI e precommit reproduzidos pelo revisor: 139 testes aprovados, cobertura de 92,25% e Credo sem achados.

Specs do MVP registradas como implementadas com base no código integrado e no aceite verificado. A documentação de estado foi reconciliada com a aprovação; histórico e marco de revisão foram preservados. Validação humana da interface continua pendente, fora do gate por decisão do PRD. CI remoto e publicação não foram verificados nem executados; evoluções futuras continuam fora do fechamento.
