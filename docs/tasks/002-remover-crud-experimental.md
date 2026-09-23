---
id: "TASK-002"
status: "planned"
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

Execução e revisão independente pendentes. Registrar teste de intenção, resultado de `mix precommit`, revisor e independência, alvo/base, critérios, achados e integração. Seguir o [formato](formato.md#registro-de-revisão).
