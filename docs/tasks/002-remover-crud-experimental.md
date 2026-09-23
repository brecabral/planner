---
id: "TASK-002"
status: "in_review"
execution_level: "standard"
execution_rationale: "Remoção delimitada de código gerado e migration; estratégia decidida, sem migração de dados."
specs: []
depends_on: ["TASK-003"]
provides: ["experimental-crud-removed"]
consumes: ["github-quality-gate"]
write_scope: ["lib/planner/tasks.ex", "lib/planner/tasks/", "lib/planner_web/controllers/task*", "lib/planner_web/router.ex", "test/planner/tasks_test.exs", "test/planner_web/controllers/task_controller_test.exs", "test/support/fixtures/tasks_fixtures.ex", "priv/repo/migrations/20260904140316_create_tasks.exs", "priv/repo/seeds.exs", "README.md"]
blockers: []
---

# 002 — Remover a geração experimental de Task

## Objetivo e decisão

Remover integralmente a geração experimental de Task, inclusive a migration original do Ecto, conforme autorização do responsável em 23/09/2026. Não migrar dados experimentais nem criar migration compensatória. O responsável fará o reset após a remoção, na [TASK-012](012-reset-banco.md).

## Escopo e contrato

Remover contexto/schema, controller/templates, rota `/tasks`, testes e fixtures exclusivos do gerador, migration `20260904140316_create_tasks.exs` e referências em seeds/imports/links. Conferir referências antes de apagar; preservar Phoenix, Repo, Gettext, Compose e página inicial. Não executar reset, remover volume nem implementar substituto.

`experimental-crud-removed`: código e migration experimentais ausentes, base apta a inicialização nova. Atualizar no README apenas descrições/instruções afetadas. Referências técnicas: Phoenix, Ecto e testes.

## Aceite

1. Teste de intenção comprova ausência das rotas experimentais e presença da página inicial.
2. Não restam dependências dos módulos/fixtures removidos; a migration original não existe.
3. Preparação de banco isolado vazio e precommit passam; não exigir upgrade do banco experimental antigo.
4. Nenhum reset do banco do responsável foi executado e nenhum modelo substituto foi criado.

## Evidência e revisão

- Estado da revisão: pendente de revisão independente. Autoavaliação do implementador `/root/implement_task_002` (gpt-6-sol, nível `standard`) concluída em 23/09/2026; não constitui aprovação independente.
- Alvo/base: commit `refactor: remove experimental task CRUD` sobre `1ae3ac8` (`feat/mvp`), que contém este registro. Entrega registrada na branch de trabalho; integração aprovada e liberação das consumidoras pendentes da revisão independente.
- Critério 1: teste de intenção escrito antes da remoção em `test/planner_web/controllers/task_controller_test.exs`. Execução inicial de `POSTGRES_TEST_DB=planner_task002_20260923 mix test test/planner_web/controllers/task_controller_test.exs`: 1/2 passou; falha esperada porque `GET /tasks` ainda resolvia para `PlannerWeb.TaskController`. Após a remoção, o mesmo comando passou 2/2: os oito métodos/caminhos do CRUD não resolvem e a página inicial responde HTTP 200.
- Critério 2: inspeção de `rg -n 'Planner\.Tasks|PlannerWeb\.TaskController|TasksFixtures|TaskHTML|/tasks|create_tasks' lib test priv config README.md --glob '!*.po' --glob '!*.pot'` encontrou `/tasks` somente no teste de intenção (e um link documental para tarefas); `rg --files priv/repo/migrations lib/planner lib/planner_web/controllers test | rg '(tasks|task_|create_tasks)'` encontrou somente o teste de intenção. Contexto, schema, controller, templates, fixture, testes gerados e migration original foram removidos. `priv/repo/seeds.exs` não referenciava o CRUD.
- Critério 3: `MIX_ENV=test POSTGRES_TEST_DB=planner_task002_fresh_20260923 mix ecto.setup` criou uma base nova e informou `Migrations already up`; `POSTGRES_TEST_DB=planner_task002_fresh_20260923 mix precommit` passou (7 testes, nenhuma falha). Não foi testado upgrade da base experimental antiga, fora do contrato.
- Critério 4: não foram executados `mix ecto.reset`, `ecto.drop`, remoção de volume ou a TASK-012 humana; a única base criada foi `planner_task002_fresh_20260923` para validação, além da base isolada do teste inicial. O diff não adiciona modelo substituto.
- Cobertura e gate adicional: `POSTGRES_TEST_DB=planner_task002_fresh_20260923 mix ci` passou compilação, formatação, Credo estrito (69 checks, nenhum problema) e 7 testes, mas retornou erro pelo limiar de cobertura: total 35,18% contra 70% em `mix.exs`. A TASK-003 descreve a cobertura como informativa; a configuração atual é bloqueante. `mix.exs` pertence à TASK-003 humana e está fora do escopo desta tarefa. Cobertura de linhas não demonstra os caminhos removidos; o teste de intenção e a inspeção do diff são a evidência principal.
- Autoavaliação pelo [fluxo de review](../fluxos/review.md): critérios 1 a 4 atendidos, `git diff --check` sem problemas, nenhuma dependência residual ou alteração fora do escopo detectada. Achado para o revisor: descompasso do gate de cobertura acima; aprovação independente e integração permanecem pendentes. Não considerar `mix ci` aprovado.
