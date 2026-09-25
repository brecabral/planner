---
id: "TASK-005"
status: "done"
execution_level: "standard"
execution_rationale: "Adapta cadastro gerado para receber proprietário explícito e restringir campos de entrada."
specs: ["SPEC-002"]
depends_on: ["TASK-010"]
provides: ["task-scaffold"]
consumes: ["default-user", "experimental-crud-removed", "clean-database"]
write_scope: ["lib/planner/tasks.ex", "lib/planner/tasks/task.ex", "priv/repo/migrations/", "test/planner/tasks_test.exs", "test/support/fixtures/tasks_fixtures.ex"]
blockers: []
---

# 005 — Gerar tarefas com cadastro simples no backlog

## Entrada e limite

[SPEC-002](../specs/002-planejamento-diario.md) RN01/RN02/RN06; consumir default-user. Referências Phoenix e Ecto.

## Scaffold

```sh
mix phx.gen.context Tasks Task tasks title:string kind:enum:backlog:today:retry scheduled_for:date position:integer completed_on:date user_id:references:users --no-scope
```

Consultar `mix help` antes de executar. O comando pertence à implementação desta tarefa; não foi executado no planejamento.

## Ajustes desta entrega

Reusar contexto/schema/fixtures com proprietário explícito. Ajustar validate_required gerado: só título é obrigatório na entrada; datas/posição são opcionais no backlog. Inicializar kind=backlog no servidor; não permitir cast de proprietário, kind, datas ou posição vindos do usuário. Restringir CRUD público a cadastro/consulta/changeset, removendo edição/exclusão genéricas. Não implementar seleção ou conclusão aqui.

Na migration gerada, exigir proprietário e texto obrigatório não nulos; adaptar as APIs/fixtures para receber o usuário padrão e atribuir user_id no servidor, fora do cast de attrs.

## Aceite e teste de intenção

1. CA-002-01: cadastro apenas por título persiste backlog sem datas; inválido não persiste.
2. CA-002-08 parcial: cadastro/consulta não atravessa conta, mesmo com attrs forjados.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Implementador `/root/implement_task005`, em 25/09/2026, base `2620271b4627841ae382213bfee0c0ce78ff6c47` de `feat/mvp`, com dependências aprovadas e integradas. Scaffold exato executado após consultar a ajuda. Alvo: contexto/schema Tasks, migration `20260925115837_create_tasks`, testes/fixture e este registro. Nenhum staging ou commit realizado.

Contrato para consumidoras:

- `Planner.Tasks.create_task(user, attrs \\ %{})` retorna `{:ok, task}` ou `{:error, changeset}`. Apenas título é entrada; proprietário e backlog são atribuídos no servidor. Datas e posição permanecem nulas.
- `Planner.Tasks.change_task(user, attrs \\ %{})` constrói changeset de **cadastro novo**, sem persistir e sem receber tarefa existente. Exige usuário explícito; não oferece edição genérica.
- `Planner.Tasks.list_tasks(user)` lista tarefas próprias por `inserted_at` crescente e ID crescente. Nesta entrega todas as tarefas criadas são backlog; snapshots de coleções e transições pertencem às consumidoras futuras.
- `Planner.Tasks.get_task!(user, id)` retorna tarefa própria; IDs alheios e inexistentes lançam `Ecto.NoResultsError`.
- `Planner.TasksFixtures.task_fixture(user, attrs \\ %{})` exige proprietário explícito e dispensa seed global.

| Critério | Evidência |
| --- | --- |
| CA-002-01 | Testes verificam trim, backlog persistido sem datas/posição, títulos iguais com identidades distintas e rejeição sem persistência de título ausente, vazio, espaços inclusive Unicode e tipos não textuais. |
| CA-002-08 parcial | Testes verificam owner/estado/datas/posição forjados em chaves atom e string, listagem própria, busca de ID próprio e rejeição idêntica de ID alheio/inexistente. Cadastro rejeita proprietário ausente ou inexistente. |
| RN02 e limites | Teste força datas de criação distintas e iguais para validar ordem por criação/ID. Inspeção confirma ausência de update/delete e de seleção/conclusão. Changeset público serve apenas ao cadastro. |
| Persistência | Migration mantém FK/índice de proprietário e exige título e proprietário não nulos. Migration final reaplicada no banco de testes antes dos gates. |

