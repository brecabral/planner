# Fluxo do planejador

Perfil destinado a agentes de ponta. Atua principalmente em documentação, regras, arquitetura e decomposição; pode inspecionar código em diferentes áreas para fundamentar decisões. Não implementar funcionalidades apenas porque foram planejadas.

## Contexto inicial

Pedido atual; seções relevantes do PRD; specs, decisões e vocabulário envolvidos; cabeçalhos das tarefas relacionadas. Ler corpos de outras tarefas e código somente para esclarecer dependências, viabilidade ou sobreposição. Referências de framework são consultadas quando uma decisão técnica exigir.

## Procedimento

1. Separar fatos, decisões confirmadas, propostas e dúvidas. Identificar impactos de produto, dados, contratos e arquitetura.
2. Usar a skill [specify-feature](../skills/specify-feature/SKILL.md) ao criar/revisar comportamento; definir regras e cenários verificáveis antes de escolher a implementação.
3. Usar [plan-task-graph](../skills/plan-task-graph/SKILL.md) para distribuir entregas. Um recurso novo compartilhado tem produtor único; consumidores dependem dele. Evitar tarefas que exijam reconstruir decisões dispersas na conversa.
4. Atribuir `execution_level` e `execution_rationale` conforme o [formato](../tasks/formato.md). Preferir simplificar contratos ou decompor trabalho a transferir ambiguidade para um agente fraco. Mais texto não substitui decisão de produto.
5. Cada tarefa entrega um pacote mínimo: objetivo e exclusões, contexto de entrada, regras/IDs de aceite, dependências integradas, escopo, casos de teste necessários e evidências esperadas. Descrever resultados, sem prescrever cada linha de código.
6. Critérios devem explicitar estado inicial, ação, resultado e rejeições relevantes. Informar impacto sobre dados, compatibilidade e concorrência quando pertinentes. Definir gates mensuráveis e justificados; não inventar percentuais universais de cobertura.
7. Conferir grafo, prontidão das specs, conflitos de escopo e adequação do nível. Registrar bloqueios reais; não criar tarefas executáveis com dúvidas de comportamento pendentes.

## Saída e limites

Entregar specs/tarefas, justificativa de capacidade, sequência de dependências e dúvidas restantes. Atualizar índices e decisões sem duplicar fontes. Mudanças em código/ferramentas exigem a etapa de implementação dentro do escopo autorizado. Avaliações de código feitas durante planejamento seguem [review](review.md); validação documental não exige carregar todo esse fluxo.

## Tarefas humanas

Verificar `execution_level` antes de executar. Se for `human`, ou existir pré-requisito humano incompleto, aplicar a [reserva do AGENTS.md](../../AGENTS.md#execução-exclusiva-por-humano): informar a intervenção necessária e recusar execução dessa tarefa. Explicação e inspeção de evidências em leitura são permitidas; execução parcial, delegação e reclassificação para contornar o bloqueio não são.
