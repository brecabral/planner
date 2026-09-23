# Linguagem de domínio e fronteiras

| Termo | Significado no MVP |
| --- | --- |
| Usuário padrão | Identidade persistente usada por todas as visitas de teste, sem login. |
| Tarefa | Ação com título obrigatório e zero ou várias labels do proprietário. |
| Backlog | Tarefas disponíveis, cadastradas ou retiradas manualmente de hoje. |
| Hoje (`today`) | Pendências selecionadas para a data corrente, em ordem de prioridade. |
| Retry | Tarefas que ficaram em hoje sem conclusão na mudança de data; selecionáveis novamente. |
| Escolha | Consumo de uma das três vagas da data. Retirada manual restitui; conclusão mantém consumo. |
| Prioridade | Posição entre as pendências de hoje. |
| Conclusão | Registro persistente da execução com data, sem horário. |
| Histórico | Tarefas concluídas ordenadas por data e desempate estável. |
| Label | Classificação reutilizável, sem criar uma entidade de projeto. |
| Dia corrente | Date.utc_today() no servidor; sem preferência de fuso. |

## Fronteiras e nomes

`Planner.Accounts` fornece o usuário padrão. `Planner.Tasks` possui tarefas, cotas, transições, histórico e vínculos com labels. `Planner.Labels` fornece o catálogo; o cadastro composto é coordenado por Tasks. `PlannerWeb` apresenta dados e eventos, sem decidir proprietário ou cota. Persistência em `Planner.Repo`.

`kind` classifica pendências como backlog/today/retry; a data de conclusão distingue concluídas das pendências. Módulos em PascalCase; campos, arquivos e funções em snake_case. Operações públicas expressam intenção e recebem o usuário definido no servidor. IDs de sessão ou formulário não são autoridade para trocar esse usuário.
