---
name: coordinate-blockers
description: Interromper e encaminhar impedimentos de execução do Planner, preservar evidências em docs/blocks e retomar após correção aprovada e integrada; não decidir solução nem ampliar escopo no lugar do planejador.
---

# Coordenar impedimentos e retomada

Aplicar o [fluxo de coordenação](../../fluxos/coordenacao.md) e o [protocolo de bloqueios](../../blocks/README.md). Esta skill cuida da interrupção e do encaminhamento; decisões de solução pertencem ao planejador.

## Parar e preservar

Distinguir falha esperada de TDD ou correção rotineira dentro do contrato de impedimento que exige outra decisão, capacidade, dependência ou escopo. Diante deste último, confirmar a parada do implementador; se ainda estiver executando, interrompê-lo. Não delegar a outro agente a mesma ampliação de escopo.

Inspecionar o estado após a parada: diff, arquivos novos e operações ainda em andamento. Preservar trabalho e alterações alheias; não usar limpeza ou reset para obter uma árvore limpa. Suspender consumidoras, mantendo apenas trabalho independente e autorizado. Uma ordem do usuário para interromper toda a execução prevalece sobre continuar tarefas independentes.

## Registrar e encaminhar

Reutilizar o relatório da mesma causa em `docs/blocks`, conforme seu protocolo. Vinculá-lo à tarefa e ao índice de bloqueios quando for novo. Registrar base, evidências e hipótese separadamente, trabalho preservado, impacto, decisão necessária e condição verificável de retomada. Não afirmar que a árvore ficou intacta sem inspecioná-la.

Preservar a fase `in_progress` ou `in_review`. Causa sem solução planejada fica em `blockers`; quando o planejador definir uma tarefa corretiva, a dependência pertence a `depends_on`, sem duplicar a aresta em `blockers`. Não modificar contratos ou criar uma corretiva durante a coordenação apenas para manter a fila andando.

Encaminhar ao planejador o relatório e as tarefas afetadas, indicando a decisão pendente. A skill [plan-unblocking](../plan-unblocking/SKILL.md) pode apoiar esse trabalho quando o planejamento for solicitado; não ativá-la como autorização automática para assumir esse perfil.

Se for necessária execução humana, informar ID/título e ação da pessoa. Recomendação do agente, passagem de tempo ou desaparecimento de um erro não substituem confirmação e evidência de aceite humano.

## Retomar com evidência

Quando existir corretiva aprovada no plano, verificar sua elegibilidade e a base real antes de delegar. Código disponível e aceite são fatos distintos: corrigir o gate de uma entrega já presente pode ser legítimo sem depender da aprovação que esse gate impede. Se o grafo criar esse ciclo, devolvê-lo ao planejador, sem remover arestas por conta própria.

Encerrar o relatório somente quando sua condição de retomada estiver comprovada. Para correção de código, exigir validação, revisão independente e referência da entrega integrada; planejamento ou testes sem integração não bastam. Usar [coordinate-delivery](../coordinate-delivery/SKILL.md) para conduzir esse aceite. Para decisão de produto, exigir decisão explícita registrada nos contratos afetados; para execução humana, exigir confirmação e evidência de aceite conforme o AGENTS.md, sem substituí-las por revisão de agente. Não exigir uma alteração de código quando a causa foi resolvida sem implementação.

Depois, retomar a tarefa de origem na fase interrompida. Resolver cobertura, ambiente ou dependência não aprova automaticamente a entrega original: sua revisão pendente permanece necessária. Reavaliar a fila pelo grafo atual e informar o que foi resolvido e o que ainda falta.