TDD: `mix test test/planner/tasks_test.exs` inicialmente teve sete falhas por APIs/fixture do scaffold ainda sem proprietário explícito (incluindo changeset de cadastro ausente); após ajustes, sete testes passaram. Foram preservadas as intenções pertinentes dos testes gerados de cadastro, consulta e changeset; edição/exclusão foram removidas com suas APIs.

Gates: `mix precommit` e `mix ci` aprovados com **46 testes**, compilação sem warnings, formatação válida e Credo estrito sem achados. Cobertura total **83,48%**, com Tasks, Task e TasksFixtures em **100%**; limiar 70% preservado. A entrega anterior registrava 82,65%, sem nova medição isolada da base. `git diff --check` aprovado. A tentativa inicial de rollback da nova migration exclusivamente no ambiente test encontrou bloqueio de lock TCP do sandbox; repetição escalada concluiu e os gates aplicaram a migration final. Nenhum reset de base de desenvolvimento.

Autoavaliação pelo fluxo de review: critérios acima atendidos, sem achados bloqueantes identificados. Cobertura de linhas não comprova ramos além dos cenários descritos. Não foram implementados nem avaliados cota, transições, conclusão, snapshots ou UI, fora deste escopo. Revisão independente e integração ainda pendentes; não liberar consumidoras antes delas.

### Revisão independente — 25/09/2026

Revisor `/root/review_task005`, independente do implementador, aplicando `review-code-diff` e o fluxo de review. Resultado **changes_requested**. Base/HEAD `2620271b4627841ae382213bfee0c0ce78ff6c47`; alvo: alterações locais desta tarefa, contexto/schema Tasks, migration `20260925115837_create_tasks.exs`, testes e fixture, incluindo os cinco arquivos de código ainda não rastreados; staging vazio. Dependência TASK-010 concluída e integrada. Marco `docs/review.md` preservado: esta revisão não aprova um SHA futuro.

**Achado bloqueante (P2): título válido com mais de 255 caracteres provoca exceção.** Em `priv/repo/migrations/20260925115837_create_tasks.exs:6`, `:string` cria `varchar(255)`, mas RN01/CA-002-01 aceitam título textual não vazio sem esse limite. O changeset não impede a tentativa. Reproduzido com `Planner.Tasks.create_task(user, %{title: String.duplicate("a", 256)})`: `Postgrex.Error`, SQLSTATE `22001`, `value too long for type character varying(255)`. Assim, entrada válida pelo contrato não cadastra e rompe o retorno previsto da API. Adequar a persistência ao contrato sem inventar limite de produto (coluna `:text`, mantendo campo Ecto `:string`) e cobrir o título longo com teste de intenção; revalidar a migration efetiva no ambiente de testes e os gates.

Demais critérios inspecionados: cadastro aplica trim, inicializa backlog e mantém datas/posição nulas; owner e campos de estado ficam fora do cast; chaves atom/string forjadas são ignoradas. Consultas filtram proprietário e rejeitam ID alheio como inexistente, sem mutação; ordenação usa criação/ID. Migration exige título/proprietário e FK. Testes verificam rejeições sem persistência, identidade distinta, isolamento e ordenação. Não há edição/exclusão genérica nem transições antecipadas. O achado acima impede considerar CA-002-01 integralmente atendido.

