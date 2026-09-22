# Linguagem de domínio e namespace

Referência: [PRD](prd.md). As convenções abaixo orientam a especificação com DDD. O CRUD atual é experimental e será removido; seus campos e módulos não constituem um modelo aprovado.

## Linguagem comum

| Termo | Significado | Representação |
| --- | --- | --- |
| Tarefa | Ação concreta que o usuário pretende executar | `Planner.Tasks.Task` |
| Backlog | Tarefas disponíveis para seleção, ainda não concluídas | Consulta no contexto `Planner.Tasks` |
| Hoje | Seleção pendente para a data corrente da instalação | Data `scheduled_for`, sujeita à decisão de virada do dia |
| Prioridade | Posição de execução entre as tarefas de hoje | Posição proposta, ainda não implementada |
| Concluir | Registrar que uma tarefa foi executada | Operação de domínio; data `completed_on` |
| Histórico | Consulta das tarefas concluídas | Consulta ordenada por `completed_on` |

A coluna de representação acima descreve o experimento atual ou propostas anteriores, não contratos do domínio futuro. Backlog, hoje e histórico são conceitos do produto; entidades, campos e transições serão definidos nas especificações antes de novo código. Não reaproveitar `kind`, `label` ou datas apenas porque o gerador os criou.

## Convenções

- Documentação `.md` em português; código, identificadores, comentários, docstrings e mensagens técnicas em inglês. Textos de interface via Gettext, com `msgid` em inglês e catálogos para `pt_BR` e `en`; comportamento na [SPEC-001](specs/001-idiomas.md) e uso técnico na [referência Gettext](referencias/gettext.md).
- Aplicação OTP: `:planner`. Domínio: `Planner`. Camada web: `PlannerWeb`.
- Preservar os namespaces raiz e `Planner.Repo`. `Planner.Tasks` e `Planner.Tasks.Task` pertencem ao experimento a remover; qualquer reintrodução desses nomes depende da especificação, sem criar sinônimos concorrentes para o mesmo conceito.
- Módulos em PascalCase, arquivos/funções/campos em snake_case e tabelas no plural.
- Uma definição de módulo por arquivo. LiveViews terminam em `Live`, como o proposto `PlannerWeb.PlannerLive` em `lib/planner_web/live/planner_live.ex`.
- Operações públicas devem expressar intenção. Exemplos propostos: `schedule_for_today`, `return_to_backlog`, `complete_task` e `reorder_today_tasks`; nomes e assinaturas finais serão definidos durante implementação.
- Regras e persistência ficam no contexto; a camada web traduz eventos em operações do domínio.
- DDD deve esclarecer linguagem, fronteiras e invariantes. Não exige novas camadas, microsserviços ou event sourcing.
- Gerar migrations usando `mix ecto.gen.migration nome_em_snake_case`.
- Specs em `docs/specs/` convertem requisitos em regras; tarefas usam `docs/tasks/NNN-descricao.md` com metadados YAML e referências às specs. Seguir o [formato do grafo](tasks/formato.md).
