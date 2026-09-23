---
name: reconcile-plan
description: Reconciliar documentação e tarefas do Planner com respostas do usuário, entregas e reviews de planejamento, preservando evidências e o contexto próprio de cada arquivo.
---

# Reconciliar o plano

Usar quando o plano existente divergir de decisões ou evidências novas. Não realizar revisão de código nem revalidar infraestrutura já aceita apenas para atualizar documentação; avaliações de código seguem o fluxo de review do projeto.

1. Partir do pedido ou review indicado. Para cada mudança relevante, localizar a regra vigente e classificar a informação como decisão explícita, evidência de execução, proposta ou dúvida. Um review é uma análise a conferir, não uma autoridade que substitui o pedido do usuário.
2. Avaliar os achados contra os contratos atuais. Corrigir os procedentes; explicar brevemente os rejeitados ou superados. Não transportar propostas antigas para o plano depois que seu motivo deixou de existir.
3. Editar somente as fontes afetadas: objetivos/escopo no PRD; comportamento na spec; decisão arquitetural no design; vocabulário no DDD; execução e evidências na tarefa; impedimento em docs/blocks; operação no README. Referenciar a fonte quando necessário para executar o contrato, sem criar uma rede de leituras irrelevantes.
4. Preservar IDs, trabalho existente e resultados históricos. Distinguir implementação presente, gate aprovado, revisão independente e integração. Não converter documentação pronta em entrega concluída. Para tarefa humana, seguir os requisitos de confirmação e evidência do AGENTS.md sem repetir a execução aceita.
5. Se o contrato ou a ordem mudar, conferir cabeçalhos e consumidoras atingidas com [plan-task-graph](../plan-task-graph/SKILL.md). Remover apenas bloqueios resolvidos por evidência; encaminhar impedimentos restantes com [plan-unblocking](../plan-unblocking/SKILL.md).
6. Verificar links, índices, ausência de contradições e leitura local: uma tarefa deve conter seu objetivo, entradas, aceite e limites sem exigir toda a documentação. Remover memória de conversa e justificativas deslocadas, mantendo a evidência necessária à retomada.

Entregar alterações materiais, achados ainda abertos e próxima ação possível. Não editar o review histórico para simular aprovação nem repetir seu conteúdo em cada documento corrigido.
