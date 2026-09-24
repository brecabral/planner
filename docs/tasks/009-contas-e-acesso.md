---
id: "TASK-009"
status: "in_review"
execution_level: "standard"
execution_rationale: "Gera identidade mínima e preparação idempotente do usuário padrão, sem autenticação."
specs: ["SPEC-005"]
depends_on: ["TASK-001", "TASK-012"]
provides: ["default-user"]
consumes: ["ptbr-interface", "clean-database"]
write_scope: ["lib/planner/accounts.ex", "lib/planner/accounts/", "priv/repo/migrations/", "priv/repo/seeds.exs", "test/planner/accounts_test.exs", "test/support/fixtures/accounts_fixtures.ex", "README.md"]
blockers: []
---

# 009 — Gerar e preparar o usuário padrão do MVP

## Objetivo e entrada

[SPEC-005](../specs/005-contas-e-acesso.md). Manter schema/migration gerados e reduzir Accounts à criação idempotente e consulta do usuário com identifier fixo default. Seeds preparam esse usuário; testes usam fixture isolada. Remover CRUD de edição/exclusão não necessário. Não executar phx.gen.auth, criar contas interativas, senha, tokens ou Accounts.Scope. Fornecer o usuário resolvido para os contextos; instruções de preparação ficam no README.

## Scaffold

```sh
mix phx.gen.context Accounts User users identifier:string:unique --no-scope
```

Consultar `mix help` antes de executar; adaptar o resultado conforme o contrato acima.

## Aceite

1. Executar seeds duas vezes mantém um único usuário default e seus dados.
2. Função de consulta fornece identidade persistida; fixtures não dependem do seed global.

## Evidência e revisão

Implementação por `/root/implement_task001` em 24/09/2026, base `9ab40c8` da branch `feat/mvp`. Dependências integradas e aceite humano da TASK-012 conferidos pelo coordenador. Scaffold exato executado após consulta à ajuda; schema e migration gerados preservados. CRUD público removido em favor de duas funções:

- `Planner.Accounts.ensure_default_user!/0`: insere identifier fixo `default` com conflito ignorado pelo índice único e retorna a identidade persistida, sem atualizar dados existentes.
- `Planner.Accounts.get_default_user!/0`: consulta a identidade persistida; lança `Ecto.NoResultsError` se a preparação ainda não ocorreu.

A fixture `Planner.AccountsFixtures.user_fixture/1` insere pelo schema/Repo com identifier único por padrão e aceita atributos para identidades de teste. Não depende dos seeds nem adiciona uma API de contas interativas.

| Critério | Evidência |
| --- | --- |
| 1 — seeds idempotentes | Testes executam o arquivo real de seeds duas vezes tanto sem default prévio como com default existente. Verificam quantidade, igualdade da struct persistida, preservação de timestamp deliberadamente antigo e de outra identidade. |
| 2 — consulta e fixture | Testes verificam consulta da identidade persistida, ausência de criação implícita na consulta e fixtures distintas em sandbox sem seed global. Schema exige identifier e retorna erro de unicidade; índice único preservado na migration. |

TDD: primeira execução teve quatro falhas por APIs ausentes e um teste aprovado do schema gerado; após implementação, testes específicos passaram. Acrescentado teste do seed sem usuário prévio. `mix precommit` final: 29 testes, zero falhas. `mix ci` final: 29 testes, zero falhas, Credo estrito sem achados, cobertura total 82,78% (limiar 70% intacto); Accounts, User e AccountsFixtures com 100%. Um achado inicial de alias no Credo foi corrigido antes dos gates finais. Ajuda Mix pertinente consultada; acesso ao Docker autorizado para os testes. Instruções operacionais adicionadas apenas ao README.

Autoavaliação pelo fluxo de review: diff local limitado ao contrato, sem achados bloqueantes; não constitui aprovação independente. Não houve autenticação, rotas, painel ou alteração de tarefas/labels. Preservação de planejamento futuro decorre de não haver update/delete no preparo; entidades de planejamento ainda não existem para teste de integração. Não foi simulado conflito concorrente entre conexões; idempotência sequencial e índice único foram exercitados, e a inserção usa a resolução de conflito do PostgreSQL.

Status `in_review`; revisão independente e integração pendentes. Nenhum staging/commit pelo implementador. Alterações documentais preexistentes preservadas.

### Revisão independente — 24/09/2026

Revisor `/root/review_task001`, independente do implementador. Conclusão **approved**, sem achados bloqueantes. Alvo: alterações locais em Accounts, User, migration de users, seeds, testes/fixtures, README e registro desta tarefa contra `9ab40c8f82445c1a8980bc943a0fd4a132d3ccd6`. Documentação preexistente de outras tarefas e bloqueios excluída do alvo.

Os dois aceites estão atendidos: o seed real é executado repetidamente com e sem identidade prévia; a resolução retorna o registro persistido, preservando ID, timestamps e outra identidade. A consulta não cria registros implicitamente e as fixtures produzem usuários independentes no sandbox. Índice único e `on_conflict: :nothing` sustentam a criação idempotente sem update/delete. API pública do contexto restrita às duas funções previstas; nenhuma infraestrutura de autenticação acrescentada. Schema e migration seguem o scaffold contratado; instruções operacionais ficam no README.

Validação independente: `rtk mix ci` aprovado com **29 testes**, compilação/formato/Credo estrito sem falhas, cobertura **82,78%**, Accounts/User/AccountsFixtures com **100%** e limiar de 70% preservado. Ajuda do alias já consultada nesta revisão contínua. `rtk git diff --check` aprovado. Precommit é evidência relatada pelo implementador, sem repetição mutante. Não foi medida a cobertura da base nesta revisão nem simulado conflito simultâneo entre conexões; os testes comprovam repetição sequencial e unicidade. Dados de planejamento e integração com painel pertencem às consumidoras e ainda não existem para exercício integrado. Aprovação técnica não comprova integração nem libera consumidoras por si só.
