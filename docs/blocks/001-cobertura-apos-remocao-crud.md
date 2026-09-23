# BLOCK-001 — Cobertura após a remoção do CRUD experimental

## Situação

Em 23/09/2026, a continuação da TASK-002 foi interrompida por solicitação do responsável. A decisão sobre como tratar a lacuna cabe ao planejador. Não há autorização para prosseguir com a ampliação da suíte proposta nesta investigação.

Base inspecionada: `03e8d31`, contendo a remoção do CRUD no commit `f757265`. A [TASK-002](../tasks/002-remover-crud-experimental.md) permanece `in_review`. A [TASK-012](../tasks/012-reset-banco.md) está `done`, com confirmação humana de base limpa; nenhum novo reset é necessário.

## Evidências

- A entrega da TASK-002 passou pelo teste de intenção das rotas e página inicial e pelo `mix precommit`, com 7 testes aprovados.
- O CI da entrega falhou com cobertura de 35,18%, abaixo do mínimo obrigatório de 70%. O diagnóstico do subagente `/root/task002_coverage` (gpt-6-sol) reproduziu 35,18% com `mix test --cover`, mantendo os 7 testes aprovados.
- O diagnóstico identificou lacunas em `PlannerWeb.CoreComponents` (17,07%) e `PlannerWeb.PageHTML` (0%). São componentes da base Phoenix preservada, não funcionalidades novas do domínio.
- A política atual exige 70% de cobertura. A descrição histórica de cobertura informativa no registro da TASK-002 não corresponde à política vigente; o limiar não deve ser reduzido e código não deve ser excluído da medição apenas para aprovar o gate.
- Após interromper o subagente, a árvore de trabalho estava limpa: nenhum teste ou alteração de implementação desta tentativa ficou pendente.

## Decisão necessária

O planejador deve definir o escopo e a tarefa responsável pela cobertura dos comportamentos preservados, com critérios de aceite e dependências explícitos. A hipótese investigada foi acrescentar testes de HTML renderizado para componentes de apresentação, formulários e página inicial. Essa hipótese não foi implementada nem aprovada como solução.

A decisão deve esclarecer se esse trabalho pertence à correção da TASK-002 ou a uma entrega própria, sem alterar a reserva humana da configuração do gate na [TASK-003](../tasks/003-infra-github.md).

## Impacto e retomada

A TASK-002 continua sem CI aprovado e sem revisão independente aprovada. A [TASK-001](../tasks/001-troca-de-idiomas.md) depende de sua conclusão; a liberação da TASK-012, isoladamente, não libera a cadeia do MVP.

Retomar somente após a decisão do planejador e a atualização dos contratos afetados. Em seguida, executar a solução autorizada, registrar evidências do gate e encaminhar ao revisor independente. Este registro não marca tarefas como concluídas nem modifica o grafo.
