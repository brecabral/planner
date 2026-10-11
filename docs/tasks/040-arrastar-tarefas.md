---
id: "TASK-040"
status: in_review
execution_level: advanced
execution_rationale: "Integra ordenação transacional, migration de dados e DOM temporário com streams e gestos touch."
specs: ["SPEC-002", "SPEC-003", "SPEC-004"]
depends_on: ["TASK-038", "TASK-039"]
provides: ["persistent-task-drag"]
consumes: ["task-registration-failure-feedback", "planner-renewed-interface"]
write_scope: ["lib/planner/", "lib/planner_web/live/", "assets/", "priv/", "test/", "docs/", "README.md"]
blockers: []
---

# 040 — Arrastar tarefas com mouse e touch

Execução direta do plano aprovado pelo usuário em 09/10/2026. Preservar a renovação [TASK-039](039-renovar-experiencia.md), produtora da interface consumida por esta tarefa. Dependências do MVP integradas; TASK-039 integrada no snapshot `8f1402a`, com conferência operacional registrada em `452083a` antes da correção R2. Nenhum pré-requisito humano pendente.

Contrato: SPEC-002 RN08–RN10/CA-002-09–11, SPEC-003 CA-003-07 e SPEC-004 RN14–16/CA-004-12–13. Reordenar hoje/backlog/retry, transferir somente backlog/retry → hoje e hoje → backlog, mantendo cota e transações. Concluir visível, demais ações no menu. Histórico somente consulta. Sem sincronização entre abas ou reabertura. Gates do agente: testes de domínio/LiveView, compilação de assets, precommit e ci com cobertura mínima 70%. Por decisão posterior do usuário, testes de UI/UX e gestos no navegador serão feitos por ele, sem exigir sua execução pelo agente.

## Correção pendente — R2 da revisão de 10/10/2026

Pacote de correção preservado abaixo como contrato. Correção implementada e revalidada nesta sessão; evidências ao final. Estado atual `in_review`, sem encerramento presumido da revisão independente.

