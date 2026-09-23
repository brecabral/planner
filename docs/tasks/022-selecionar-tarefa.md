---
id: "TASK-022"
status: "planned"
execution_level: "standard"
execution_rationale: "Aplica seleção à cota transacional e verifica concorrência com o contrato existente de alteração de fuso."
specs: ["SPEC-002", "SPEC-003"]
depends_on: ["TASK-021"]
provides: ["select-today"]
consumes: ["planning-snapshot", "daily-quota-transaction", "timezone-settings"]
write_scope: ["lib/planner/tasks.ex", "test/planner/tasks_test.exs"]
blockers: []
---

# 022 — Selecionar tarefa e consumir uma escolha

## Entrada e limite

[SPEC-002](../specs/002-planejamento-diario.md) RN03/RN06/RN07 e [SPEC-003 CA-003-08](../specs/003-dia-e-historico.md#cenários-de-aceite); consumir planning-snapshot, daily-quota-transaction e timezone-settings. Referência Ecto.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Implementar apenas backlog/retry → hoje, debitando escolha e atribuindo última posição dentro da fronteira existente. Repetição em hoje não debita. Datas e proprietário vêm do servidor.

## Aceite e teste de intenção

1. Com três seleções pendentes confirmadas no dia, tentar selecionar uma quarta tarefa de backlog/retry é rejeitado sem alterar listas, posições ou cota. CA-002-03/08: disputar a última vaga com conexões distintas tem um vencedor; a cota de outro usuário permanece independente.
2. Falha de gravação reverte movimento e contador; repetição e ID alheio não consomem escolha.
3. CA-003-08: após aprovar a política da SPEC-003, executar alteração de fuso e seleção reais em conexões distintas, com instante controlado. Cobrir mudança de fuso antes da seleção e seleção antes da mudança, incluindo mudança de data local e retorno a uma data com consumo registrado. Usar barreiras de sincronização para controlar a ordem de aquisição da trava; verificar data efetiva, cota e destino das pendências conforme a política aprovada, sem reposição indevida.

O cenário integrado CA-002-02 (selecionar → concluir → rejeitar nova seleção) pertence à [TASK-007](007-historico-e-virada.md), quando a conclusão estiver disponível. Esta entrega não o comprova com fixture de tarefa já concluída.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
