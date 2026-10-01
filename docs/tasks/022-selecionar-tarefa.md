---
id: "TASK-022"
status: "in_review"
execution_level: "standard"
execution_rationale: "Aplica seleção e limite na fronteira transacional com revalidação da data corrente."
specs: ["SPEC-002", "SPEC-003"]
depends_on: ["TASK-021"]
provides: ["select-today"]
consumes: ["planning-snapshot", "daily-quota-transaction"]
write_scope: ["lib/planner/tasks.ex", "test/planner/tasks_test.exs"]
blockers: []
---

# 022 — Selecionar tarefa e consumir uma escolha

## Objetivo e entrada

[SPEC-002](../specs/002-planejamento-diario.md) RN03/RN06/RN07. Consumir planning-snapshot e daily-quota-transaction. Implementar backlog/retry → hoje com débito atômico e última posição. Repetição em hoje não debita. Data e proprietário vêm do servidor. CA-002-02 completo, com conclusão, pertence à TASK-007.

## Aceite

1. Três seleções pendentes impedem uma quarta; disputa pela última vaga com conexões distintas tem um vencedor.
2. Falha reverte movimento/contador; repetição não duplica consumo.
3. Mudança de data entre tela e comando normaliza pendências e usa cota corrente sem reutilizar indevidamente escolhas anteriores.

## Evidência e revisão

Implementador `/root/implement_task021`, em 01/10/2026. Base `f3900376746280d55a4cce6afe938301186139a5` de `feat/mvp`, com TASK-021 aprovada e integrada. Alvo: diff local de `lib/planner/tasks.ex`, `test/planner/tasks_test.exs` e este registro. Sem staging/commit. Revisão independente permanece pendente para o final da rodada, conforme orientação do responsável; autoavaliação não constitui aprovação independente.

Contrato `select-today`:

- `Planner.Tasks.select_today(user, id, date \\ nil)` aceita proprietário resolvido no servidor, ID inteiro ou string numérica e data opcional controlada pelo servidor/testes. Retorna `{:ok, task}`; rejeições de domínio são `{:error, :not_found}`, `{:error, :invalid_state}` ou `{:error, :quota_exhausted}`. IDs alheios/inexistentes e entradas não convertíveis para ID recebem `:not_found`.
- Dentro de `UserTransaction.run/3`, lê novamente a tarefa após lock/normalização. Pendência já em hoje/data corrente retorna sem débito, inclusive com cota esgotada. Concluídas/estados não selecionáveis são rejeitados. Backlog/retry consomem uma escolha e recebem a data capturada e posição seguinte à maior posição pendente corrente.
- Movimento e contador compartilham a transação; erro/exceção reverte ambos. Identidade, título e vínculos são preservados. O resultado é a tarefa; telas podem recuperar coleções/cota pelo snapshot. Não há implementação antecipada de conclusão, devolução ou reordenação.

| Aceite | Evidência |
| --- | --- |
| 1 — limite e concorrência | Três seleções recebem posições 1–3; quarta recebe `:quota_exhausted` sem sair do backlog. Duas conexões PostgreSQL distintas aguardam a mesma cadeia de locks (`pg_blocking_pids`) e disputam uma cota com consumo dois: exatamente uma sucede, a outra é rejeitada, contador termina em três e não há posição duplicada. Usuário diferente seleciona com cota própria mesmo com a primeira esgotada. |
| 2 — atomicidade e repetição | Constraint temporária no sandbox provoca falha de gravação da cota após movimento; tarefa e consumo permanecem originais. Repetir seleção corrente, inclusive após atingir limite ou vencer disputa, mantém posição e contador. IDs inválidos/alheios e concluída não modificam dados nem criam cota residual. |
| 3 — virada | Seleções na data anterior são normalizadas antes da nova seleção; a tarefa solicitada volta de retry para hoje com posição um e consome uma escolha da nova data. Outra vencida permanece retry. Cota antiga permanece em dois, nova fica em um; título, ID e labels preservados. Chamada sem data usa a data do servidor. |

TDD: antes da implementação, os quatro testes sequenciais falharam pela API ausente e os workers concorrentes também encontraram a API ausente. O teste concorrente revelou ainda ajustes necessários no harness: liberar o lock em falha e reconhecer bloqueio indireto por outro contendiente. Após essas correções e implementação, os **25 testes** então existentes de Tasks passaram; acrescentado caso de data padrão/isolamento da cota. Ajuda Mix já consultada nesta sessão. `rtk mix precommit` aprovado com **83 testes**. CI inicial pediu alias de Sandbox, corrigido; `rtk mix ci` final aprovado com **83 testes**, compilação/formatação/Credo estrito sem falhas, **88,22% de cobertura total**, Tasks **98,63%**, UserTransaction **100%**, mínimo de 70% preservado. `rtk git diff --check` aprovado.

Autoavaliação pelo fluxo de review: aceites cobertos no escopo produtor e nenhum achado bloqueante. A concorrência usa conexões reais e dados próprios removidos ao terminar; cobertura não prova todos os interleavings. CA-002-02 com conclusão permanece na TASK-007. Evidências encaminhadas para conferência de aceite do coordenador; revisão independente e integração ainda pendentes neste registro.