Objetivo: completar o cancelamento funcional previsto em SPEC-004 RN16, removendo os resíduos temporários do arraste sem enviar movimento nem substituir os nós dos streams. O [achado R2](../review.md#r2--p2-cancelamento-deixa-resíduos-do-arraste-no-dom) é procedente frente ao contrato de restauração do DOM; os gates anteriores não executam o hook e não comprovam esse aceite.

### Entradas e limites

- Ler `assets/js/task_drag.js`, a integração em `assets/js/app.js`, os estilos de arraste em `assets/css/app.css` e o markup de listas/alças em `lib/planner_web/live/task_live/index.ex`.
- Consultar [SPEC-004 RN14–RN16 e CA-004-12–13](../specs/004-experiencia-e-acesso.md), [design D16](../design.md#d16--movimentação-persistida-de-pendências) e as referências de [LiveView/JavaScript](../referencias/liveview-javascript.md), [testes](../referencias/testes.md) e [Mix](../referencias/mix.md).
- Conferir o ciclo de cancelamento/destruição na versão instalada de SortableJS, resolvida em `assets/package-lock.json`. A revisão relata que `destroy()` chama `_onDrop()` sem evento e apaga referências sem limpar todos os artefatos; não presumir limpeza completa pela biblioteca.
- Restringir a correção ao hook, aos testes técnicos necessários e, se indispensável, aos estilos de arraste. Não alterar domínio, migration, cota, contratos de eventos, dependências npm ou a interface produzida pela TASK-039 para contornar o achado. Manter nível `advanced` pela integração sensível entre ciclo de vida, DOM e streams.

### Aceites da correção

1. Com gesto ativo e artefato fallback anexado ao body, um patch cancela o gesto antes da atualização: nenhum evento de movimento é enviado; ghost/clone e demais artefatos do gesto são removidos; classes e estilos temporários são desfeitos, preservando os valores anteriores do item. Os mesmos nós voltam à ordem e aos pais capturados antes de o patch aplicar o estado do servidor.
2. No mesmo estado inicial, a desconexão executa a mesma limpeza sem enviar movimento, mantém novos movimentos bloqueados enquanto desconectado e permite retomá-los após reconexão e recomposição do estado confirmado. Não restam elementos flutuantes fora dos streams.
3. Cancelamento repetido, cancelamento sem gesto ativo e destruição do hook após cancelamento não lançam erro, não removem elementos legítimos e não deixam listeners ou referências do gesto ativos. A limpeza deve ocorrer antes de perder as referências necessárias aos artefatos.
4. Após cancelamento e retomada, um novo drop válido continua enviando exatamente um evento, com restauração dos mesmos nós antes do envio e confirmação apenas após persistência. Preservar rejeição pelo servidor e bloqueio durante operação pendente.

### Validação e conclusão

Aplicar TDD enxuto à regressão técnica do hook, cobrindo separadamente patch e desconexão, identidade/ordem dos nós, restauração de classes/estilos, ausência de artefatos e ausência de evento de movimento. Usar a dependência instalada no caminho exercitado ou explicitar os limites de um harness; um mock que já limpe tudo em `destroy()` não reproduz R2. Incluir idempotência e novo drop válido. Não instalar navegador nem tornar teste de UI/UX ou avaliação humana um gate; a dispensa de CA-004-13 permanece. Registrar o que foi automatizado e o que depende de inspeção, sem atribuir execução JavaScript ao LiveViewTest.

Após a correção, compilar assets, executar os gates previstos no [README](../../README.md), incluindo precommit e ci com limiar de 70% preservado, e registrar autoavaliação, resultados e limites. As evidências anteriores são históricas; não equivalem à validação da correção. Retornar a `in_review` somente após essa etapa; conclusão depende de conferência operacional e integração.

### Dependência e sequência

A TASK-039 é a produtora única de `planner-renewed-interface`. Esta tarefa consome seu painel, streams, modal e hooks e sobrepõe seus arquivos; não distribuí-las em paralelo. Antes de retomar a correção, conferir e integrar a TASK-039 na base de trabalho, preservando as alterações locais já existentes da TASK-040. A presença conjunta na árvore local não comprova integração. A dependência fica em `depends_on`, sem duplicação em `blockers`.

## Evidências anteriores à correção R2

Implementação retomada e validada em 10/10/2026 por `/root`. O responsável instalou SortableJS via npm antes da retomada; usada a versão 1.15.7 resolvida no lockfile, substituindo a previsão anterior de vendor. Preservadas a renovação TASK-039 e as alterações locais de setup/CI/npm. Registro histórico em [retomada](../retomada-task-040.md).

- Domínio: ordenação persistida nas três listas, transferências autorizadas na posição escolhida, cota/compactação atômicas, normalização ao final de retry e cadastro serializado pelo mesmo lock. Corrigido retorno de changeset para proprietário ausente/inexistente.
- Interface: hook externo `TaskDrag`, alças, pressão touch de 200 ms, animação, auto-scroll, destinos vazios e indicação de destinos permitidos/proibidos. Um evento por drop, restauração dos mesmos nós antes do envio, cancelamento do gesto antes de patches, bloqueio durante espera/desconexão e limpeza de listeners. Menus nas três listas; concluir permanece visível; histórico sem arraste.
- Migração: validada com dados antigos em schema temporário isolado e aplicada em desenvolvimento nesta sessão. Preserva identidade, conteúdo, datas, timestamps, posições de hoje e concluídas; inicializa backlog/retry e aplica restrições.

### Evidências por aceite

| Critério | Evidência executada |
| --- | --- |
| CA-002-09 | `task_movement_test.exs`: ordem persistida de backlog/hoje/retry, cadastro ao final e cota conservada. `tasks_test.exs`: compatibilidade de reorder_today e última ordem aceita sob concorrência. |
| CA-002-10 | Destino vazio e posições inicial/intermediária/final, preservação de labels, compactação, consumo/restituição e menu ao final nos testes de domínio. |
| CA-002-11 | Rejeição de payload malformado, origem/destino incorretos, duplicatas, IDs inválidos/alheios, conjuntos antigos, concluídas e cota esgotada. Constraint real após transferência provoca rollback de posições, virada e cota. Conexões PostgreSQL distintas comprovam espera pelo lock em cadastro/reordenação/movimento. |
| RN09 / migração | `task_order_migration_test.exs` executa migrations reais em schema isolado com dados anteriores; compara dados e posições e verifica rejeição de posições ausentes/não positivas/duplicadas. |
| CA-003-07 | Retry reordenado preservado durante duas viradas; vencidas entram por prioridade anterior; repetição idempotente. Histórico e conclusão continuam cobertos pela regressão. |
| CA-004-12 | `task_live_test.exs`: evento de arraste, reordenação pelo menu nas três listas, contadores, persistência após remontagem, dados de usuário/data forjados ignorados, erro traduzido e falha real de persistência sem gravação parcial. |
| CA-004-13 | Inspeção do hook contra as APIs instaladas de SortableJS/LiveView e compilação do bundle. Gestos/UI/UX não executados pelo agente, conforme dispensa do responsável; LiveViewTest não executa JavaScript. |

### Gates e autoavaliação

- `mix precommit`: aprovado, 157 testes, sem falhas.
- `mix ci`: aprovado, 157 testes, cobertura total **93,44%** (mínimo preservado em 70%); Tasks e TaskLive.Index **98,31%**, UserTransaction **100%**. Credo estrito sem achados; build Tailwind/esbuild aprovado; npm audit sem vulnerabilidades.
- O primeiro CI apontou complexidade em `move_with_orders`; validação das ordens foi extraída e o gate completo repetido com sucesso.
- Catálogos atualizados; ajuste final de liberação do hook após reconexão recompilado por `mix assets.build`. Não altera os caminhos Elixir medidos acima.
- `git diff --check` sem problemas. Não houve navegador, revisão independente, commit ou publicação.

Autoavaliação `/root`, conforme fluxo de review e skill `review-code-diff`: **approved no escopo técnico validado**, sem aprovação independente. Alvo é a árvore local não commitada da TASK-040 sobre HEAD `43ea80314c0a47a2a8357c17064cc01ac9ed5a40`, incluindo os arquivos novos de hook, migration e testes. O diff contra HEAD também contém TASK-039 e alterações preexistentes do responsável; esta avaliação não aprova essas entregas separadamente nem avança o marco independente de `docs/review.md`.

Na entrega anterior à revisão, estado `in_review`: implementação disponível localmente, aguardando conferência operacional e integração. A avaliação manual de gestos será realizada pelo responsável; não foi presumida como executada nem usada como bloqueio da implementação.

## Revisão independente — 10/10/2026

Revisor `/root`, árvore local sobre `43ea80314c0a47a2a8357c17064cc01ac9ed5a40`. **changes_requested**: R2, limpeza incompleta do arraste ao cancelar por patch/desconexão em `assets/js/task_drag.js:124`. Corrigir e revalidar antes do encerramento; status `in_review` preservado. Gate reproduzido: `rtk mix ci`, 157 testes, cobertura 93,44%, Credo/build/npm audit aprovados. JavaScript inspecionado, sem navegador. Evidências, limites e achado em [docs/review.md](../review.md#revisão-das-entregas-locais--10102026). Nenhum código corrigido ou commit criado.

Reconciliação de planejamento em 10/10/2026: tarefa devolvida a `in_progress`, conforme o [formato](formato.md#elegibilidade-e-conclusão), porque R2 exige alteração de código. Acrescentados pacote de correção e dependência da TASK-039. O registro da revisão acima preserva o estado daquela rodada; R2 continua aberto, sem correção ou aprovação presumida.

## Correção R2 e autoavaliação — 10/10/2026

Implementador `/root`. Antes da alteração, conferência operacional da TASK-039 registrada em `452083a`, sobre a entrega já integrada em `8f1402a`; dependência liberada sem reescrever o snapshot. Alvo da autoavaliação: diff local de `assets/js/task_drag.js`, novos testes em `assets/test/`, README e documentação pertinente sobre `452083a`. Skill `review-code-diff` e fluxo de review aplicados como autoavaliação, sem revisão independente ou avanço do marco em `docs/review.md`.

Correção: capturar atributos antes de Sortable alterar `will-change`; guardar referências do ghost/clone do próprio gesto antes de `destroy()` apagá-las; remover esses artefatos explicitamente; cancelar timers de animação e restaurar atributos, pais e ordem dos mesmos nós. Limpar referências do gesto e listeners na destruição. Preservados evento/payload, bloqueio pendente, invalidação de resposta antiga, domínio, dependências npm e interface da TASK-039.

TDD: após completar o suporte mínimo de DOM do harness, os dois testes de patch/desconexão falharam no código anterior porque o ghost ainda tinha `body` como pai após cancelar. O teste sem gesto já passava. Depois da correção, os cinco cenários abaixo passaram. O harness carrega e executa o arquivo instalado de SortableJS **1.15.7**, inclusive `_onTapStart`, início fallback, animação, `_onDrop`, `destroy()` e `_nulling()`; não usa um mock de `destroy()` que limpe os resíduos.

| Aceite | Evidência da correção |
| --- | --- |
| 1 — patch | Teste técnico inicia fallback, anexa ghost ao body e clone à lista, transfere item e anima vizinho. Cancelamento remove ambos os artefatos, restaura identidade/ordem/pais/classes/estilos (inclusive atributos antes ausentes), limpa timers/referências e não envia movimento. Elemento legítimo fora do stream com classe de preview é preservado. |
| 2 — desconexão | Cenário independente repete a limpeza; após remontagem, instâncias permanecem desabilitadas enquanto offline. Tentativa de início com `_onTapStart` não inicia gesto. Reconexão permite novo drop. |
| 3 — idempotência | Cancelamento repetido, sem gesto, destruição posterior e pressão touch ainda aguardando delay não lançam erro nem enviam evento. Listeners da biblioteca retornam à base global e os adicionados pelo hook são removidos em `destroyed`; timers controlados ficam vazios. |
| 4 — retomada | Drop real via `_onDrop(event)` após cada cancelamento envia exatamente um `move_task` com ordens finais; callback de envio verifica DOM já restaurado. Espera mantém instâncias desabilitadas até resposta. Resposta antiga após desconexão não libera uma nova operação pendente. A resposta de rejeição libera a espera; testes LiveView existentes cobrem rejeição/persistência/recomposição pelo servidor. |

Gates executados nesta correção:

- Teste JavaScript pelo Mix: **5 testes aprovados**.
- `mix precommit`: **157 testes aprovados**, compilação e formatação aprovadas.
- `mix ci`: **157 testes aprovados**, cobertura total **93,44%**, mínimo **70%** preservado; Credo estrito sem achados, build de assets incluído aprovado e npm audit sem vulnerabilidades.
- `git diff --check`: aprovado.

Limites: DOM e timers mínimos controlados; a movimentação entre listas e a ordem de chamada dos eventos são montadas pelo harness. Não há layout, propagação completa de eventos, execução dos patches reais de LiveView ou avaliação de mouse/touch em navegador. A cobertura percentual é Elixir e não mede o hook. A validação manual de CA-004-13 permanece com o responsável, sem constituir gate humano. Comando técnico e seus limites documentados no README; nenhuma dependência nova instalada.

Autoavaliação: **approved no escopo técnico validado**, R2 corrigido sem achado bloqueante identificado. Estado `in_review`, aguardando conferência operacional e integração da correção. Nenhum commit da TASK-040, publicação remota ou nova aprovação independente nesta entrega.

## Revalidação independente — 11/10/2026

Revisor `/root`, sem implementação nesta sessão: **approved no escopo técnico local**, R2 resolvido. Alvo: correção não commitada sobre `452083a6a4a117a39622c96bd1aec4bf9cd60f50`, incluindo hook e testes técnicos. Reproduzidos os cinco testes JavaScript e `mix ci`: 157 testes Elixir aprovados, cobertura 93,44%, Credo/build/npm audit aprovados. Inspeção contra SortableJS instalado confirma limpeza antes da perda das referências e restauração dos nós; sem navegador. Evidências e limites em [revisão de prontidão](../review.md#prontidão-do-mvp-e-revalidação-de-r2--11102026). Estado `in_review` preservado até integração e conferência operacional; marco commitado não avançado porque a correção continua local. Nenhum commit ou publicação.
