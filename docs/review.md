---
review_base_commit: "367bf3555bc2b06e5ce90aedc2118e46e00986de"
reviewed_commit: "b0810ba49cf6049c7d5aac49960950a5236be22b"
last_approved_commit: "2b8ba19ce2657126423256d3fd2596875c7ca661"
reviewed_at: "2026-10-13"
reviewer: "/root — revisão independente de código e alinhamento documental"
status: changes_requested
reviewed_tasks: ["TASK-041", "TASK-042", "TASK-043", "TASK-044", "TASK-015", "TASK-045", "TASK-046", "TASK-047", "TASK-048"]
---

# Revisão incremental das tarefas concluídas

## Revisão das últimas entregas e documentação — 13/10/2026

Resultado: **changes_requested**, por R3. O gate existente passa, mas a falha de envio durante o cadastro derruba a LiveView. Autenticação, isolamento, movimentos, exclusão e temas estão majoritariamente alinhados aos contratos inspecionados; há também desatualizações documentais R4/R5. Nenhum código de produto ou contrato foi corrigido nesta revisão.

### Alvo e reconstrução da base

Alvo commitado: `b0810ba49cf6049c7d5aac49960950a5236be22b`. O código executável local coincide com HEAD. O marco histórico `2b8ba19ce2657126423256d3fd2596875c7ca661` existe, mas `git merge-base --is-ancestor` retornou 1; não é ancestral do alvo. A história atual integra o MVP local em `367bf3555bc2b06e5ce90aedc2118e46e00986de` (`MVP Local (#7)`), também registrado como integração na TASK-041. Essa é a base reconstruída para o incremento 041–048/015. Não se presume equivalência integral entre o antigo histórico e essa integração. `last_approved_commit` permanece como evidência histórica, sem avanço e sem servir automaticamente de base ancestral futura.

As 13 alterações locais preexistentes são documentais: README, BLOCK-005, design, PRD, SPEC-005/008, índice de specs, TASK-011/033/034/035/050 e índice de tarefas. Foram consideradas decisões vigentes, separadas do SHA do código e preservadas. A entrega termina no release local; infraestrutura remota não é requisito. TASK-011 continua planejada com BLOCK-005 aberto; TASK-050 depende dela. Nenhuma dessas duas tarefas foi tratada como entregue.

### R3 — P2: falha de envio no cadastro encerra a LiveView

