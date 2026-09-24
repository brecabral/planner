---
id: "TASK-016"
status: "in_review"
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

Implementador `/root/implement_task001`, em 24/09/2026, base `e752019` de `feat/mvp`; dependência TASK-009 aprovada e integrada. Implementação restrita a `lib/planner/day.ex` e `test/planner/day_test.exs`.

Contrato fornecido: `Planner.Day.current/0` retorna `Date.utc_today()`; `current/1` aceita uma struct `Date` fornecida pelo chamador servidor/teste. A docstring exige capturar uma vez por consulta/comando e reutilizar o valor durante a operação, sem aceitar data do navegador como autoridade. Não há configuração global, processo de relógio, fuso ou persistência de horário.

| Critério | Evidência |
| --- | --- |
| 1 — Date e dia controlado | Teste do padrão confirma struct Date e data UTC, tolerando uma eventual virada durante a própria asserção. Outro teste avança de 24 para 25/09/2026 por argumento, sem espera. |
| 2 — isolamento | Duas chamadas em processos independentes recebem datas distintas; chamadas posteriores preservam sua própria data e o padrão continua sendo UTC corrente. Nenhum estado global é alterado. |

TDD: três falhas esperadas antes da existência de Planner.Day; implementação passou os três casos. `mix precommit`: 32 testes aprovados. `mix ci`: 32 testes aprovados, Credo estrito sem achados, cobertura total 82,86%, Planner.Day 100%, limiar de 70% inalterado. Ajuda Mix de test/precommit/ci previamente consultada nesta execução. `git diff --check` sem erros.

Autoavaliação pelo fluxo de review: sem achados bloqueantes, contrato aderente a RN01; não equivale a aprovação independente. Limitação: capturar uma única data por operação é obrigação das futuras consumidoras, ainda não implementadas nesta tarefa. Revisão independente e integração pendentes. Nenhum staging/commit realizado; quatro documentos preexistentes preservados.

### Revisão independente — 24/09/2026

Revisor `/root/review_task001`, independente do implementador. Conclusão **approved**, sem achados bloqueantes. Alvo: `lib/planner/day.ex`, `test/planner/day_test.exs` e registro desta tarefa no estado local sobre `e752019f0f4577e69236a913e112e316acbda8d4`; documentação preexistente de outras tarefas/bloqueios fora do alvo.

Os dois aceites estão atendidos: `current/0` avalia `Date.utc_today()` na chamada e `current/1` permite controlar uma Date explicitamente, sem configuração, armazenamento ou processo global. Testes verificam o padrão UTC, mudança explícita de dia e chamadas independentes, com tolerância à virada durante a asserção. A implementação é proporcional ao contrato; documentação delimita o uso servidor/teste e a captura única por operação conforme RN01.

Validação independente: `rtk mix ci` aprovado, **32 testes**, compilação/formato/Credo estrito sem falhas, cobertura total **82,86%**, **Planner.Day 100%**, limiar 70% preservado; ajuda do alias já consultada nesta revisão contínua. `rtk git diff --check` aprovado. Precommit permanece evidência relatada do implementador, sem repetição mutante. Sem comparação de cobertura com a base nesta revisão. A captura única e a rejeição de autoridade do navegador devem ser verificadas novamente nas futuras consumidoras; não existe integração de contexto/painel neste alvo. Aprovação técnica não comprova integração nem libera consumidoras por si só.
