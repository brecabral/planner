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

## Vocabulário do MVP de produção

A tabela anterior descreve o MVP local. No incremento de produção, `Planner.Accounts` passa a fornecer identidade autenticada; o usuário padrão torna-se somente um proprietário legado isolado. Tasks/Labels preservam suas fronteiras e recebem o usuário derivado do scope no servidor.

| Termo | Significado |
| --- | --- |
| Conta | Usuário identificado por e-mail confirmado por magic link, com dados privados. |
| Scope autenticado | Identidade resolvida por sessão Phoenix; fonte de autoridade para operações. |
| Exclusão de pendência | Remoção definitiva da tarefa e vínculos, preservando labels; em hoje restitui uma escolha corrente. |
| Envio de retry ao backlog | Transferência persistida sem consumo/restituição de escolha. |
| Tema | Paleta cadastrada com código estável; claro e escuro são gratuitos no MVP de produção. |
| Concessão de tema | Relação única usuário/tema que autoriza sua seleção; origem gratuita agora e futura compra após especificação. |
| Preferência de tema | Tema escolhido entre os concedidos; trocar preferência não compra nem remove propriedade. |
| Crédito | Unidade futura para compra de temas; regras de concessão e saldo ainda não definidas, fora do MVP de produção. |

`Planner.Themes` possui catálogo/concessões; Accounts mantém identidade e referência da preferência. Nenhum contexto financeiro é introduzido neste MVP.
