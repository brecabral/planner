---
review_base_commit: "aafed16d7b7a09000404e716cc98dcc43763510e"
reviewed_commit: "2b8ba19ce2657126423256d3fd2596875c7ca661"
last_approved_commit: "2b8ba19ce2657126423256d3fd2596875c7ca661"
reviewed_at: "2026-10-05"
reviewer: "/root/review_mvp_readiness — revisão independente do MVP"
status: approved
reviewed_tasks: ["TASK-006", "TASK-007", "TASK-008", "TASK-022", "TASK-023", "TASK-024", "TASK-025", "TASK-026", "TASK-027", "TASK-028", "TASK-029", "TASK-030", "TASK-032", "TASK-037", "TASK-038"]
---

# Revisão incremental das tarefas concluídas

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
