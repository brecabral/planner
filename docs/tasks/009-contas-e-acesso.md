---
id: "TASK-009"
status: "planned"
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

Pendentes. Registrar teste de intenção, precommit e CI com cobertura mínima de 70%, revisor independente, alvo/base, critérios, achados e integração.