Verificação independente: ajudas `mix help ci` e `mix help run` consultadas e aliases inspecionados. `rtk mix ci` aprovado: **46 testes**, compilação/formato/Credo estrito aprovados, cobertura total **83,48%**, Tasks/Task/TasksFixtures **100%**, limiar 70% preservado. `rtk git diff --check` aprovado. Reprodução adicional via `MIX_ENV=test mix run -e` com checkout/checkin de `Ecto.Adapters.SQL.Sandbox`, fixture isolada e rollback, sem reset ou dados de desenvolvimento; primeira tentativa bloqueada pelo lock TCP do sandbox, repetição escalada reproduziu a exceção. Precommit permanece evidência relatada, sem repetir alias mutante. Não houve medição isolada da base; cobertura de linhas não detectou o cenário de título longo. Não foram avaliadas consumidoras futuras, UI, cota ou transições. Nenhuma correção de código, staging ou commit efetuados pelo revisor.

### Correção após revisão — 25/09/2026

Implementador `/root/implement_task005`, mesma base `2620271b4627841ae382213bfee0c0ce78ff6c47`. Achado P2 corrigido na migration ainda não integrada: título usa coluna `:text`, mantendo campo Ecto `:string` conforme referência de persistência. Nenhum limite de produto acrescentado.

Teste de intenção adicionado antes da correção: título textual com 256 caracteres reproduziu `Postgrex.Error` 22001 (sete testes passaram e um falhou). Após reaplicar somente a migration nova no banco de testes, os oito testes específicos passaram e a leitura confirmou o título integral. Banco de desenvolvimento não foi alterado e não houve reset.

Revalidação: `mix precommit` e `mix ci` aprovados com **47 testes**, formatação/compilação/Credo estrito sem falhas, cobertura total **83,48%** e Tasks/Task/TasksFixtures **100%**, limiar 70% intacto. `git diff --check` aprovado. Autoavaliação considera o achado corrigido e CA-002-01 coberto também para título longo; essa avaliação não substitui nova revisão independente. Estado devolvido a `in_review`, sem staging/commit, aguardando reavaliação e integração.

### Reavaliação independente — 25/09/2026

Revisor `/root/review_task005`, independente do implementador. Decisão atual **approved**, substituindo a decisão anterior após correção do P2. Base `2620271b4627841ae382213bfee0c0ce78ff6c47`; mesmo alvo local e escopo da revisão inicial, agora com coluna `title` em `:text` e teste adicional. Schema preserva `:string`, sem limite de produto acrescentado. Contexto e fixture reinspecionados, sem mudanças de contrato. O teste cria título de 256 caracteres e confirma por consulta o conteúdo integral persistido, resolvendo o cenário que reproduzia SQLSTATE 22001. CA-002-01 e CA-002-08 parcial atendidos no escopo desta tarefa; nenhum achado bloqueante restante.

Gate independente repetido após consultar `mix help ci`: `rtk mix ci` aprovado com **47 testes**, compilação/formatação/Credo estrito sem falhas, cobertura total **83,48%** e Tasks/Task/TasksFixtures **100%**; limiar 70% preservado. Primeira tentativa impedida pelo lock TCP do sandbox; repetição escalada aprovada. `rtk git diff --check` aprovado. A execução confirma o cenário de título longo na base de testes efetiva; a reaplicação histórica da migration permanece evidência relatada do implementador. Precommit não repetido por ser mutante; base anterior não medida isoladamente. Mantêm-se os limites da revisão inicial sobre consumidoras futuras e cobertura de linhas. Nenhuma correção de código, staging ou commit pelo revisor. Aprovação técnica da árvore local não comprova integração; marco `docs/review.md` preservado para atualização pelo coordenador após integrar.

### Integração aceita — 25/09/2026

Coordenador `/root`: entrega aprovada por `/root/review_task005` e integrada em `feat/mvp`, commit `79a22bf045bdf89c8d767335a1c87f0554e0f4e3`. Conteúdo staged conferido; nenhum código mudou após o gate independente (47 testes, 83,48%). Contrato `task-scaffold` liberado para TASK-018. Registros anteriores de pendência são históricos.
