---
id: "TASK-010"
status: "in_review"
execution_level: "standard"
execution_rationale: "Restringe catálogo gerado ao proprietário e oferece criação componível em transação."
specs: ["SPEC-006"]
depends_on: ["TASK-016"]
provides: ["user-label-catalog"]
consumes: ["default-user"]
write_scope: ["lib/planner/labels.ex", "lib/planner/labels/", "priv/repo/migrations/", "test/planner/labels_test.exs", "test/support/fixtures/labels_fixtures.ex"]
blockers: []
---

# 010 — Gerar o catálogo de labels do usuário padrão

## Entrada e limite

[SPEC-006](../specs/006-labels.md) RN01 e RN03; consumir default-user. Referências Phoenix e Ecto.

## Scaffold

```sh
mix phx.gen.context Labels Label labels name:string user_id:references:users --no-scope
```

Consultar `mix help` antes de executar. O comando pertence à implementação desta tarefa; não foi executado no planejamento.

## Ajustes desta entrega

Manter schema, migration, criação/consulta e fixtures com proprietário explícito gerados. Ajustar trim e validação de nome. Retirar update/delete não previstos; não criar interface CRUD de labels. Oferecer operação componível em transação externa, sem commit independente.

Na migration gerada, exigir proprietário e texto obrigatório não nulos; adaptar as APIs/fixtures para receber o usuário padrão e atribuir user_id no servidor, fora do cast de attrs.

## Aceite e teste de intenção

1. Nome vazio falha; listar/buscar retorna só labels próprias, sem aceitar proprietário vindo de attrs.
2. Reverter transação externa remove nova label e preserva anteriores.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Implementador `/root/implement_task001`, em 24/09/2026, base `f9bc6f2` de `feat/mvp`; dependências aprovadas e integradas. Scaffold exato executado após consultar a ajuda Mix. Schema e migration adaptados com nome/proprietário obrigatórios, índice de proprietário e chave estrangeira para users.

Contrato para consumidoras:

- `Planner.Labels.list_labels(user)` retorna apenas labels desse usuário, ordenadas por ID.
- `Planner.Labels.get_label!(user, id)` retorna uma label própria; ID inexistente ou alheio lança `Ecto.NoResultsError`.
- `Planner.Labels.create_label(user, attrs)` retorna `{:ok, label}` ou `{:error, changeset}`; atribui owner pelo usuário resolvido no servidor, ignora user_id de attrs e participa da transação externa sem abrir commit independente. A consumidora deve reverter a operação composta quando qualquer etapa falhar.
- `Planner.LabelsFixtures.label_fixture(user, attrs)` exige proprietário explícito e é independente de seed global.

| Aceite | Evidência |
| --- | --- |
| 1 — nome, catálogo próprio e owner seguro | Testes cobrem trim, nomes nulos/vazios/espaços inclusive Unicode, identidade distinta para nomes iguais, user_id forjado em mapas de chaves atom/string, consulta própria, rejeição de ID alheio/inexistente, owner ausente e owner inexistente com erro de FK. Fixture preserva nome em inglês sem tradução. |
| 2 — rollback externo | Teste cria label anterior, insere nova em transação externa, confirma visibilidade interna e força rollback. Apenas a anterior permanece com a mesma struct. |

TDD inicial: cinco falhas por APIs com proprietário ainda inexistentes no scaffold. Após ajustes, seis testes específicos aprovados; acrescentado cenário de FK inexistente. Gates finais: `mix precommit` e `mix ci`, 39 testes aprovados, Credo estrito sem achados, cobertura total 82,65%, limiar 70% preservado. Labels 75%, Label 100%, LabelsFixtures 66,67%; aridades com argumentos padrão não exercitadas explicam os caminhos restantes, enquanto criação explícita, rejeições e consultas possuem testes. `git diff --check` passou.

Autoavaliação pelo fluxo de review: sem achados bloqueantes; nenhum update/delete, CRUD web ou vínculo tarefa-label adicionado. Não equivale a aprovação independente. Limitação: rollback foi comprovado com transação externa do Repo; integração com cadastro de tarefas e vínculos pertence às consumidoras futuras. Nenhum staging/commit realizado; documentos preexistentes preservados.

Status `in_review`; revisão independente e integração pendentes. Não liberar consumidoras antes desses passos.

### Revisão independente — 24/09/2026

Revisor `/root/review_task001`, independente do implementador. Conclusão **approved**, sem achados bloqueantes. Alvo: contexto/schema Labels, migration de labels, testes/fixture e registro desta tarefa no diff local sobre `f9bc6f2d185dfcf06fa773845ac70fa5997572eb`. Documentos preexistentes de outras tarefas/bloqueios fora do alvo.

Aceites atendidos: nome passa por trim e validação obrigatória; proprietário vem da struct User do servidor e fica fora do cast, inclusive diante de atributos forjados com chaves string/atom. Migration exige nome e proprietário não nulos e mantém FK. Listagem e busca filtram pelo proprietário; busca rejeita IDs alheios/inexistentes. Nomes iguais mantêm identidades distintas. Transação externa revertida elimina a label nova e preserva integralmente a anterior. API não adiciona update/delete nem interface de contas ou labels.

Validação independente: `rtk mix ci` reproduzido com **39 testes aprovados**, compilação/formato/Credo estrito sem falhas, cobertura total **82,65%**, Labels **75%**, Label **100%**, LabelsFixtures **66,67%**, limiar 70% intacto. Ajuda do alias já consultada nesta revisão contínua. `rtk git diff --check` aprovado. Precommit é evidência relatada do implementador, sem repetição mutante. Aridades padrão de criação/fixture não estão exercitadas; os caminhos explícitos relevantes e rejeições possuem testes. Não houve medição comparativa da base nem teste integrado do cadastro tarefa-label, que pertence às consumidoras. O rollback foi exercitado no Repo; estas consumidoras ainda devem reverter o conjunto ao receber erro. Aprovação técnica não comprova integração. Por orientação atual do usuário, encerrar a execução após a conclusão desta tarefa, sem iniciar outra.
