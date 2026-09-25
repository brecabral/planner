# BLOCK-001 — Cobertura após a remoção do CRUD experimental

## Situação

Estado: resolvido. Tarefa de origem: TASK-002. Registro em 23/09/2026.

A execução anterior foi interrompida antes de ampliar a suíte. O planejamento atribuiu a correção à [TASK-036](../tasks/036-cobertura-base.md), sem autorizar mudanças na configuração humana do CI.
Base inspecionada no diagnóstico: `03e8d31`, contendo a remoção do CRUD no commit `f757265`. A [TASK-002](../tasks/002-remover-crud-experimental.md) estava `in_review`. A [TASK-012](../tasks/012-reset-banco.md) está `done`, com confirmação humana de base limpa; nenhum novo reset é necessário.

## Evidências

- A entrega da TASK-002 passou pelo teste de intenção das rotas e página inicial e pelo `mix precommit`, com 7 testes aprovados.
- O CI da entrega falhou com cobertura de 35,18%, abaixo do mínimo obrigatório de 70%. O diagnóstico do subagente `/root/task002_coverage` (gpt-6-sol) reproduziu 35,18% com `mix test --cover`, mantendo os 7 testes aprovados.
- O diagnóstico identificou lacunas em `PlannerWeb.CoreComponents` (17,07%) e `PlannerWeb.PageHTML` (0%). São componentes da base Phoenix preservada, não funcionalidades novas do domínio.
- A política atual exige 70% de cobertura. A descrição histórica de cobertura informativa no registro da TASK-002 não corresponde à política vigente; o limiar não deve ser reduzido e código não deve ser excluído da medição apenas para aprovar o gate.
- Após interromper o subagente, a árvore de trabalho estava limpa: nenhum teste ou alteração de implementação desta tentativa ficou pendente.

## Decisão e critérios de retomada (histórico)

A TASK-036 cobre os comportamentos da base Phoenix preservada e deve entregar o gate com pelo menos 70%, sem reduzir o limiar ou excluir módulos. A configuração da TASK-003 permanece concluída; o impedimento é a ausência de testes suficientes.

A TASK-002 passou a depender dessa correção para retomar seu aceite. Sua remoção já está na base, portanto a TASK-036 não depende da conclusão da TASK-002. Até o aceite, as consumidoras ficaram impedidas transitivamente pelas dependências do grafo.

Encerrar este registro somente após revisão independente e integração da TASK-036 com evidência de `mix ci` aprovado e cobertura mínima de 70%. Depois, retomar a revisão independente da TASK-002; resolver a cobertura não equivale a aprovar sua entrega.

## Resolução

Concluída conforme as evidências de encerramento abaixo. A atualização do planejamento definiu a correção; sua execução e revisão ocorreram posteriormente.

### Encerramento — 23/09/2026

Estado final: resolvido. TASK-036 aprovada por revisão independente do coordenador `/root` e integrada no commit `8c6d655`, com conclusão registrada em `952d05a`. Gate reproduzido pelo revisor: `POSTGRES_TEST_DB=planner_coord_20260923 mix ci`, saída 0, 21 testes aprovados e cobertura 75,38%, sem mudanças na política de medição. A revisão separada da TASK-002 também foi concluída e registrada na tarefa.
