# Decisões de design e arquitetura

## D01 — Phoenix e PostgreSQL

Manter stack existente, `Planner.Repo` e monólito Phoenix. Sem serviços separados ou filas no MVP.

## D02 — Documentação por responsabilidade

PRD define escopo; specs agregam arquitetura e comportamento de cada capacidade; tarefas descrevem incrementos e evidências; DDD nomeia conceitos. Referências ensinam uso do framework. Operação fica somente no README.

## D03 — Remover o experimento antes de modelar

Remover geração experimental de Task, inclusive migration, e construir o modelo definido pelas specs. Não preservar compatibilidade com dados experimentais nem recriar o CRUD genérico.

## D04 — Painel LiveView

Reaproveitar Index/Form gerados. Resolver usuário padrão no servidor e chamar contextos com esse proprietário. Atualizar o resultado das ações próprias; não adicionar polling, timer ou sincronização automática entre abas. Recarga consulta o estado corrente.

## D06 — Persistência e concorrência

Tarefas e labels têm user_id do usuário padrão. APIs recebem esse usuário explicitamente; não há Accounts.Scope autenticado no MVP. Associações não cruzam proprietários.

Persistir cota por usuário/data separada das pendências. Seleção, devolução, ordem e conclusão usam a mesma fronteira transacional, inclusive quando a cota ainda não existe. Cadastro engloba tarefa, novas labels e vínculos muitos-para-muitos em uma transação.

## D08 — Usuário padrão e data

Contexto Accounts contém somente identidade persistente e resolução/criação idempotente do usuário padrão. Não gerar autenticação agora. Data de negócio é Date.utc_today(), com valor controlável nos testes; não persistir fuso nem horário de seleção/conclusão. Normalizar virada na leitura/comando, sem depender de processo web.

## D09 — Gettext fixo em pt-BR

Manter PlannerWeb.Gettext, mensagens-base em inglês e tradução pt_BR. Configurar locale fixo e HTML pt-BR; sem sessão de preferência ou seletor. Conteúdo do usuário permanece inalterado.

## D14 — Scaffolds e incrementos pequenos

Gerar contexto/schema e LiveViews, uma vez por recurso; usar --no-context na interface sobre domínio existente. Sem autenticação gerada, usar --no-scope e declarar user_id explicitamente nos recursos dependentes. Ajustar APIs para receber o usuário padrão do servidor e restringir campos permitidos. Comandos concretos ficam nas tarefas.
