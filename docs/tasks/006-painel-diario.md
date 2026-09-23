---
id: "TASK-006"
status: "planned"
execution_level: "standard"
execution_rationale: "Integra LiveViews geradas a APIs existentes e remove superfícies CRUD fora do escopo."
specs: ["SPEC-001", "SPEC-002", "SPEC-004", "SPEC-005"]
depends_on: ["TASK-025"]
provides: ["task-live-scaffold"]
consumes: ["task-scaffold", "default-user", "ptbr-interface"]
write_scope: ["lib/planner_web/live/task_live/", "lib/planner_web/router.ex", "lib/planner_web/controllers/page*", "priv/gettext/", "test/planner_web/live/task_live_test.exs"]
blockers: []
---

# 006 — Gerar o painel e cadastro simples do MVP

## Objetivo e entrada

[SPEC-004](../specs/004-experiencia-e-acesso.md) e [SPEC-005](../specs/005-contas-e-acesso.md). Reusar Index/Form gerados sobre task-scaffold existente; resolver default-user no servidor ao abrir a página e passá-lo às APIs. Sem login, session guard ou seletor de conta. Remover Show/edição/exclusão, ajustar chamadas/testes e exibir mensagens em pt-BR via Gettext. Não manter subscribe/broadcast que sincronize abas automaticamente.

## Scaffold

```sh
mix phx.gen.live Tasks Task tasks title:string --no-context --no-scope
```

Consultar `mix help` antes de executar; adaptar o resultado conforme o contrato acima.

## Aceite

1. Abrir painel sem login permite cadastrar título no backlog do usuário padrão.
2. Recarga mantém os dados; erro de título aparece em pt-BR; params não trocam proprietário.

## Evidência e revisão

Pendentes. Registrar teste de intenção, precommit e CI com cobertura mínima de 70%, revisor independente, alvo/base, critérios, achados e integração.