Local: [registration.ex:60](../lib/planner_web/live/user_live/registration.ex#L60), introduzido na TASK-015 (`d36fed4`). Depois de persistir a conta, o evento exige `{:ok, _}` de `Accounts.deliver_login_instructions/2`. Se o adapter retorna `{:error, :delivery_unavailable}`, ocorre `MatchError` e o processo LiveView encerra. A conta já foi criada em transação anterior; repetir o cadastro encontra e-mail ocupado, sem orientação controlada para recuperar o acesso. Não foi identificada criação indevida de sessão.

Reprodução independente: teste temporário `/tmp/planner_review_registration_delivery_test.exs`, usando ConnCase/Sandbox, restauração de configuração em `on_exit` e o adapter existente `Planner.FailingMailAdapter`. Abrir `/users/register` e submeter um e-mail novo reproduziu a exceção em `registration.ex:60`. `rtk mix test /tmp/planner_review_registration_delivery_test.exs`: **1 teste, 1 falha**, saída 2, seed 72785. Nenhum envio real ou dado permanente foi criado. O teste adicional está fora da suíte do repositório.

Correção esperada: tratar retorno de falha do envio após cadastro, apresentar resposta traduzida e recuperação coerente para a conta já persistida, sem anunciar entrega nem abrir sessão; acrescentar teste web desse caminho. A TASK-046 testa falha na solicitação de login, mas não no cadastro (`test/planner_web/local_magic_link_test.exs:88`), portanto seu teste verde não cobre R3. O defeito pertence ao fluxo introduzido pela TASK-015, não às alterações documentais locais nem aos temas.

### R4 — P3: README descreve comportamento removido dos seeds

Local: [README.md:37](../README.md#L37). A tabela afirma que `mix run priv/repo/seeds.exs` prepara o usuário padrão. O arquivo atual contém apenas comentário e não grava nada; a seção de autenticação do próprio README afirma corretamente que seeds não criam contas nem alteram o legado. Quem seguir a tabela esperando preparar identidade não obterá o resultado prometido. Atualizar a descrição operacional conforme o comportamento entregue pela TASK-045, sem restaurar o bootstrap antigo.

### R5 — P3: SPEC-002 apresenta regras entregues como não implementadas

Local: [SPEC-002:61](specs/002-planejamento-diario.md#L61). A frase “RN11–RN13 ainda exigem implementação” contradiz as TASK-042/043 concluídas e o código/testes de retry → backlog e exclusão. Reconciliar o estado declarado com as evidências de integração, preservando a origem histórica da decisão e distinguindo o aceite do release ainda pendente. Não é defeito dessas operações.

### Critérios e validação

| Entregas | Resultado da revisão |
| --- | --- |
| 041 | Composição à esquerda, espaço dos controles e separação de texto presentes; testes estruturais aprovados. Layout real não medido. |
| 042–044 | Whitelist cliente/servidor, retorno de retry sem restituição, exclusão própria pendente, preservação de labels/histórico, compactação, lock, rollback e confirmação conferidos com os testes. Sem novo achado bloqueante nesses contratos. |
| 015/045 | Tokens com hash/TTL, consumo serializado, sessão/CSRF/logout, rotas HTTP/mount protegidas, proprietário do servidor e migrations de preservação conferidos. R3 impede aprovação integral do cadastro; R4 afeta documentação operacional. |
| 046 | Captura local/teste, destinatário/URL, duas contas e ausência de rotas dev em configuração prod cobertos. Falha no login coberta; falha no cadastro ausente. Procedimento em navegador e envio externo não executados. |
| 047/048 | Catálogo/concessões, backfill, cadastro transacional, autorização da escolha, preferência por conta, HTML inicial, patches e erros conferidos. Sem achado bloqueante identificado; persistência após reinício do release pertence à TASK-050. |

Após leitura dos aliases, política e ajuda: `rtk mix ci` passou com **240 testes**, seed 519817, cobertura Elixir **94,08%**, limiar 70% preservado; compilação, formato, Credo estrito, assets e npm audit aprovados. `rtk mix cmd node --test assets/test/task_drag.test.mjs assets/js/account_theme.test.mjs`: **9 testes aprovados**. `rtk git diff --check`: aprovado. A reprodução adicional de R3 falhou conforme descrito, apesar do gate verde.

Conferência estrutural dos 50 cabeçalhos: nenhuma dependência inexistente/cíclica, tarefa concluída com dependência não concluída ou consumo sem produtor alcançável entre tarefas planejadas/em execução/concluídas. A cadeia vigente TASK-048 → TASK-011 → TASK-050 é coerente; cancelamento de 033/034/035 não quebra essa cadeia. Essa conferência não certifica todo o planejamento histórico nem executa tarefas pendentes.

Limites: sem nova medição da base, sem alegação de variação de cobertura; sem navegador real, contraste, gestos ou reinício do release. CI remoto não consultado. `precommit` não repetido porque formata e pode alterar lockfile; verificações sem correção foram reproduzidas via `ci`, e nenhuma implementação foi feita. Registros de autoavaliação anteriores permanecem evidências históricas. Revisão independente não muda status operacional das tarefas, não aprova publicação e não encerra BLOCK-005.

## Prontidão do MVP e revalidação de R2 — 11/10/2026

Resultado: **approved no escopo local revisado**. O MVP local definido pelo PRD está pronto. TASK-039 está integrada; a correção de R2 na TASK-040 foi revalidada independentemente nesta sessão, sem novos achados bloqueantes identificados. A TASK-040 continua `in_review`: sua correção ainda está sem commit e requer integração e conferência operacional para encerramento. Aprovação técnica não equivale a conclusão operacional ou publicação.

Base: `2b8ba19ce2657126423256d3fd2596875c7ca661`, confirmada como ancestral de HEAD `452083a6a4a117a39622c96bd1aec4bf9cd60f50`. Alvo efetivamente validado: árvore local sobre HEAD, incluindo alterações preexistentes em `assets/js/task_drag.js`, `assets/test/`, README, referência de LiveView/JavaScript e TASK-040. O SHA do cabeçalho identifica o commit de suporte, não certifica seu hook antigo. **Preservado `last_approved_commit`**, pois o código executável validado diverge de HEAD; esta aprovação depende da correção local.

Conferidos PRD, mapa de entregas, contratos de interface/arraste, evidências humanas históricas, revisão anterior e código de domínio, transação, migration, painel, cadastro e hooks. Cadastro com labels, cota, devolução, conclusão, ordenação, virada, persistência e tratamento de falhas continuam cobertos pela suíte aprovada. O aceite de reinício entre processos da TASK-008 foi consultado como evidência histórica, sem repetição. Não foi refeita uma auditoria integral dos workflows/skills históricos; suas aprovações mantêm o escopo original.

**R2 resolvido na árvore local:** captura de atributos anterior ao início, retenção e remoção explícita de ghost/clone, cancelamento de timers e restauração dos mesmos nós conferidos contra SortableJS instalado. Cinco testes técnicos executam a dependência real e verificam patch, desconexão, idempotência, pressão touch atrasada e resposta antiga após reconexão. O novo drop envia um único evento com DOM restaurado; cancelamento não envia movimento. A dependência explícita de TASK-039 também resolve a observação documental anterior.

Validação reproduzida, após leitura da ajuda e política: `rtk mix ci`, saída 0, **157 testes aprovados**, seed 622287, cobertura Elixir **93,44%** (mínimo 70%); Credo, compilação, formato, build e npm audit aprovados. `rtk mix cmd node --test assets/test/task_drag.test.mjs`: **5 testes aprovados**. `rtk git diff --check`: aprovado. `precommit` não repetido por formatar e poder alterar dependências; sua execução aprovada na correção permanece evidência relatada. Não foi medida novamente a base; nenhuma alegação de aumento de cobertura.

Limites: harness JavaScript usa DOM/timers controlados, sem gestos reais, layout ou patches em navegador; cobertura percentual não mede JavaScript. Conforme decisão vigente, avaliação humana da interface não é gate nem pendência obrigatória. Login, fuso configurável, sincronização e publicação são evolução futura e não impedem o MVP. CI remoto não consultado; nenhum reset humano, alteração de código de produto, commit ou deploy nesta revisão. Registros anteriores abaixo preservam o estado de cada rodada.


## Revisão das entregas locais — 10/10/2026

Resultado: **changes_requested**. Revisão independente por `/root`, sem implementação nesta sessão. TASK-039 sem achado bloqueante identificado; TASK-040 requer correção do cancelamento do gesto. O MVP histórico continua aprovado no seu escopo.

### Base e escopo

Base aprovada `2b8ba19ce2657126423256d3fd2596875c7ca661`, confirmada como ancestral de HEAD `43ea80314c0a47a2a8357c17064cc01ac9ed5a40`. O intervalo commitado contém reconciliação documental. O alvo executável desta rodada é **a árvore local não commitada sobre HEAD**, incluindo TASK-039/TASK-040, hook, migration, testes e configuração npm/CI. Não havia alterações staged; os arquivos novos também foram lidos. O SHA de `reviewed_commit` identifica somente HEAD, não uma aprovação das alterações locais. Preservado `last_approved_commit`.

Conferidos contratos atuais, cadastro/modal, eventos e menus, ordenação/transferências/cota, lock compartilhado, virada, migração, regressões e integração do hook com as fontes instaladas de LiveView/SortableJS. Decisões documentais posteriores dispensam avaliação humana obrigatória da interface; esta revisão não reabre esse requisito.

### R2 — P2: cancelamento deixa resíduos do arraste no DOM

Local: [assets/js/task_drag.js:124](../assets/js/task_drag.js#L124), especialmente chamadas a `destroy()` nas linhas 128–130. Durante um arraste ativo, um patch ou desconexão chama `cancelGesture()`. Com `forceFallback: true` e `fallbackOnBody: true`, há um elemento flutuante anexado ao body. O hook pressupõe que `destroy()` o remova, mas SortableJS 1.15.7 chama `_onDrop()` **sem evento** (`assets/node_modules/sortablejs/Sortable.js:2170`): remoção do ghost/clone e limpeza das classes do item estão dentro de `if (evt)` (linhas 1936–1961). `_nulling()` depois apaga as referências. `restore()` apenas reposiciona os nós capturados e limpa atributos das listas; não remove o elemento flutuante no body nem limpa as classes do item. O artefato pode permanecer após reconexão/patch, fora dos streams, até recarregar a página.

Evidência por inspeção do caminho real da dependência instalada; não houve reprodução em navegador. Trata-se do cancelamento funcional exigido por RN16, não de preferência estética. Correção esperada: cancelar sem enviar movimento, remover os artefatos temporários e restaurar classes/estilos do item antes de perder as referências, preservando os mesmos nós dos streams. Cobrir cancelamento por patch e desconexão e garantir ausência de evento de movimento/fantasmas residuais. Não corrigido nesta revisão.

### Validação reproduzida

Ajuda de `mix ci`, aliases e política de qualidade lidos antes da execução. `rtk mix ci`: saída 0, **157 testes aprovados**, seed 826447, cobertura **93,44%**; Tasks/Index 98,31%, Form 97,26%, UserTransaction 100%. Compilação, formato sem correção, Credo estrito, build Tailwind/esbuild e npm audit aprovados, zero vulnerabilidades reportadas. Limiar de 70% preservado. `rtk git diff --check`: aprovado. Base não medida novamente; nenhuma alegação de variação de cobertura.

Os testes exercitam permutações, destinos vazios/início/meio/fim, rejeições, rollback, concorrência e migração com dados anteriores em schema isolado. LiveViewTest cobre eventos, cadastro e feedback, mas não executa o hook. O gate verde não detecta R2. `precommit` não repetido por conter formatação e alteração de lockfile; suas evidências anteriores permanecem relatadas. Nenhum código de produto editado, navegador executado, reset humano, commit ou publicação. CI remoto não consultado.

### Trabalho remanescente

- **TASK-040:** corrigir R2 e revalidar; depois conferir integração e encerrar a tarefa. Continua `in_review`, com correção solicitada registrada abaixo e na tarefa.
- **TASK-039:** sem correção funcional identificada nesta rodada; ainda requer conferência operacional/integração para mudar de `in_review` para `done`.
- Tarefas do MVP, incluindo humanas TASK-003/TASK-012, têm conclusão histórica registrada; nenhuma execução humana pendente foi identificada.
- TASK-004/011/013/014/015/017/031/033/034/035 são evolução futura, dependente de redefinição de contratos/produto, não trabalho obrigatório do escopo atual.

Observação documental não bloqueante: TASK-040 sobrepõe arquivos e usa a interface local da TASK-039, mas declara somente TASK-038 em `depends_on`. Antes de distribuí-las separadamente, reconciliar essa relação para impedir execução concorrente em recursos compartilhados. Esta revisão não replaneja o grafo.

## Revalidação de prontidão do MVP — 05/10/2026

Resultado: **approved**. O MVP está pronto no escopo local definido pelo PRD, com os critérios automatizados atendidos e sem achados bloqueantes identificados. R1 foi corrigido pela TASK-038 e revalidado independentemente por `/root/review_mvp_readiness`, que não implementou o produto. A avaliação humana de teclado, foco, layout e anúncios continua pendente, fora do gate por decisão explícita do PRD; esta aprovação não a presume nem autoriza publicação.

### Base, alvo e separação do estado local

Base `aafed16d7b7a09000404e716cc98dcc43763510e`, confirmada como ancestral do alvo `2b8ba19ce2657126423256d3fd2596875c7ca661`. Conferidos o diff acumulado e os contratos de cadastro, comandos de planejamento, transação compartilhada, posições, histórico, formulário, painel e usuário padrão. A correção integrada em `190dd9bf0860188dff92820d4bca68ec2ca359f6` recebe revisão específica dos quatro aceites da TASK-038. As aprovações anteriores sustentam seus próprios escopos; workflows/skills históricos e evoluções futuras não recebem certificação implícita.

O código executável local coincide com o alvo. Seis arquivos documentais já estavam modificados: `README.md`, `docs/prd.md`, `docs/specs/005-contas-e-acesso.md`, `docs/tasks/008-aceite-mvp.md`, `docs/tasks/029-acao-reordenar.md` e `docs/tasks/README.md`. Foram lidos como contexto vigente e preservados sem edição; não integram a aprovação de código pelo SHA. Esta revisão modifica somente este relatório e o registro da TASK-038.

### Critérios e evidências

| Critério | Conferência e resultado |
| --- | --- |
| CA01/02/13/15 | Cadastro, rejeições, labels próprias, rollback, parâmetros sem autoridade de proprietário, identidade padrão e bootstrap dev conferidos no código e nos testes aprovados. |
| CA03–06/08 | Cota persistente, restituição única, conclusão sem restituição, permutação exata, posições, virada e revalidação verificadas; testes de concorrência usam conexões PostgreSQL distintas e espera por lock real. |
| CA07 | Testes de reinício de Repo/pool executados novamente. Ensaio entre dois processos BEAM da TASK-008 consultado como evidência histórica relatada, sem repetição nesta rodada. |
| CA09 / TASK-038 aceites 1–4 | Captura específica de `Ecto.ConstraintError`, `Postgrex.Error` e `DBConnection.ConnectionError` fora da transação; três testes aprovados verificam o mesmo processo LiveView, alerta pt-BR, entradas preservadas, ausência de falso sucesso, rollback e reenvio único. Constraint e trigger falham depois de gravações parciais; indisponibilidade de conexão é reproduzida mantendo ocupado o checkout do Sandbox. Painel mantém tratamento de falhas e recuperação de estado. R1 encerrado. |
| CA10 | Eventos, controles, estrutura de erros e traduções cobertos por LiveViewTest. Teclado, foco, layout e anúncios efetivos não foram avaliados. |
| CA11/12 | Gates locais reproduzidos com configuração externa existente; nenhuma alteração em dependências, configuração, limiar ou código executável. CI remoto não consultado. |

Ajuda de `ci` e `precommit` e aliases inspecionados antes da execução. `rtk mix ci`: saída 0, **139 testes aprovados**, seed 775364, cobertura de linhas **92,25%**, compilação, formato e Credo estrito aprovados. Form 98,00%, Index 97,66%, Tasks 98,31%, Accounts e UserTransaction 100%. Mínimo de 70% mantido; base não medida nesta rodada, sem alegação de variação. `rtk mix precommit`: saída 0, **139 testes aprovados**, seed 921072, sem alteração em código ou lockfile. `rtk git diff --check`: aprovado.

### Pendências não bloqueantes e limites

Os seis documentos locais foram preservados. README, abertura do PRD, encerramento da SPEC-005, índice de tarefas e reconciliação histórica da TASK-008 ainda mencionam R1 pendente; cabe reconciliar a apresentação do estado atual com esta aprovação, mantendo o histórico. Não é falha funcional nem reabre R1.

Cobertura por linhas não prova todos os ramos ou interleavings. O teste de conexão cobre falha de aquisição, não perda de comunicação durante commit. Testes LiveView não executam JavaScript em navegador. O reinício do PostgreSQL, recuperação de backup, autenticação e publicação estão fora do MVP. TASK-003/TASK-012 têm aceite humano histórico; nenhuma execução humana ou reset foi repetido. O marco avança apenas para o código e os escopos declarados, preservando as exclusões anteriores. Nenhum código corrigido, commit criado ou publicação executada nesta revisão.

## Revisão de prontidão do MVP — 05/10/2026

Resultado: **changes_requested**. O fluxo principal está implementado e os gates automatizados existentes passam, mas o tratamento de falha de gravação no cadastro impede aprovar integralmente o CA09. Revisão independente por `/root`, sem implementação de produto nesta sessão. Os estados operacionais históricos das tarefas não equivalem à aprovação desta revisão.

### Base e escopo

Base `aafed16d7b7a09000404e716cc98dcc43763510e`, último marco aprovado, confirmada como ancestral do alvo `ce0f72bb59eb27efa0a60e867f93242c2e805916`. Inspecionados os comandos de planejamento, transação compartilhada, migration de posições, formulário, painel, resolução de usuário e testes relevantes das tarefas listadas no cabeçalho. Código executável local idêntico ao alvo; alterações locais preexistentes são documentais e foram preservadas separadamente: AGENTS, fluxos/skills/formato, PRD/design, SPEC-004/005, índices e BLOCK-004. Elas registram coordenação sem revisão automática, validação humana fora dos gates e bootstrap em desenvolvimento. Não recebem aprovação de código pelo SHA.

O último marco aprovado permanece na TASK-021. Revisões anteriores e suas exclusões continuam válidas apenas nos respectivos escopos; esta rodada não é certificação de todos os workflows/skills históricos.

### Achado bloqueante de aceite

**R1 — P2: tratar exceções de persistência no cadastro.** Local: [form.ex:113](../lib/planner_web/live/task_live/form.ex#L113), chamada a `Tasks.create_task/2` no evento `save` (linhas 112–123). Se a gravação lança `Ecto.ConstraintError`, `Postgrex.Error` ou erro de conexão, o callback não trata a exceção e a LiveView encerra, em vez de manter o formulário com erro visível em pt-BR. O tratamento existente cobre somente retorno de changeset; o painel já captura falhas de persistência. Contraria PRD CA09 e SPEC-004 RN04/CA-004-03. Não se atribui perda de dados persistidos: a transação protege atomicidade; a falha comprovada é na resposta da interface.

Reprodução em teste temporário `/tmp/planner_review_registration_test.exs`, usando ConnCase e SQL Sandbox existentes: criar fixture `default`, abrir `/tasks/new`, adicionar dentro da transação de teste a constraint `ALTER TABLE tasks ADD CONSTRAINT reject_review_registration CHECK (title <> 'Review failure') NOT VALID`, submeter `#task-form` com título `Review failure` e nova label `Keep label`. Esperado: formulário ativo, entrada preservada e alerta traduzido. Obtido: `Ecto.ConstraintError` em `form.ex:113`, encerramento do processo e teste interrompido antes das asserções de UI. `rtk mix test /tmp/planner_review_registration_test.exs`: **1 teste, 1 falha**, saída 2. Constraint temporária revertida pelo sandbox; nenhuma migration ou código de produção alterado. A injeção reproduz a mesma classe de falha já usada pelos testes do painel, sem alegar que a constraint artificial existe no produto.

Correção esperada: converter as exceções de persistência pertinentes em resposta controlada no formulário, preservar entradas e apresentar erro via Gettext, mantendo rollback e sem falso sucesso; acrescentar teste de intenção para esse caminho. O handler foi introduzido em `ca84dfd` (TASK-006) e estendido em `b3cbf7e` (TASK-026); a lacuna não foi introduzida pelo bootstrap da TASK-037 nem pelo diff documental local. Código não corrigido nesta revisão.

### Critérios e evidências

| Escopo | Resultado |
| --- | --- |
| CA01/02/13/15 | Cadastro válido/inválido, labels, identidade, isolamento e remontagem cobertos por contexto/LiveView; bootstrap dev nas duas entradas e concorrência cobertos. |
| CA03–06/08 | Cota durável, restituição única, conclusão sem restituição, permutação exata, rollback e revalidação do dia conferidos no código e testes; concorrência usa conexões PostgreSQL distintas. |
| CA07 | Testes de reinício de Repo/pool reproduzidos no CI. Ensaio de dois processos BEAM da TASK-008 consultado como evidência relatada, não repetido nesta rodada. |
| CA09 | Parcial: painel trata falha e contexto reverte gravações; cadastro tem R1. |
| CA10 | Eventos, estrutura e mensagens cobertos por LiveViewTest. Teclado, foco, layout e anúncios reais permanecem reservados à validação humana, fora do gate conforme PRD/BLOCK-004. |
| CA11/12 | Gates locais aprovados com configuração externa existente; nenhuma dependência ou política de cobertura alterada. CI remoto não consultado. |

Ajuda Mix e aliases inspecionados antes da execução. `rtk mix ci`: **136 testes aprovados**, cobertura de linhas **92,16%**, compilação, formato e Credo estrito aprovados. Tasks 98,31%, Index 97,66%, Form 97,73%, Accounts/UserTransaction 100%. Mínimo de 70% mantido; base não medida novamente, sem afirmação de variação. `rtk mix precommit`: **136 testes aprovados**, sem mudanças em código/lockfile. `rtk git diff --check`: aprovado. O teste exploratório de R1 é adicional à suíte existente e sua falha impede concluir que o gate verde cobre todo o contrato.

### Observações documentais e limites

Não bloqueantes: README ainda afirma que a implementação não começou (linhas 3 e 57), PRD linha 3 declara implementação pendente e SPEC-005 encerra dizendo que TASK-037 não foi implementada, embora integrada. TASK-029 ainda menciona teclado no aceite; prevalece a decisão posterior do PRD que reserva essa validação ao humano. Recomenda-se reconciliar esses textos; não se presume validação humana concluída.

Tarefas humanas TASK-003/TASK-012 tiveram apenas suas evidências históricas consultadas; nenhuma execução ou reset repetido. Publicação, autenticação e demais evoluções permanecem fora do MVP. O commit solicitado registra o estado e esta revisão, sem constituir aprovação, correção ou publicação remota.

## Revisão anterior preservada — TASK-021

Revisor independente `/root/review_task021`: **approved**, sem achados bloqueantes no diff da base `ed37fdbe7c91fed6cb6eb9c1ab95ee1deda125d8`, integrado sem alterações executáveis em `aafed16d7b7a09000404e716cc98dcc43763510e`. Normalização antes do callback, rollback, isolamento e ordenação atendidos. CI reproduzido: 77 testes, 87,46% total, Tasks 98,15%, UserTransaction 100%; diff check aprovado. Reinício cobre Repo/pool; comando antigo usa callback. Comandos futuros fora do escopo. Evidências completas na TASK-021.

## Revisão anterior preservada — TASK-019 e TASK-020

Resultado: **approved**, sem achados bloqueantes. Revisão independente por `/root`, que não implementou estas entregas nesta sessão, do intervalo `9ec53063065ac434895baa70333d49824ee8fb91..6b8030933cdf64c7390709e3cc825d4300106fc3`. Ancestralidade confirmada e código executável local idêntico ao alvo. Dependências integradas; aceites humanos anteriores apenas consultados. Esta rodada encerra as pendências de revisão detalhada das duas tarefas, preservando os registros excepcionais como histórico.

| Tarefa | Critérios conferidos e evidências reproduzidas | Resultado |
| --- | --- | --- |
| TASK-019 | Cadastro sem labels, múltiplas próprias, existentes e novas; IDs inteiro/string deduplicados; proprietário filtrado; título/nome/ID inválidos e falha de gravação revertem tarefa, novas labels e vínculos, preservando existentes. Transação e FKs sustentam SPEC-006 RN02–RN04 e CA-006-01–04. | Aprovada. |
| TASK-020 | Lock do usuário precede captura da data e criação da cota; conexões PostgreSQL distintas demonstram espera real e consumo serializado; outro usuário prossegue; erro/exceção reverte gravações; constraints impõem chave usuário/data e faixa 0–3; reinício efetivo do Repo/pool preserva consumo. | Aprovada. |

Validação: ajuda dos aliases e `mix.exs` inspecionados; `rtk mix ci` aprovado com **72 testes, 86,97% de cobertura total**, Tasks 97,78%, UserTransaction e DailyPlan 100%. Compilação, formatação e Credo estrito aprovados; limiar de 70% preservado. `rtk mix precommit` também aprovado com 72 testes, sem alterações executáveis ou de lockfile; `rtk git diff --check` aprovado. Não foi medida novamente a base, portanto não se afirma variação de cobertura nesta rodada.

As alterações locais preexistentes em `docs/fluxos/implementacao.md` e `docs/referencias/ecto.md` foram revisadas separadamente e aprovadas por coerência, link/âncora e avaliação de cenários: migration completa antes do primeiro teste; invariantes já satisfeitas sem vermelho artificial; falha de transação ainda testada; migration aplicada exige avaliar ambiente/integração, sem autorização para reversão em base compartilhada. Nenhum comando novo de operação foi introduzido. Essa aprovação documental se refere ao diff local, não ao SHA do marco.

Limites: reinício cobre processo/pool, não VM ou servidor PostgreSQL; captura da data após lock conferida no código, sem simular virada durante espera. Cobertura não prova todos os interleavings. Formulário, normalização da virada e comandos consumidores pertencem às próximas tarefas e não recebem aprovação antecipada. TASK-021 não iniciada. Exclusões históricas de workflows/skills continuam preservadas.

## Revisão anterior preservada — TASK-018

Revisão independente `/root/review_task005` aprovada sobre o diff local da TASK-018 na base `6a6e56a2b4dfed0827558c0dda40f716440f3a7d`, integrado sem alterações executáveis em `9ec53063065ac434895baa70333d49824ee8fb91`. Associações many_to_many, unicidade e FKs compostas garantem vínculos próprios. Gate independente: 55 testes, 84,05% total, TaskLabel/Task/Label 100%, limiar 70% preservado; precommit relatado aprovado. Sem achados bloqueantes. Evidências e limites completos na TASK-018; cadastro atômico, deduplicação de entrada e concorrência em conexões independentes não foram avaliados.

O marco cobre TASK-018; aprovações anteriores permanecem abaixo, sem aprovação implícita de áreas excluídas. Coordenação encerrada após esta entrega por solicitação do responsável; TASK-019 não iniciada.

## Revisão anterior preservada — TASK-005

Revisão independente `/root/review_task005` aprovada sobre a árvore local da TASK-005 na base `2620271b4627841ae382213bfee0c0ce78ff6c47`, integrada sem alterações executáveis no commit `79a22bf045bdf89c8d767335a1c87f0554e0f4e3`. Cadastro no backlog, título validado e consultas com proprietário explícito atendem CA-002-01/08 parcial. Achado de título acima de 255 caracteres corrigido com coluna text e teste de persistência integral. Gate independente: 47 testes, 83,48% total, módulos novos 100%, limiar 70% preservado. Precommit relatado pelo implementador aprovado. Evidências completas na TASK-005; código de consumidoras futuras fora do escopo.

O marco anterior cobria somente TASK-005; a aprovação anterior das seis tarefas permanece documentada abaixo. Não há aprovação implícita de workflows, skills ou áreas excluídas.

## Revisão anterior preservada — alvo e487516

Resultado: **approved**, sem achados bloqueantes nas entregas indicadas. O marco acima permite retomar a revisão incremental conforme o [fluxo de review](fluxos/review.md#marco-persistente-de-revisão); não constitui aprovação de todo o planejamento ou do MVP completo.

## Base, alvo e escopo

O histórico de `docs/review.md` identifica `03e8d31` como o último commit que esvaziou o arquivo, removendo suas 105 linhas. Esse commit é a base solicitada, não uma aprovação anterior: o relatório removido tratava do planejamento e tinha resultado `changes_requested`.

Revisado o intervalo `03e8d31..e487516`, concentrado nas seis tarefas de implementação concluídas desde a base, seus testes, contratos e dependências. TASK-002 teve sua remoção implementada antes da base, em `f757265`, mas seu aceite ocorreu no intervalo: conferidos o estado resultante, referências residuais, teste de rotas e evidências de aceite. TASK-003 e TASK-012 já possuíam aceite humano; apenas seus registros foram consultados, sem executar novamente suas ações. A confirmação “o db esta limpo” está registrada na TASK-012.

O código executável local coincide com o alvo commitado. Quatro arquivos já estavam modificados antes desta revisão: `docs/blocks/001-cobertura-apos-remocao-crud.md`, `docs/blocks/README.md`, `docs/tasks/002-remover-crud-experimental.md` e `docs/tasks/README.md`. Foram preservados; suas alterações não integram a aprovação do SHA. Os registros históricos de bloqueio/autoavaliação foram distinguidos dos aceites posteriores. Alterações de workflows/skills no intervalo não são objeto desta revisão das entregas e não recebem aprovação implícita pelo marco.

## Critérios e evidências

| Tarefa | Conferência | Resultado |
| --- | --- | --- |
| TASK-036 | Testes verificam campos, valores, erros, escape de HTML, flash, links, temas e reconexão; asserções observáveis, sem mudança do limiar ou exclusões de cobertura. | Aprovada. |
| TASK-002 | Oito rotas experimentais ausentes; GET `/` preservado; módulos, fixture e migration experimentais ausentes, sem referências de produção. Preparação de base nova e ausência de reset na entrega original têm evidências históricas na tarefa. | Aprovada; nenhum reset executado nesta revisão. |
| TASK-001 | Locale fixo HTTP/LiveView, HTML pt-BR, conteúdo informado preservado, página base traduzida, plurais e nomes acessíveis; catálogos default/errors sem mensagens vazias ou fuzzy, exceto cabeçalhos convencionais. Controles, URLs e nomes próprios preservados. | Aprovada segundo SPEC-001 e decisão do BLOCK-002. |
| TASK-009 | Seeds reais repetidos com e sem usuário prévio preservam identidade, timestamps e outras identidades; consulta não cria usuário; fixtures isoladas; índice único e conflito ignorado sustentam idempotência. | Aprovada no escopo produtor de default-user. |
| TASK-016 | Date UTC por padrão e data explícita para testes; chamadas independentes, sem estado global. | Aprovada no escopo produtor de current-day. |
| TASK-010 | Trim e rejeição de nome vazio; proprietário fora do cast; consultas filtradas, IDs alheios/inexistentes rejeitados; FK; rollback externo remove nova label e preserva anteriores; nomes iguais não são fundidos. | Aprovada no escopo produtor de user-label-catalog. |

Dependências das entregas estão integradas no alvo. As evidências individuais anteriores permanecem nos arquivos das tarefas; esta rodada registra aqui a revisão conjunta solicitada, sem reescrever estados ou evidências históricas.

## Verificações reproduzidas

- Ajuda de `ci` e `precommit` consultada; aliases inspecionados em `mix.exs`.
- `rtk mix ci`: saída 0; compilação com warnings como erros, formatação e Credo estrito aprovados; **39 testes aprovados, 82,65% de cobertura total**, mínimo de 70% preservado.
- Cobertura de linhas via Mix/ExUnit: Accounts, User, Day e Label 100%; Labels 75%; CoreComponents 82,11%; Layouts 100%. Não foi medida novamente a base, portanto não se afirma variação de cobertura nesta rodada.
- Inspeção dos catálogos, migrations, seeds, APIs e testes; busca de referências ao CRUD encontrou apenas o teste negativo de rotas e link documental.
- `rtk mix precommit`: saída 0, 39 testes aprovados; não deixou alterações em código ou lockfile.
- `rtk git diff --check`: aprovado também após as alterações documentais; ancestralidade da base em relação ao alvo confirmada.

## Limites e observações

Nenhum defeito acionável encontrado no escopo revisado. Os testes cobrem HTTP, processos LiveView, renderização e transações; não exercitam JavaScript em navegador, queda física de rede ou criação simultânea do usuário em conexões independentes. PageHTML registra 0% na instrumentação apesar de testes HTTP e de renderização direta; a métrica não substitui suas asserções.

Painel, cadastro integrado tarefa-label e captura de uma data única por operação pertencem às consumidoras futuras. O rollback atual comprova composição com Repo, sem antecipar esse cadastro. Não foram repetidos resets humanos nem a preparação histórica da TASK-002. Aprovação técnica não autoriza publicação remota.

A regra de marco persistente adicionada ao fluxo nesta rodada é uma alteração documental local, fora do SHA aprovado. Sua autoavaliação por cenários confirma: aprovação avança; bloqueio/reprovação preservam; divergência local não aprova HEAD; ancestralidade inválida exige reconstrução; escopo excluído não é pulado.
