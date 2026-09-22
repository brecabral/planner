---
id: "TASK-002"
status: planned
execution_level: advanced
execution_rationale: "Remoção transversal com migration aplicada e possível descarte de dados; exige definir e verificar estratégia de persistência."
specs: []
depends_on: ["TASK-003"]
provides: ["experimental-crud-removed"]
consumes: ["github-quality-gate"]
write_scope:
  - "lib/planner/tasks*"
  - "lib/planner_web/controllers/task*"
  - "lib/planner_web/router.ex"
  - "test/planner/tasks_test.exs"
  - "test/planner_web/controllers/task_controller_test.exs"
  - "test/support/fixtures/tasks_fixtures.ex"
  - "priv/repo/"
  - "README.md"
  - "docs/prd.md"
  - "docs/ddd.md"
  - "docs/design.md"
blockers:
  - "Definir estratégia para migration aplicada e dados existentes antes de qualquer descarte."
---

# 002 — Remover o CRUD experimental de tarefas

## Objetivo e referências

Retirar o CRUD criado como teste de `phx.gen`, pois seu modelo não representa os requisitos do Planner. Não implementar um substituto nesta tarefa: primeiro definir as especificações do domínio.

Consultar [design D03/D06](../design.md#d03--remover-o-experimento-antes-de-modelar), [DDD](../ddd.md#convenções) e PRD §8/§13. Esta é uma limpeza preparatória para RF01–RF07; não entrega esses requisitos. Aplicam-se também as verificações locais de CA11.

## Inventário inicial a conferir antes de editar

- `lib/planner/tasks.ex` e `lib/planner/tasks/task.ex`: contexto e schema experimentais.
- `lib/planner_web/controllers/task_controller.ex`, `task_html.ex` e `task_html/`: controller e templates do CRUD.
- `resources "/tasks", TaskController` no router e eventuais links para essas rotas.
- `test/planner/tasks_test.exs`, `test/planner_web/controllers/task_controller_test.exs` e `test/support/fixtures/tasks_fixtures.ex`: testes e fixtures exclusivos do experimento.
- `priv/repo/migrations/20260904140316_create_tasks.exs`, seeds e referências a `Planner.Tasks`, `Planner.Tasks.Task`, `TaskController` e `TasksFixtures`.

O inventário descreve a inspeção atual; pesquisar referências novamente para não apagar trabalho novo nem deixar dependências quebradas.

## Escopo e estratégia

1. Escrever primeiro um teste de intenção confirmando que a rota experimental deixou de ser exposta, usando a estrutura de rotas ou resposta HTTP sem depender de HTML bruto. Preservar a verificação de que a página inicial continua acessível.
2. Remover contexto/schema, controller, templates, rotas e os testes/fixtures específicos do gerador. Não remover testes de infraestrutura ou testes de uma futura especificação apenas por compartilharem o nome “task”.
3. Revisar seeds, links e imports; preservar Phoenix, `Planner.Repo`, configuração, Compose, Gettext e a página inicial.
4. Verificar se a migration já foi aplicada em ambientes compartilhados e se há dados a preservar. Não apagar silenciosamente tabela ou volume. Se já aplicada, preservar o histórico e definir uma migration de remoção com `mix ecto.gen.migration remove_experimental_tasks`; qualquer descarte depende de confirmar que os dados são descartáveis ou estão preservados. Se comprovadamente nunca aplicada e sem dados, documentar a possibilidade de retirar apenas a migration experimental. Não executar `ecto.reset` para contornar essa decisão.
5. Atualizar PRD/DDD/design para distinguir o que foi removido do que continua proposto; retirar links para arquivos excluídos e ajustar o estado atual no README.
6. Não criar novos campos, schemas, contextos ou CRUD. A modelagem definitiva é um trabalho posterior, condicionado às especificações.

## Critérios de aceite

1. `/tasks` e suas operações CRUD não constam das rotas disponíveis; não há links internos apontando para elas.
2. Não restam módulos, imports, fixtures ou testes dependentes do CRUD removido; menções históricas pertinentes na documentação podem permanecer.
3. A página inicial, configuração de banco, Gettext e comandos documentados continuam funcionando.
4. A estratégia para a tabela/migration está registrada e é consistente tanto para uma base nova quanto para uma base existente; nenhuma perda de dados ocorre sem a decisão necessária.
5. Nenhum modelo substituto foi implementado; documentos deixam explícita a sequência especificação → testes de intenção → implementação.
6. `mix precommit` passa. Verificar rotas e preparação de uma base isolada por tarefas/aliases Mix apropriados, consultando `mix help` antes do uso.

## Evidência

Preencher na execução: referências encontradas, decisão sobre dados/migrations, teste de intenção que falhou antes da mudança e resultado final dos aliases. Esta tarefa ainda não foi executada.

## Contrato da entrega

`experimental-crud-removed`: rotas, módulos e referências do experimento removidos, estratégia de persistência executada conforme decisão e verificações verdes. É manutenção preparatória, sem spec de novo comportamento do produto. A tarefa 001 consome essa base; não incluir tradução, seletor ou novo modelo de tarefas aqui.

## Revisão independente

Pendente. Na execução, registrar revisor de ponta, alvo/base, critérios verificados, evidências de testes/cobertura/evals aplicáveis, achados e decisão do gate conforme o [fluxo de review](../fluxos/review.md). A autoavaliação do implementador não substitui esta etapa. Integração ainda pendente.
