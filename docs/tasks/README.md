# Tarefas de implementação

Metadados YAML no início de cada `.md` são a fonte de status, dependências e recursos. Ler os cabeçalhos para selecionar trabalho; depois somente o corpo relevante. Convenções e elegibilidade: [formato do grafo](formato.md).

| Tarefa | Entrega |
| --- | --- |
| [001 — Troca de idiomas](001-troca-de-idiomas.md) | Seletor e integração Gettext; comportamento na SPEC-001. |
| [002 — Remover CRUD experimental](002-remover-crud-experimental.md) | Base sem o experimento de `phx.gen`. |
| [003 — Infraestrutura GitHub (humana)](003-infra-github.md) | Proteção da main e CI obrigatório. |

A dependência atual é TASK-003 (humana) → TASK-002 → TASK-001. Essa indicação resume os cabeçalhos e não altera os bloqueios declarados neles. As tarefas ainda são planejamento; criar documentação não executa funcionalidade.

Uma tarefa deve conter objetivo, contexto mínimo, escopo exclusivo, aceite, teste de intenção e evidência de entrega. Recursos comuns novos pertencem a uma tarefa produtora, consumida pelas demais. Planejamento assistido: [skill de decomposição](../skills/plan-task-graph/SKILL.md).

Cada cabeçalho indica o nível mínimo do implementador e sua justificativa. O planejador classifica; o implementador testa e encaminha a revisão; o revisor de ponta avalia o gate. Ver os [perfis no AGENTS.md](../../AGENTS.md#perfis-de-atuação).
