# BLOCK-003 — Escopo do teste de rotas do painel

- Estado: resolvido por decisão documental em 03/10/2026.
- Origem: TASK-006, em 03/10/2026, implementador `/root/implement_task025`.
- Base: `d6a43e9`, com TASK-025 integrada.

## Causa e evidência

O scaffold previsto na TASK-006 fornece painel/cadastro em `GET /tasks` e `GET /tasks/new`. O teste preservado da remoção experimental, `test/planner_web/controllers/task_controller_test.exs:4`, exige que essas duas rotas não existam, junto das antigas rotas Show/edição/mutações HTTP. Esse arquivo não está no `write_scope` da TASK-006. Ajustá-lo exige decisão de escopo; não foi modificado nem foi escolhido outro caminho de URL para contornar o conflito.

`rtk mix test test/planner_web/live/task_live_test.exs`: 3 testes aprovados (cadastro/recarga, validação em pt-BR e parâmetros forjados). `rtk mix precommit` e `rtk mix ci`: 107/108 testes aprovados, única falha no teste acima porque `GET /tasks` agora resolve para `TaskLive.Index`. Compilação, formatação e Credo aprovados; cobertura 90,40%, Index/Form 100%. O gate não está aprovado apesar da cobertura suficiente.

## Trabalho preservado e impacto

Diff local preservado: Index/Form gerados e adaptados, rotas, acesso pela página inicial, catálogos Gettext, testes LiveView e registro TASK-006. Sem staging/commit. Execução interrompida em `in_progress`; consumidoras permanecem impedidas até correção e integração.

## Decisão necessária e retomada

Planejador deve definir o contrato do teste de rotas após a introdução do painel, incluindo proprietário do arquivo afetado e autorização de escopo ou tarefa corretiva. Retomada exige decisão registrada nos contratos (ou correção integrada, conforme decisão), preservação da rejeição das superfícies CRUD não autorizadas e posterior execução dos gates completos. Nenhuma solução foi executada neste registro.

## Decisão e evidência de desbloqueio — 03/10/2026

Por solicitação explícita do usuário, o planejador ampliou o `write_scope` da TASK-006 para incluir `test/planner_web/controllers/task_controller_test.exs`. O contrato e o aceite agora permitem GET `/tasks` e `/tasks/new` em Index/Form e preservam a rejeição das seis rotas de Show/edição/mutações HTTP, além do teste da página inicial.

Conferida a presença dessa decisão no contrato da TASK-006: a causa era autorização de escopo e está resolvida, sem necessidade de tarefa corretiva ou nova dependência. Removido BLOCK-003 de `blockers`; preservados `in_progress`, diff e evidências anteriores. O pedido de desbloqueio autoriza encerrar este impedimento documental no planejamento.

A implementação do ajuste, os gates completos e a integração continuam pendentes. A falha conhecida é permitida somente como entrada da retomada. TASK-026 e consumidoras transitivas não estão liberadas até a conclusão operacional da TASK-006; este encerramento não declara testes aprovados nem revisão independente.
