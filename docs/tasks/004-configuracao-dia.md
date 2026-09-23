---
id: "TASK-004"
status: "planned"
execution_level: "standard"
execution_rationale: "Acrescenta campo e validação de fuso ao User gerado, sem definir a política temporal."
specs: ["SPEC-003"]
depends_on: ["TASK-015"]
provides: ["user-timezone-storage"]
consumes: ["authenticated-user-scope"]
write_scope: ["lib/planner/accounts/user.ex", "priv/repo/migrations/", "test/planner/accounts/user_test.exs"]
blockers: ["Resolver fuso inicial e vigência de alteração na SPEC-003."]
---

# 004 — Persistir e validar o fuso da conta

## Entrada e limite

[SPEC-003](../specs/003-dia-e-historico.md) RN01 e política de fuso inicial aprovada; consumir authenticated-user-scope. Referência Ecto.

## Scaffold

```sh
mix ecto.gen.migration add_timezone_to_users
```

Consultar `mix help` antes de executar. O comando pertence à implementação desta tarefa; não foi executado no planejamento.

## Ajustes desta entrega

Preencher migration e campo timezone no User já gerado; validar identificadores de fuso. Não gerar outra entidade User. Definir null/default conforme política aprovada, sem inferir fuso global. Expor validação, não um setter público que contorne a transação de planejamento.

## Aceite e teste de intenção

1. Fuso válido passa e inválido falha sem alteração; base nova respeita a política de conta ainda sem escolha de fuso.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
