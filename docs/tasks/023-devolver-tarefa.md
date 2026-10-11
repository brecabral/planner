---
id: "TASK-023"
status: "done"
execution_level: "standard"
execution_rationale: "Compõe devolução idempotente, restituição e ordem na mesma fronteira transacional."
specs: ["SPEC-002", "SPEC-003"]
depends_on: ["TASK-022"]
provides: ["return-to-backlog"]
consumes: ["planning-snapshot", "daily-quota-transaction", "select-today"]
write_scope: ["lib/planner/tasks.ex", "test/planner/tasks_test.exs"]
blockers: []
---

# 023 — Devolver ao backlog e restituir uma escolha

## Entrada e limite

[SPEC-002](../specs/002-planejamento-diario.md) RN05/RN07; consumir select-today e fronteira transacional. Referência Ecto.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Implementar hoje → backlog manual, restituição única e compactação das posições. Não enviar retorno manual para retry. Repetição no backlog é sem efeito; seleção vencida não restitui cota do dia novo.

## Aceite e teste de intenção

1. CA-002-05/07: retorno libera uma escolha uma vez; repetição concorrente não libera duas.
2. Disputa retorno/seleção respeita limite; erro reverte estado, posições e contador.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Implementador `/root/implement_task021`, em 01/10/2026. Base `1cc2d584836befc7bb0b45ace9d428f67408e517` de `feat/mvp`, com TASK-022 integrada e aceite operacional excepcional do coordenador. Alvo: diff local de `lib/planner/tasks.ex`, `test/planner/tasks_test.exs` e este registro. Sem staging/commit. Revisão independente pendente para o final da rodada por orientação explícita do responsável; esta autoavaliação não representa aprovação independente.

Contrato `return-to-backlog`:

- `Planner.Tasks.return_to_backlog(user, id, date \\ nil)` recebe usuário resolvido no servidor, ID inteiro/string numérica e data opcional servidor/teste. Retorna `{:ok, task}`; ID inexistente/alheio/não convertível retorna `{:error, :not_found}`, enquanto concluída, retry ou estado não corrente retornam `{:error, :invalid_state}`. Erros de changeset são propagados e exceções de persistência revertem a transação.
- Após lock e normalização comuns, backlog pendente já existente retorna inalterado. Hoje/data corrente passa ao backlog, perde posição, preserva identidade/título/labels/data da última seleção e restitui exatamente uma escolha. As demais pendências correntes próprias recebem posições consecutivas preservando sua ordem relativa.
- Movimento, posições e contador são uma transação. Seleção vencida é revalidada como retry e rejeitada, sem restituição na nova data; pelo contrato comum, a rejeição também reverte a normalização, que será reaplicada no snapshot seguinte. Nenhum comando de conclusão ou reordenação foi antecipado.

| Aceite | Evidência |
| --- | --- |
| 1 — restituição única | Com três seleções, devolver a central reduz consumo para dois e compacta posições das restantes para 1–2, preservando título/ID/labels. Repetição mantém o mesmo retorno e consumo. Nova seleção dessa tarefa ocupa posição três e consome a terceira escolha. Duas devoluções simultâneas da mesma tarefa em conexões distintas retornam o mesmo backlog e deixam consumo zero, nunca negativo. |
| 2 — disputa e rollback | Devolução e seleção simultâneas partem de consumo três: seleção antes da devolução pode ser rejeitada, deixando consumo dois; depois da devolução pode suceder, deixando três. Ambas as ordens preservam limite e posições consecutivas. Constraint temporária faz a restituição falhar depois de movimento/compactação; snapshot completo permanece idêntico ao original. |
| Revalidação e isolamento | IDs alheios/inválidos, concluída e retry são rejeitados sem alterações indevidas. Comando de retorno como primeira operação de uma nova data rejeita tarefa vencida e não cria cota residual; snapshot posterior mostra retry, consumo novo zero e consumo antigo preservado. Caso de tarefa única verifica posição vazia e data padrão do servidor. |

TDD: seis falhas iniciais por API ausente (nos casos concorrentes os workers falharam antes de adquirir lock); após implementação, **32 testes de Tasks aprovados**. Acrescentado caso explícito de retorno vencido como primeira operação na nova data. Ajuda Mix já consultada nesta sessão. `rtk mix precommit` e `rtk mix ci`: **90 testes aprovados**, compilação/formatação/Credo estrito aprovados, **88,48% de cobertura total**, Tasks **97,75%**, UserTransaction **100%**, mínimo de 70% preservado. `rtk git diff --check` aprovado.

Autoavaliação pelo fluxo de review: aceites atendidos, sem achado bloqueante. Concorrência confirma espera real (`pg_blocking_pids`) e backends distintos; não enumera todos os interleavings, e o teste aceita ambos os resultados serializáveis da disputa retorno/seleção. A cobertura de Tasks inclui tratamento defensivo de erro de changeset não provocado; falha real de escrita e rollback integral são exercitados por constraint no sandbox. Evidências entregues ao coordenador para conferência operacional; revisão independente e integração pendentes neste registro.

### Conferência e integração — 01/10/2026

Coordenador `/root`: código/testes conferidos contra aceites de restituição única, compactação, concorrência, rollback e virada. Gates relatados: 90 testes, 88,48% de cobertura; diff check aprovado. Integrada em `f61e30d51399121d8a2947d4b291e507cd2ea9ab`. Conforme autorização explícita do usuário, conclusão operacional e liberação da TASK-024 por conferência do coordenador, mantendo revisão independente pendente para o final da rodada; não constitui aprovação do revisor.


### Revisão independente de prontidão — 05/10/2026

Revisor `/root`; alvo `ce0f72bb59eb27efa0a60e867f93242c2e805916`, base `aafed16d7b7a09000404e716cc98dcc43763510e`. Nenhum achado adicional neste escopo; o aceite global do MVP permanece com alterações solicitadas por R1 no cadastro. CI e precommit reproduzidos: 136 testes aprovados; cobertura total 92,16%. Evidências, reprodução, critérios e limites no [relatório de revisão](../review.md#revisão-de-prontidão-do-mvp--05102026). Registro operacional anterior preservado; esta revisão não presume validação humana ou CI remoto.
