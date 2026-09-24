# BLOCK-002 — Escopo da tradução da interface base

## Situação

Estado: resolvido. Tarefa de origem: TASK-001. Registro em 23/09/2026 pelo implementador `/root/implement_task001`.
Base inspecionada: `0c5f70d`, branch `feat/mvp`.

## Causa e evidências

A [TASK-001](../tasks/001-troca-de-idiomas.md) exige interface base pt-BR e mensagens da base traduzidas. A [SPEC-001](../specs/001-idiomas.md), RN01, inclui páginas. Contudo, o `write_scope` autoriza configuração, layouts, catálogos e testes, sem incluir `lib/planner_web/controllers/page_html/home.html.heex`.

A página inicial preservada contém textos literais em inglês sem Gettext: linha 60 (`Peace of mind from prototype to production.`), linha 63 (descrição), linhas 84 (`Guides & Docs`), 101 (`Source Code`), 130 (`Changelog`), 147, 162, 177 e 192 (links da comunidade e publicação). Portanto, traduzir somente layouts e catálogos não traduz essa página. O teste `test/planner_web/controllers/page_controller_test.exs` também espera a frase inglesa da página inicial.

Esses fatos demonstram divergência entre o aceite e o escopo autorizado. A hipótese de excluir a página provisória do aceite não foi adotada: exige decisão explícita de planejamento.

## Trabalho preservado e impacto

Nenhum código ou teste foi alterado antes da interrupção. Apenas este registro, o índice de bloqueios e o estado/evidências da TASK-001 foram atualizados. Alterações documentais preexistentes de outras tarefas foram preservadas.

A TASK-001 não pode concluir o aceite integral nem liberar consumidoras enquanto persistir a divergência. Nenhum teste, precommit ou CI foi executado nesta tentativa; a inspeção não constitui aprovação.

## Decisão necessária e retomada

O planejador deve alinhar explicitamente a definição de interface base, o aceite e o `write_scope`: decidir o tratamento dos textos da página inicial e registrar a responsabilidade por sua tradução, sem deixar RN01 implicitamente descumprida.

Retomar somente após decisão registrada nos contratos pertinentes e validada pelo coordenador. Caso a decisão introduza tarefa corretiva, registrar a dependência no grafo sem duplicá-la em `blockers`. Este relatório não escolhe a solução nem autoriza ampliação de escopo.

## Decisão do planejador — 24/09/2026

Causa confirmada: lacuna no escopo autorizado, sem necessidade de novo comportamento de produto ou tarefa corretiva. A página inicial preservada integra a interface base da TASK-001 e deve cumprir RN01. Seu template foi acrescentado ao `write_scope` da tarefa, com responsabilidade explícita pela tradução de chamada, descrição, links e nomes acessíveis via Gettext; nomes próprios, URLs e versões permanecem preservados. Não excluir a página do aceite, removê-la ou substituí-la pelo painel.

O contrato da TASK-001 agora explicita entradas e aceites de GET `/`, recarga e renderização, incluindo atualização de `page_controller_test.exs` e `page_html_test.exs`, este último já presente após a TASK-036. Os testes continuam cobrindo links, temas e reconexão. Configuração, catálogos e gates permanecem no contrato original; nenhuma redução de cobertura foi autorizada.

Sem nova tarefa ou aresta: TASK-001 mantém TASK-002 como dependência e permanece produtora única de `ptbr-interface`. A decisão deixou de estar pendente em `blockers`, mas a fase `in_progress` e a interrupção ficam preservadas até a conferência do coordenador. As consumidoras continuam aguardando a entrega aprovada e integrada da TASK-001.

Condição de retomada: o coordenador conferir a inclusão do template e os critérios acima no contrato da TASK-001, registrar essa validação e encerrar este relatório. A causa é documental; não exige tradução implementada para encerrar o BLOCK-002. A tradução e seus gates serão exigidos no aceite da TASK-001. Estado do relatório permanece aberto, aguardando essa conferência; nenhum código foi implementado nem teste executado neste planejamento.

## Conferência da coordenação — 24/09/2026

Coordenador `/root`, base `0c5f70d`: conferidos o template inicial no `write_scope`, as entradas de testes e os critérios 3–5 da TASK-001 contra RN01 da SPEC-001 (`ready`). A decisão explícita está registrada no contrato disponível na árvore de trabalho e satisfaz a condição documental de retomada. BLOCK-002 encerrado; TASK-001 retomada em `in_progress`, com revisão independente e gates ainda pendentes. TASK-002 e TASK-036 têm aceite registrado e commits integrados na base. Alterações documentais preexistentes foram preservadas.
