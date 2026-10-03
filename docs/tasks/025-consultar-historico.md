---
id: "TASK-025"
status: "in_review"
execution_level: "standard"
execution_rationale: "Consulta conclusões do proprietário com preload e desempate estável."
specs: ["SPEC-003", "SPEC-006"]
depends_on: ["TASK-007"]
provides: ["history-query"]
consumes: ["complete-task", "task-label-storage"]
write_scope: ["lib/planner/tasks.ex", "test/planner/tasks_test.exs"]
blockers: []
---

# 025 — Consultar conclusões com labels e ordem estável

## Entrada e limite

[SPEC-003](../specs/003-dia-e-historico.md) RN06 e [SPEC-006](../specs/006-labels.md) RN05; consumir complete-task e task-label-storage. Referência Ecto.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Adicionar consulta histórica com proprietário explícito com preload de labels e ordenação por data/ID decrescentes. Não criar edição/reabertura/exclusão nem recalcular datas originais de conclusão.

## Aceite e teste de intenção

1. CA-003-06: recarga/reinício mantém registros, datas e desempate.
2. CA-006-05: labels preservadas; uma conta nunca recebe histórico de outra.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Implementador `/root/implement_task025`, em 03/10/2026. Base `dd10653`, com TASK-007 integrada em `1c4f886` e aceite operacional registrado na base. Alvo: diff local de `lib/planner/tasks.ex`, `test/planner/tasks_test.exs` e este registro. Sem staging/commit; encaminhado ao coordenador para conferência superficial e integração, conforme orientação explícita do usuário. Não houve revisão independente nem criação de revisor.

Contrato `history-query`: `Planner.Tasks.list_history(%Planner.Accounts.User{})` recebe proprietário resolvido no servidor e retorna lista de tarefas concluídas, com `labels` carregadas, ordenada por `completed_on` e `id` decrescentes. Lista vazia para conta sem conclusões. Consulta somente os dados persistidos, sem recalcular datas, alterar consumo ou oferecer mutações históricas.

| Aceite | Evidência |
| --- | --- |
| CA-003-06 | Testes consultam conclusões produzidas por `select_today`/`complete_task`; verificam ordem por data mesmo quando diverge da ordem de IDs e desempate por ID decrescente. Reinício real do Repo/pool troca processo e backend PostgreSQL, conserva a lista inteira, labels, datas e consumo anterior após consultar um novo dia. |
| CA-006-05 / isolamento | Duas labels mantêm IDs e vêm carregadas na consulta; tarefas sem labels retornam lista vazia. Backlog, retry e pendência corrente são excluídos. Consultas de duas contas recebem somente suas conclusões, e uma terceira recebe lista vazia. Recarga mantém o resultado. |

TDD: após corrigir a limpeza das associações da fixture de reinício e remover somente os dados criados pela tentativa inicial, a fase vermelha limpa apresentou **46 aprovados e 2 falhas**, ambas por ausência de `list_history/1`. Implementação mínima deixou **48 testes de Tasks aprovados**. Ajuda de `test`, `precommit`, `ci` e `run` consultada antes do uso. `rtk mix precommit` e `rtk mix ci`: **105 testes aprovados**, compilação/formatação/Credo estrito aprovados, **89,42% de cobertura total**, Tasks **98,31%**, mínimo de 70% preservado. `rtk git diff --check` aprovado.

Autoavaliação pelo fluxo de review: critérios atendidos, escopo preservado e nenhum bloqueador identificado. Teste reinicia Repo/pool, não o servidor PostgreSQL nem todo o sistema operacional; a consulta lê registros persistidos e não depende de cache. Nenhuma aprovação independente alegada. Integração e liberação de consumidoras dependem da conferência operacional do coordenador autorizada pelo usuário.
