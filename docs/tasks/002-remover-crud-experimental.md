---
id: "TASK-002"
status: "done"
execution_level: "standard"
execution_rationale: "Remoção delimitada de código gerado e migration; estratégia decidida, sem migração de dados."
specs: []
depends_on: ["TASK-003", "TASK-036"]
provides: ["experimental-crud-removed"]
consumes: ["github-quality-gate", "baseline-test-coverage"]
write_scope: ["lib/planner/tasks.ex", "lib/planner/tasks/", "lib/planner_web/controllers/task*", "lib/planner_web/router.ex", "test/planner/tasks_test.exs", "test/planner_web/controllers/task_controller_test.exs", "test/support/fixtures/tasks_fixtures.ex", "priv/repo/migrations/20260904140316_create_tasks.exs", "priv/repo/seeds.exs", "README.md"]
blockers: []
---

# 002 — Remover a geração experimental de Task

## Objetivo e decisão

Remover integralmente a geração experimental de Task, inclusive a migration original do Ecto, conforme autorização do responsável em 23/09/2026. Não migrar dados experimentais nem criar migration compensatória. O responsável confirmou a base limpa na [TASK-012](012-reset-banco.md); não há novo reset pendente.

## Escopo e contrato

Remover contexto/schema, controller/templates, rota `/tasks`, testes e fixtures exclusivos do gerador, migration `20260904140316_create_tasks.exs` e referências em seeds/imports/links. Conferir referências antes de apagar; preservar Phoenix, Repo, Gettext, Compose e página inicial. Não executar reset, remover volume nem implementar substituto.

`experimental-crud-removed`: código e migration experimentais ausentes, base apta a inicialização nova. Atualizar no README apenas descrições/instruções afetadas. Referências técnicas: Phoenix, Ecto e testes.

## Aceite

1. Teste de intenção comprova ausência das rotas experimentais e presença da página inicial.
2. Não restam dependências dos módulos/fixtures removidos; a migration original não existe.
3. Preparação de banco isolado vazio e precommit passam; não exigir upgrade do banco experimental antigo.
4. Nenhum reset do banco do responsável foi executado e nenhum modelo substituto foi criado.

## Impedimento de aceite resolvido

O [BLOCK-001](../blocks/001-cobertura-apos-remocao-crud.md) impediu a aprovação do gate. A [TASK-036](036-cobertura-base.md) corrigiu a cobertura e foi integrada antes do aceite desta entrega, conforme a revisão independente abaixo. A dependência registra essa condição de aceite, sem exigir refazer a remoção.

## Evidência e autoavaliação original — 23/09/2026

- Estado na autoavaliação original: bloqueado pelo gate de cobertura; revisão independente pendente. Autoavaliação do implementador `/root/implement_task_002` (gpt-6-sol, nível `standard`) concluída em 23/09/2026; não constitui aprovação independente.
- Alvo/base: commit `refactor: remove experimental task CRUD` sobre `1ae3ac8` (`feat/mvp`), que contém este registro. Entrega registrada na branch de trabalho; integração aprovada e liberação das consumidoras pendentes da revisão independente.
- Critério 1: teste de intenção escrito antes da remoção em `test/planner_web/controllers/task_controller_test.exs`. Execução inicial de `POSTGRES_TEST_DB=planner_task002_20260923 mix test test/planner_web/controllers/task_controller_test.exs`: 1/2 passou; falha esperada porque `GET /tasks` ainda resolvia para `PlannerWeb.TaskController`. Após a remoção, o mesmo comando passou 2/2: os oito métodos/caminhos do CRUD não resolvem e a página inicial responde HTTP 200.
- Critério 2: inspeção de `rg -n 'Planner\.Tasks|PlannerWeb\.TaskController|TasksFixtures|TaskHTML|/tasks|create_tasks' lib test priv config README.md --glob '!*.po' --glob '!*.pot'` encontrou `/tasks` somente no teste de intenção (e um link documental para tarefas); `rg --files priv/repo/migrations lib/planner lib/planner_web/controllers test | rg '(tasks|task_|create_tasks)'` encontrou somente o teste de intenção. Contexto, schema, controller, templates, fixture, testes gerados e migration original foram removidos. `priv/repo/seeds.exs` não referenciava o CRUD.
- Critério 3: `MIX_ENV=test POSTGRES_TEST_DB=planner_task002_fresh_20260923 mix ecto.setup` criou uma base nova e informou `Migrations already up`; `POSTGRES_TEST_DB=planner_task002_fresh_20260923 mix precommit` passou (7 testes, nenhuma falha). Não foi testado upgrade da base experimental antiga, fora do contrato.
- Critério 4: não foram executados `mix ecto.reset`, `ecto.drop`, remoção de volume ou a TASK-012 humana; a única base criada foi `planner_task002_fresh_20260923` para validação, além da base isolada do teste inicial. O diff não adiciona modelo substituto.
- Cobertura e gate adicional: `POSTGRES_TEST_DB=planner_task002_fresh_20260923 mix ci` passou compilação, formatação, Credo estrito (69 checks, nenhum problema) e 7 testes, mas retornou erro pelo limiar de cobertura: total 35,18% contra 70% em `mix.exs`. O mínimo obrigatório confirmado é 70%; a lacuna está nos testes, não na configuração do gate. `mix.exs` pertence à TASK-003 humana e está fora do escopo desta tarefa. Cobertura de linhas não demonstra os caminhos removidos; o teste de intenção e a inspeção do diff são a evidência principal.
- Autoavaliação pelo [fluxo de review](../fluxos/review.md): critérios 1 a 4 atendidos, `git diff --check` sem problemas, nenhuma dependência residual ou alteração fora do escopo detectada. Achado para o revisor: lacuna de cobertura registrada no BLOCK-001; aprovação independente e integração permanecem pendentes. Não considerar `mix ci` aprovado.

### Revisão independente e integração — 23/09/2026

Revisor: coordenador `/root`, independente da implementação original. Resultado: `approved`. Alvo: remoção `f757265` contra `1ae3ac8`, conferida na base integrada `952d05a`, que incorpora os testes da TASK-036 (`8c6d655`). Nenhum achado bloqueante no diff; alterações de planejamento preexistentes foram preservadas fora deste commit de aceite.

Critérios 1 e 2: teste de intenção cobre os oito métodos/caminhos removidos e GET `/`; inspeção confirmou ausência do contexto, schema, controller/templates, fixtures e migration experimental, sem referências residuais em produção ou seeds. Critério 3 reproduzido: `MIX_ENV=test POSTGRES_TEST_DB=planner_task002_accept_20260923 mix ecto.setup` criou base nova e executou seeds, saída 0; `POSTGRES_TEST_DB=planner_task002_accept_20260923 mix precommit` passou com 21 testes. Gate da mesma árvore executável: `POSTGRES_TEST_DB=planner_coord_20260923 mix ci`, saída 0 e 75,38% de cobertura. Critério 4: nenhum modelo substituto no diff; esta revisão não executou reset. A ausência de reset na implementação original é evidência relatada pelo implementador, não deduzida do diff.

TASK-036 concluída e integrada; BLOCK-001 resolvido. Remoção original `f757265` confirmada na ancestralidade da base e aprovada sem reescrever seu commit. TASK-002 concluída; liberação da TASK-001 após o commit deste aceite.
