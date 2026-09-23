---
name: plan-unblocking
description: Converter um impedimento documentado em docs/blocks do Planner em decisão ou tarefa corretiva com critérios de retomada e dependências sem ciclos; não executar a correção.
---

# Planejar a resolução de impedimentos

Ler o relatório pertinente, a tarefa interrompida, as evidências e os cabeçalhos diretamente afetados. Seguir o [protocolo de bloqueios](../../blocks/README.md); a tarefa interrompida permanece parada durante este planejamento.

- Confirmar a causa com a evidência disponível, distinguindo falha do produto, lacuna de testes, configuração, dependência ausente e decisão pendente. Não repetir verificações já suficientes nem atribuir um gate vermelho à configuração sem evidência.
- Determinar se cabe corrigir no contrato atual ou criar um incremento próprio. Quando ultrapassar o escopo, criar tarefa delimitada com [plan-task-graph](../plan-task-graph/SKILL.md), incluindo base de entrada, arquivos, resultado verificável e exclusões. Se exigir pessoa ou decisão do usuário, registrar essa necessidade sem contorná-la.
- Preservar gates e limites vigentes. Cobertura insuficiente exige testes de comportamento com valor de regressão; não planejar reduzir o limiar, excluir módulos ou criar funcionalidades apenas para elevar a métrica. Consultar o valor vigente na política do projeto, sem duplicá-lo como regra universal da skill.
- Ordenar a correção antes das consumidoras atingidas. Quando código já presente aguarda um gate, separar presença na base de aceite: a correção pode referenciar esse código como entrada, sem depender da aprovação que ela própria deve viabilizar. Se o código ainda não está disponível, resolver primeiro sua base de trabalho; não presumir integração.
- Manter arestas somente em `depends_on`, recursos com produtor único e causas sem solução em `blockers`. Validar ciclos e consumos; não espalhar dependências diretas quando a cadeia já garante o bloqueio transitivo.
- Explicitar que a falha alvo é permitida como estado inicial da tarefa corretiva, mas não como resultado final. Outras falhas fora do contrato seguem o protocolo de interrupção.
- Atualizar o relatório com a decisão e a condição de retomada conforme a causa. Planejar uma correção de código não encerra o bloqueio: exigir correção validada e integrada. Quando a causa for uma decisão pendente ou execução humana, a evidência deve seguir o protocolo correspondente, sem inventar uma implementação necessária. O coordenador confere a resolução e retoma as revisões pendentes das entregas afetadas.

Entregar a tarefa corretiva ou decisão necessária, o impacto sobre a fila e a evidência que permitirá retomá-la. A distribuição e execução pertencem ao coordenador e ao implementador, quando autorizadas.
