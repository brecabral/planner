---
id: "TASK-007"
status: "done"
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

Implementador `/root/implement_task021`, em 01/10/2026. Base `76e315b17d34eb67b15303b4305ac9de9a379642` de `feat/mvp`, com TASK-024 integrada e conferida operacionalmente. Alvo: diff local de `lib/planner/tasks.ex`, `test/planner/tasks_test.exs` e este registro. Sem staging/commit. Revisão independente pendente ao final da rodada por orientação explícita do responsável; esta autoavaliação não equivale a aprovação independente.

Contrato `complete-task`:

- `Planner.Tasks.complete_task(user, id, date \\ nil)` recebe usuário resolvido no servidor, ID inteiro/string numérica e data opcional servidor/teste. Retorna `{:ok, task}`; ID alheio/inexistente/não convertível retorna `{:error, :not_found}` e backlog/retry/estado não corrente retorna `{:error, :invalid_state}`.
- Recarrega a tarefa após lock e normalização. Pendência corrente recebe `completed_on` igual à data capturada e posição nula; demais posições próprias correntes são compactadas na mesma transação. Não altera consumo. Repetir uma conclusão própria devolve exatamente a tarefa persistida, preservando a data original mesmo numa data posterior.
- Identidade, título, labels e data da seleção são preservados. Exceção durante persistência/compactação reverte conclusão e posições. Não foi criada consulta histórica nem interface.

| Aceite | Evidência |
| --- | --- |
| 1 — repetição/concorrência | Conclusão corrente persiste data, limpa posição e compacta restantes; repetição no mesmo dia e em data posterior mantém tarefa/data originais e consumo antigo. Duas conclusões em conexões PostgreSQL distintas aguardam lock real e retornam um único resultado idêntico, sem restituição. Caso unitário verifica data padrão e conjunto corrente vazio. |
| 2 — disputa/rejeições | Conclusão contra devolução concorrentes têm exatamente um sucesso e um `:invalid_state`. Se conclusão vence, tarefa concluída e consumo um; se devolução vence, backlog e consumo zero. Backlog, retry, seleção vencida, ID inválido e alheio são rejeitados. Constraint temporária falha durante compactação depois da conclusão; snapshot e data da tarefa voltam ao estado original. |
| 3 — CA-002-02 completo | Teste cria quatro tarefas e usa `select_today` três vezes; executa `complete_task` na central e tenta selecionar a quarta. Recebe `:quota_exhausted`, snapshot mostra três escolhas consumidas, duas pendências em posições 1–2 e quarta tarefa no backlog. A conclusão desta sequência é a API real, sem fixture substituindo o comportamento. |

TDD: seis falhas pela API ausente antes da implementação, inclusive nos workers de concorrência; depois **46 testes de Tasks aprovados**. Ajuda Mix já consultada nesta sessão. `rtk mix precommit` e `rtk mix ci`: **103 testes aprovados**, compilação/formatação/Credo estrito aprovados, **89,39% de cobertura total**, Tasks **98,29%**, UserTransaction **100%**, mínimo de 70% preservado. `rtk git diff --check` aprovado.

Autoavaliação pelo fluxo de review: aceites atendidos, sem bloqueadores identificados. Concorrência confirma backends distintos e espera por lock; aceita os dois vencedores serializáveis sem afirmar enumeração de todos os interleavings. Reinício/persistência da consulta histórica e UI não pertencem a esta entrega. Encaminhada ao coordenador para conferência operacional; revisão independente e integração pendentes neste registro.

### Conferência e integração — 01/10/2026

Coordenador `/root`: código/testes conferidos contra os três aceites, incluindo CA-002-02 por APIs reais, preservação de consumo/data, compactação, rejeições, rollback e disputa com devolução. Gates relatados: 103 testes, 89,39%; diff check aprovado. Integrada em `1c4f88659d47c32fae5f55375f446aaf25e8877d`. Conforme autorização explícita do usuário, conclusão operacional e liberação da TASK-025 por conferência do coordenador; revisão independente pendente para o final, sem aprovação presumida do revisor.
