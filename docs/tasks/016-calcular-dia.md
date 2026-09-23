---
id: "TASK-016"
status: "planned"
execution_level: "standard"
execution_rationale: "Fornece Date.utc_today() com data controlável nos testes, sem estado global."
specs: ["SPEC-003"]
depends_on: ["TASK-009"]
provides: ["current-day"]
consumes: ["default-user"]
write_scope: ["lib/planner/day.ex", "test/planner/day_test.exs"]
blockers: []
---

# 016 — Fornecer a data corrente do planejamento

## Objetivo e entrada

[SPEC-003](../specs/003-dia-e-historico.md) RN01. Entregar pequena função que use Date.utc_today() por padrão e permita data controlada nos testes, sem relógio global mutável. O contexto captura uma data por consulta/comando. Não converter fuso nem armazenar horário.

## Aceite

1. Resultado é Date; teste controlado troca o dia sem esperar a hora real.
2. Duas execuções de teste não contaminam a data uma da outra.

## Evidência e revisão

Pendentes. Registrar teste de intenção, precommit e CI com cobertura mínima de 70%, revisor independente, alvo/base, critérios, achados e integração.
