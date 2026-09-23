---
name: plan-task-graph
description: Decompor specs do Planner em tarefas Markdown com dependências YAML, produtor único por recurso e escopos definidos; usar para planejar ou revisar o grafo, não para executar funcionalidades.
---

# Planejar tarefas em grafo

1. Ler o [formato](../../tasks/formato.md), a spec solicitada e os cabeçalhos das tarefas potencialmente relacionadas. Abrir corpos completos somente quando houver dependência ou possível sobreposição.
2. Identificar entregas observáveis. Atribuir um responsável único por recurso novo; extrair tarefa comum quando duas entregas precisarem criá-lo. Compartilhar leitura de código existente não exige uma tarefa extra.
3. Escrever os arquivos em `docs/tasks/` com metadados do formato. Usar IDs estáveis, `depends_on` para arestas, `provides`/`consumes` para contratos e `write_scope` para a revisão de conflitos.
4. Planejar a partir de rascunhos é permitido, mas registrar bloqueios de decisões/specs. Não declarar uma tarefa executável sem satisfazer as condições do formato.
5. Conferir referências e produtores existentes, IDs/recursos únicos, ciclos, consumos alcançáveis e dependências canceladas/incompletas. Revisar sobreposição semântica e de arquivos das tarefas que poderiam rodar em paralelo.
6. Atribuir `execution_level` (`basic`, `standard`, `advanced` ou reserva `human`) e `execution_rationale` conforme o formato, considerando o ponto mais exigente. Extrair recursos comuns difíceis para produtoras de capacidade adequada. Fornecer contexto mínimo, critérios explícitos e testes de intenção; exigir revisão independente de ponta antes da conclusão. Atualizar o índice; não manter um segundo grafo em JSON ou diagrama editado separadamente.
7. Entregar sequência possível, bloqueios e contratos compartilhados. Não iniciar implementação ou delegar trabalho automaticamente.

## Decomposição e scaffold

Uma spec pode exigir muitas tarefas pequenas. Separar geração, adaptação de regras e integração de interface quando houver resultado verificável em cada etapa. Evitar tarefas que concentrem todo um domínio ou dependam de implementação futura para cumprir o próprio aceite.

Para geração Phoenix, consultar as referências locais e a ajuda do gerador pertinente antes de registrar o comando exato. Declarar o que o scaffold produz, os ajustes posteriores e o que fica fora da etapa; nomear a tarefa produtora para impedir regeneração por consumidoras. Não executar o gerador durante planejamento. Quando não houver gerador adequado, indicar o recurso existente a alterar.

Gates existentes fazem parte da viabilidade do incremento. Se a base já falha fora do escopo, usar [plan-unblocking](../plan-unblocking/SKILL.md) em vez de delegar a falha para todas as tarefas seguintes. Distinguir tarefa planejada de tarefa executável; informar a próxima elegível com base nas dependências reais.

Não criar tarefas vazias só para completar uma arquitetura imaginada. A decomposição deve reduzir ambiguidade e conflito para o escopo efetivamente solicitado.

Perfil ativo: [planejador](../../fluxos/planejamento.md). Não confundir nível de implementação com perfil de review.

Para tarefas `human`, escrever passos e aceite curtos para uma pessoa. Declarar dependências das consumidoras e informar que intervenção humana é necessária; nunca executar ou delegar a tarefa reservada. Consultar a regra de execução humana no formato.
