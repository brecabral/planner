---
name: coordinate-dispatch
description: Selecionar tarefas elegíveis do Planner e distribuir trabalho autorizado a subagentes conforme capacidade, dependências e conflitos; não planejar novas tarefas nem iniciar execução ao apenas consultar a fila.
---

# Distribuir trabalho do Planner

Aplicar o [fluxo de coordenação](../../fluxos/coordenacao.md). Distinguir pedido para consultar a fila de autorização para executar: criar skills, assumir um perfil ou listar tarefas não inicia implementadores.

## Selecionar a próxima entrega

- Ler estado do Git, cabeçalhos das tarefas e impedimentos pertinentes. Usar a elegibilidade do [formato](../../tasks/formato.md); carregar corpos, specs e evidências somente para candidatas e suas dependências relevantes.
- Conferir que a base efetiva contém os contratos aprovados das dependências. `blockers: []`, código presente, commit existente ou mensagem de conclusão isolados não comprovam liberação. `in_review` exige retomar o aceite, não iniciar suas consumidoras.
- Para reserva humana pendente, informar ID, título, ação necessária e consumidoras impedidas. Não tratar “destravada” como confirmação de execução: verificar o registro de aceite humano antes de prosseguir.
- Se houver falha conhecida, consultar a decisão no relatório. Uma tarefa corretiva planejada pode partir dessa falha quando seu contrato a assume expressamente; isso não libera a tarefa de origem. Sem solução planejada, usar [coordinate-blockers](../coordinate-blockers/SKILL.md).
- Confrontar `write_scope`, recursos produzidos/consumidos e efeitos semânticos antes de paralelizar. Checkouts separados evitam colisão de arquivos, mas não resolvem dependência de contrato. Serializar escopos conflitantes; preservar alterações preexistentes do usuário.

## Preparar a delegação

Selecionar capacidade pelo ponto mais exigente de `execution_level` e sua justificativa. Usar os modelos e ferramentas disponíveis e a autorização vigente; não fixar uma tabela universal entre nível e modelo, nem rebaixar a tarefa para caber no runtime. Não criar tarefas de aplicativo como substituto de subagentes sem pedido explícito.

Enviar um pacote curto, suficiente para execução sem reconstruir a conversa:

- ID e caminho da tarefa, checkout/branch e base de comparação; estado preexistente relevante.
- Escopo e exclusões, contratos integrados de entrada, critérios de aceite e referências a ler.
- Capacidade/modelo selecionado, responsabilidades e possíveis escritores concorrentes.
- Validações exigidas pelo contrato e gate vigente; evidências esperadas por critério e base testada.
- Obrigação de seguir o fluxo de implementação, parar e registrar impedimentos pelo protocolo; staging e commits reservados ao coordenador no diretório compartilhado.

Não incluir credenciais, histórico inteiro ou toda a documentação. Se capacidade ou contrato forem insuficientes, encaminhar a limitação antes de iniciar mudanças.

## Acompanhar

Manter a associação tarefa → agente → escopo/base enquanto houver trabalho ativo, sem criar outro arquivo de estados paralelo ao grafo. Acompanhar resultados e intervenções do usuário; ao receber ordem de parada, interromper o agente antes de investigar o diff. Se alguma operação estiver em andamento, verificar o estado após sua interrupção antes de afirmar que nada mudou.

Receber retorno com arquivos alterados, evidências por critério, comandos/resultados e limitações. Encaminhar entrega para [coordinate-delivery](../coordinate-delivery/SKILL.md) e impedimento para [coordinate-blockers](../coordinate-blockers/SKILL.md). Recalcular a fila somente após liberação efetiva das dependências.

Informar tarefas distribuídas, capacidade escolhida e razão concreta das que ficaram impedidas. Se não houver candidata elegível, não inventar trabalho para ocupar agentes.
