---
id: "TASK-007"
status: "planned"
execution_level: "standard"
execution_rationale: "Compõe conclusão idempotente e compactação de ordem na fronteira transacional existente."
specs: ["SPEC-002", "SPEC-003"]
depends_on: ["TASK-024"]
provides: ["complete-task"]
consumes: ["planning-snapshot", "daily-quota-transaction", "select-today", "return-to-backlog"]
write_scope: ["lib/planner/tasks.ex", "test/planner/tasks_test.exs"]
blockers: []
---

# 007 — Concluir uma tarefa preservando o consumo diário

## Entrada e limite

[SPEC-003](../specs/003-dia-e-historico.md) RN04/RN05; consumir fronteira transacional, select-today e return-to-backlog. Referência Ecto.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Implementar conclusão corrente com data corrente persistida, retirada da pendência e compactação da ordem, sem restituir cota. Repetir preserva a data original. Não criar consulta histórica ou interface nesta tarefa.

## Aceite e teste de intenção

1. CA-003-03/05: conclusão repetida/concorrente grava uma vez e não libera escolha.
2. Conclusão contra devolução produz um vencedor consistente; backlog/retry/alheia são rejeitados.
3. CA-002-02 / PRD CA03: pelas APIs públicas, selecionar três tarefas, concluir uma e tentar selecionar uma quarta. Rejeitar a nova seleção, manter as três escolhas consumidas e as duas pendências restantes. Usar a operação real de conclusão, sem substituir essa etapa por fixture persistida.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit e CI com cobertura mínima de 70%, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
