---
name: coordinate-delivery
description: Conferir superficialmente conclusão, integração e liberação de dependências no Planner e registrar commit por tarefa; sem revisão independente automática ou autorização de publicação remota.
---

# Conferir conclusão e registrar entrega

Aplicar o [fluxo de coordenação](../../fluxos/coordenacao.md). Fazer apenas conferência operacional superficial do registro da tarefa, resumo do implementador, evidências relatadas de autoavaliação e gates e ausência de impedimentos. Não auditar código ou critérios, reproduzir testes nem spawnar revisores no fluxo padrão.

Os gates vigentes e a cobertura mínima do projeto permanecem responsabilidade do implementador. Evidência ausente ou falha conhecida impede conclusão; devolver a pendência ao implementador ou seguir [coordinate-blockers](../coordinate-blockers/SKILL.md). Não reduzir requisitos. Identificar resultados como relatados; gate local não comprova CI remoto.

Revisão independente só ocorre mediante solicitação explícita, conforme o [fluxo de review](../../fluxos/review.md). Se o usuário a reservou como condição de aceite, manter a entrega pendente até o resultado. Não registrar conferência operacional ou autoavaliação como aprovação independente, nem avançar seu marco histórico.

## Integrar e fazer commit

Conferir a presença da entrega na base usada pelas consumidoras. Se a integração alterar a implementação, devolver ao implementador para atualizar as validações afetadas antes de concluir.

Reservar ao coordenador staging e commit, sobretudo em diretório compartilhado. Conferir os arquivos staged e incluir somente a tarefa, testes e evidências; preservar alterações preexistentes ou de outro agente. Um commit de entrega por tarefa, com ID na mensagem. Preservar commits anteriores; registros posteriores usam commit documental identificado com a tarefa.

Registrar `done` após conferência operacional, gates relatados aprovados, commit bem-sucedido e integração verificada. Recalcular dependências e blockers para informar quais próximas tarefas ficaram elegíveis. Falha de commit ou integração mantém a entrega pendente. Commit de diagnóstico não conclui tarefa bloqueada. Push, merge remoto e publicação exigem autorização própria.

Entregar ID, SHA, evidências relatadas, conclusão operacional e próximas tarefas liberadas, sem alegar revisão independente ou verificações não realizadas.
