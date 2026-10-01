---
id: "TASK-024"
status: "in_review"
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

Implementador `/root/implement_task021`, em 01/10/2026. Base `e88f15afd6f5f6e84d8cfcb69bce3018e3b7859d` de `feat/mvp`, com TASK-023 integrada e conferida operacionalmente. Alvo: diff local de `lib/planner/tasks.ex`, `test/planner/tasks_test.exs`, migration nova `20261001195014_constrain_today_positions.exs` e este registro. Sem staging/commit. Revisão independente permanece pendente ao final da rodada, por orientação explícita do responsável; autoavaliação não equivale a aprovação independente.

Contrato `reorder-today`:

- `Planner.Tasks.reorder_today(user, ids, date \\ nil)` recebe usuário resolvido no servidor, lista de IDs inteiros/strings numéricas e data opcional servidor/teste. Retorna `{:ok, tasks}` na ordem solicitada ou `{:error, :invalid_order}`. Lista vazia é válida somente com conjunto corrente vazio.
- Dentro de `UserTransaction.run/3`, captura o conjunto próprio de pendências da data após normalização. Exige mesma cardinalidade e mesmo conjunto de IDs, impedindo duplicados, ausentes, alheios, concluídos ou conjunto antigo. Grava posições 1–N sem alterar consumo; rejeição ou exceção reverte tudo.
- A migration exige posição positiva quando presente e posição/data não nulas em `today` pendente. Índice único parcial por usuário/data/posição abrange somente `today` sem conclusão. Não restringe posições a 1–3 no banco, pois a persistência atômica de trocas usa temporariamente posições positivas acima da maior corrente e depois grava 1–N; nenhum estado intermediário é exposto pelo contexto. O lock do usuário serializa a operação com seleção/devolução, e o índice permanece ativo em ambas as etapas. Compactação existente continua válida, movendo posições crescentes após liberar a removida.

| Aceite | Evidência |
| --- | --- |
| 1 — permutação e rejeição integral | Inversão de três tarefas persiste posições 1–3 com cota inalterada; repetição preserva ordem. IDs duplicados, incompletos, desconhecidos, alheios, backlog, concluídos, não convertíveis e listas inválidas preservam snapshot integral. Mudanças por seleção/devolução e virada invalidam conjuntos antigos. Conjunto vazio e data padrão são exercitados. |
| 2 — concorrência e atomicidade | Corridas com seleção e com devolução usam conexões PostgreSQL distintas e confirmam espera real por lock. Reordenação sucede antes da mutação ou rejeita conjunto antigo depois dela; conjunto final, posições e consumo correspondem somente à mutação aceita. Constraint temporária provoca falha na etapa final da reordenação, depois de reservar posições temporárias; snapshot e cota originais são recuperados integralmente. |
| Invariantes físicas | Gravações diretas pelo Repo rejeitam posição duplicada corrente, zero, negativa, posição ausente e data ausente em `today` pendente; outro usuário pode usar a mesma posição/data. Troca reversa, seleção, devolução/compactação, normalização e cenários anteriores passam com os índices ativos. |

TDD: ajuda do gerador consultada, scaffold gerado e migration integralmente preenchida antes da primeira aplicação. Nenhuma migration integrada revertida ou editada. Primeiro teste teve seis falhas pela API ausente; constraints já passaram. Após implementação, **40 testes de Tasks aprovados**. `rtk mix precommit` e `rtk mix ci`: **97 testes aprovados**, compilação/formatação/Credo estrito aprovados, **89,08% de cobertura total**, Tasks **98,13%**, UserTransaction **100%**, mínimo de 70% preservado. CI repetido após tornar a asserção de repetição independente do timestamp técnico. `rtk git diff --check` aprovado.

Autoavaliação pelo fluxo de review: aceites atendidos, sem bloqueadores identificados. A migration foi validada no banco de testes, sem aplicar rollback de bases existentes; não foi simulada instalação com dados legados inválidos. Concorrência cobre resultados serializáveis de disputas reais, sem enumerar todos os interleavings. Cobertura de linhas não substitui asserções das constraints nem garante todas as exceções defensivas. Encaminhada ao coordenador para conferência operacional; revisão independente e integração pendentes neste registro.
