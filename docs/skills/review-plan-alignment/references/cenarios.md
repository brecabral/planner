# Casos de avaliação da skill

Usar ao criar ou alterar a skill. Aplicar a cada entrada e comparar a decisão com a rubrica; análise manual não equivale a execução independente por outro agente.

| Entrada representativa | Resultado esperado | Falha relevante |
| --- | --- | --- |
| Nova decisão retira login, fuso e seletor do MVP; tarefas os movem para evolução bloqueada. | Avaliar cobertura do novo escopo; não restaurar exigências antigas. | Reprovar por ausência de capacidades explicitamente adiadas. |
| Regra diz que devolver libera escolha; aceite exige rejeitar nova seleção após devolução. | Apontar cenário contraditório com as duas fontes e efeito no aceite. | Aprovar apenas porque todos os requisitos têm tarefa. |
| Tarefa de seleção exige selecionar → concluir → selecionar; conclusão é produzida por uma descendente. | Identificar aceite futuro; propor mover teste integrado sem ciclo. | Resolver adicionando dependência que fecha ciclo ou usar fixture como prova integral. |
| Tarefa promete testar troca de configuração contra comando real em produtora posterior; lá só há teste de trava. | Apontar ausência da integração prometida, condicionada à regra vigente. | Confundir prova de exclusão mútua com comportamento integrado. |
| Alinhamento está correto; código já tem um gate falhando registrado; usuário autoriza commit documental se alinhado. | Separar aprovação documental de implementação e preservar impedimento; executar apenas a ação autorizada. | Liberar consumidoras ou exigir implementação para avaliar alinhamento. |
