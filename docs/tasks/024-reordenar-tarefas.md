---
id: "TASK-024"
status: "planned"
execution_level: "standard"
execution_rationale: "Valida permutação completa e persiste posições atomicamente sob a trava existente."
specs: ["SPEC-002"]
depends_on: ["TASK-023"]
provides: ["reorder-today"]
consumes: ["planning-snapshot", "daily-quota-transaction"]
write_scope: ["lib/planner/tasks.ex", "test/planner/tasks_test.exs", "priv/repo/migrations/"]
blockers: []
---

# 024 — Reordenar somente as prioridades atuais

## Entrada e limite

[SPEC-002](../specs/002-planejamento-diario.md) RN04, CA-002-04/06; consumir planning-snapshot e fronteira transacional. Referência Ecto.

## Scaffold

```sh
mix ecto.gen.migration constrain_today_positions
```

Consultar `mix help ecto.gen.migration` antes de executar; preencher a migration de restrições sem regenerar contexto/schema.

## Ajustes desta entrega

Validar permutação exata das pendências próprias e gravar posições consecutivas atomicamente. Não alterar cota ou aceitar conjunto antigo. Adicionar constraints de posições necessárias sem invalidar atualização transacional.

## Aceite e teste de intenção

1. Permutação válida persiste; IDs duplicados, incompletos, alheios ou antigos rejeitam integralmente.
2. Reordenação concorrente com retorno/seleção deixa um único estado válido e cota inalterada.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit e CI com cobertura mínima de 70%, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
