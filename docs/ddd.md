# Linguagem de domínio e fronteiras

## Conceitos

| Termo | Significado |
| --- | --- |
| Usuário | Titular de conta, tarefas, labels, fuso e planejamento privados. |
| Tarefa | Ação com título obrigatório e zero ou várias labels do proprietário. |
| Backlog | Tarefas disponíveis, cadastradas ou retiradas manualmente de hoje. |
| Hoje (`today`) | Tarefas selecionadas para a data corrente do usuário, ordenadas por prioridade. |
| Retry | Tarefas que permaneceram em hoje sem conclusão na virada do dia; podem ser selecionadas novamente. |
| Escolha | Consumo de uma das três vagas diárias ao selecionar uma tarefa. Retirada manual restitui; conclusão mantém o consumo. |
| Prioridade | Posição relativa entre as pendências de hoje. |
| Conclusão | Registro persistente da execução da tarefa, com a data local original. |
| Histórico | Coleção de tarefas concluídas do usuário. |
| Label | Classificação reutilizável do catálogo privado do usuário; não representa uma entidade de projeto. |
| Dia do usuário | Data calculada no servidor a partir do instante atual e do fuso da conta. |

`kind` expressa a classificação backlog/today/retry solicitada pelo produto. Conclusão e data de escolha precisam ser representadas sem tornar tarefa concluída também pendente; o schema definitivo deve preservar essa distinção. Não transportar automaticamente os campos do experimento.

## Fronteiras

- Contas: identidade, sessão, configurações e escopo autenticado.
- Planejamento: tarefas, escolhas diárias, ordem, transições e histórico.
- Labels: catálogo privado; planejamento possui os vínculos com tarefas e compõe o cadastro atômico.
- Interface: apresenta dados autorizados e traduz eventos em comandos; não decide proprietário, cota ou dia.

## Nomes

Aplicação `:planner`; namespaces `Planner` e `PlannerWeb`; persistência `Planner.Repo`. Contextos previstos: `Planner.Accounts`, `Planner.Tasks` e `Planner.Labels`. Módulos em PascalCase; campos, funções e arquivos em snake_case. Operações públicas expressam intenção e recebem escopo autenticado. Detalhes físicos de tabelas e assinaturas ficam na entrega produtora, sem criar sinônimos para os conceitos acima.
