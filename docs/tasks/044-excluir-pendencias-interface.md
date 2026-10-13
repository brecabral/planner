---
id: "TASK-044"
status: "done"
execution_level: "standard"
execution_rationale: "Integra operação pronta com confirmação e atualização de streams e contadores."
specs: ["SPEC-004", "SPEC-002"]
depends_on: ["TASK-043"]
provides: ["pending-task-deletion-ui"]
consumes: ["delete-pending-task"]
write_scope: ["lib/planner_web/live/task_live/", "priv/gettext/", "test/planner_web/live/task_live_test.exs", "docs/tasks/044-excluir-pendencias-interface.md"]
blockers: []
---

# 044 — Confirmar e excluir pendências pelo painel

## Objetivo e entradas

Implementar SPEC-004 RN19/CA-004-16 consumindo a operação da TASK-043. Ler painel/menu, diálogos existentes e referências HEEx/formulários/LiveView/Gettext/testes. Sem scaffold; reutilizar composição do painel.

## Aceite e testes

1. Menu de cada pendência oferece excluir com confirmação explícita da remoção definitiva da tarefa identificada; cancelar não envia mutação. Histórico não oferece ação.
2. Confirmar chama domínio com usuário do servidor; eventos forjados para concluída/ID alheio não removem dados. Sucesso atualiza listas, contadores e cota somente após persistência.
3. Falha mantém estado e informa erro pt-BR; conflito recupera snapshot. Testar cancelar/confirmar, cada origem e ausência no histórico, sem prometer validação de diálogo real por LiveViewTest.
4. Não adicionar desfazer, reabertura ou exclusão de labels. Preservar menus à esquerda e cadastro com rascunho.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.


## Entrega — 12/10/2026

Implementador `/root/implement_task042`, capacidade herdada suficiente para standard; base `a1d58868298945688123006d2a4d86507ec2c8c2`, branch `feat/ux`, árvore inicialmente limpa. TASK-043 integrada e `done`; specs prontas, sem bloqueios. Cinco arquivos no escopo: TaskLive.Index, teste LiveView, catálogos `.pot`/`pt_BR.po` e esta tarefa.

Menu oferece “Excluir tarefa” nas três listas. A solicitação carrega somente tarefa própria pendente e abre confirmação renderizada pela LiveView, identificando título e irreversibilidade. A confirmação usa `focus_wrap` existente com foco inicial no botão cancelar; cancelar limpa apenas o assign, sem chamada de mutação do domínio. O ID selecionado fica no servidor e a confirmação ignora ID/proprietário do payload. A API da TASK-043 revalida estado sob lock; sucesso, erro e conflito reutilizam o tratamento de persistência e recomposição de streams/contadores existentes. Histórico não recebe controles novos.

| Aceite | Evidência e resultado |
| --- | --- |
| 1 — menu/confirmação/cancelamento | Três testes parametrizados verificam menu esquerdo, título identificado e aviso definitivo em pt-BR, cancelar com snapshot idêntico, nova confirmação e remoção nas origens backlog/retry/hoje. Histórico sem ação é verificado por seletor. |
| 2 — autoridade/persistência | Eventos forjados para concluída/alheia/inexistente/nil/malformada não abrem confirmação e não removem dados; confirmar sem seleção devolve indisponível. Teste específico confirma tarefa selecionada mesmo com payload apontando para tarefa/proprietário alheios, preservando tarefa alheia e outra própria. Recarga confirma persistência; consumo/contadores são recompostos pelo servidor. |
| 3 — falha/conflito | Exclusão externa entre abertura e confirmação produz erro pt-BR, snapshot atualizado e nenhum anúncio falso de sucesso. Constraint de restituição força falha de persistência e confirma tarefa/cota intactas, erro visível e rascunho do cadastro preservado. |
| 4 — preservação de escopo | Testes de menus à esquerda, títulos/labels longos, cadastro e demais ações permanecem verdes. Nenhuma ação de desfazer/reabrir/excluir label ou alteração de hook/domínio introduzida. |

TDD: cinco testes novos falharam inicialmente por menu e eventos ausentes, com setup válido; após implementação os 43 testes LiveView então presentes passaram. Teste adicional de autoridade do ID confirmado integrou os gates completos.

Validações via RTK, usando ajudas Mix já consultadas nesta sessão: `mix test test/planner_web/live/task_live_test.exs` (vermelho e depois **43 aprovados** naquele estágio); `mix gettext.extract --merge --no-fuzzy` (quatro mensagens novas traduzidas para pt-BR); `mix precommit` (**180 aprovados**); `mix ci` (**180 aprovados**, cobertura total **93,77%**, TaskLive.Index **98,59%**, mínimo 70% preservado, Credo estrito sem achados, assets compilados e npm audit sem vulnerabilidades); `git diff --check` aprovado.

Autoavaliação pelo fluxo de review: **approved no escopo técnico validado**, sem achados bloqueantes, sobre os quatro arquivos locais de código/teste/catálogo contra a base acima. Cobertura total anterior: 93,50%; atual: 93,77%. Não é revisão independente e não avança o marco independente. LiveViewTest comprova HTML, eventos, mensagens e persistência; não executa layout, foco, teclado, modalidade ou diálogo no navegador. Nenhuma validação visual real foi realizada. Hook não alterado, portanto teste JavaScript adicional não se aplica.

Estado `in_review`: aguarda conferência operacional e commit de integração pelo coordenador. Sem staging, commit, publicação ou início de consumidoras pelo implementador.

### Conferência operacional — 12/10/2026

Coordenador `/root`: entrega integrada em `5f8049d` na branch `feat/ux`. Conferidos escopo, autoavaliação, gates relatados aprovados (180 testes, cobertura 93,77%) e ausência de impedimentos. Sem reprodução de testes ou revisão independente. Estado anterior histórico; conclusão operacional libera TASK-015. Limites da validação em navegador preservados.

### Revisão independente — 13/10/2026

Revisor `/root`, alvo `b0810ba49cf6049c7d5aac49960950a5236be22b`, base reconstruída `367bf3555bc2b06e5ce90aedc2118e46e00986de`. Sem achado bloqueante identificado no contrato desta entrega. Parecer global changes_requested por R3 no cadastro de contas. `mix ci`: 240 testes aprovados, cobertura 94,08%; testes JavaScript de arraste/tema: 9 aprovados. Escopo, reprodução adicional com falha, achados documentais e limites em [docs/review.md](../review.md#revisão-das-últimas-entregas-e-documentação--13102026). Sem correção de produto ou mudança do estado operacional nesta revisão.
