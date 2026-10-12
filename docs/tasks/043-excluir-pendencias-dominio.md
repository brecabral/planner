---
id: "TASK-043"
status: "in_review"
execution_level: "advanced"
execution_rationale: "Remoção definitiva exige atomicidade, compactação e disputa com conclusão e virada."
specs: ["SPEC-002", "SPEC-003", "SPEC-006"]
depends_on: ["TASK-042"]
provides: ["delete-pending-task"]
consumes: ["retry-to-backlog"]
write_scope: ["lib/planner/tasks.ex", "lib/planner/tasks/", "priv/repo/migrations/", "test/planner/", "docs/tasks/043-excluir-pendencias-dominio.md"]
blockers: []
---

# 043 — Excluir pendências preservando histórico e cota

## Objetivo e entradas

Implementar somente a operação de domínio de exclusão (SPEC-002 RN12–RN13/CA-002-13–14). Ler Tasks, TaskLabel, UserTransaction, constraints/FKs vigentes e referências Elixir/Ecto/testes. Usar recurso existente; nenhuma geração de CRUD. Nova migration somente se indispensável para o contrato, preservando migrations aplicadas e dados existentes.

## Aceite e testes

1. Pendência própria removida de backlog/retry/hoje deixa posições consecutivas; vínculos somem, labels permanecem. Hoje restitui exatamente uma escolha; demais listas não alteram consumo.
2. Concluída/ID ausente/alheio/repetido retornam indisponível sem revelar proprietário ou alterar cota. Repetir não restitui novamente.
3. Após virada, pendência vencida é retry e sua exclusão não reduz cota nova. Concorrência com excluir/devolver/concluir serializa e preserva invariantes; concluir vencedor mantém histórico não excluível.
4. Falha provocada de persistência reverte tarefa, vínculos, posições, cota e normalização. Testes de domínio verificam efeitos observáveis. Não expor botão antes da consumidora TASK-044.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.


## Entrega — 12/10/2026

Implementador `/root/implement_task042`, capacidade advanced; base `424b272438ebab9367d931a23d794d2eca5707f9`, branch `feat/ux`, árvore inicialmente limpa. TASK-042 integrada e `done`; SPEC-002/003 `ready`, SPEC-006 `implemented`, sem bloqueios. Quatro arquivos no escopo: `lib/planner/tasks.ex`, `test/planner/task_deletion_test.exs` (novo), `test/planner/tasks_test.exs` e esta tarefa. Nenhuma migration ou interface alterada.

Contrato entregue para TASK-044: `Tasks.delete_pending_task(user, id, date \\ nil)` recebe proprietário resolvido no servidor e ID; data opcional é exclusiva do servidor/testes. Retorna `{:ok, task}` com struct removida, ou `{:error, :not_found}` uniforme para ausente, malformado, alheio, repetido e concluído. Falhas de persistência levantadas pelo Repo revertem a transação e propagam a exceção, conforme a fronteira existente; a consumidora deve usar o tratamento de persistência já adotado nos outros comandos. Não depende de labels carregadas no retorno.

A operação usa `UserTransaction.run` para lock, data, cota e normalização. Remove explicitamente vínculos próprios antes da tarefa, reutiliza compactação existente e restitui uma escolha somente se a tarefa ainda for hoje na data corrente. FKs existentes com `on_delete: :nothing` permanecem válidas; nenhuma alteração de schema é necessária.

| Aceite | Evidência e resultado |
| --- | --- |
| 1 — remoção/compactação/labels/cota | Três casos parametrizados em `task_deletion_test.exs` excluem tarefa intermediária de backlog/retry/hoje, comprovam tarefa/vínculos ausentes, catálogo e vínculos das vizinhas preservados, posições 1/2 e consumo 3 nas primeiras duas listas ou 2 em hoje. |
| 2 — indisponível uniforme | Casos para ID nil/malformado/inexistente/alheio/concluído e repetição após cada lista confirmam `:not_found`, snapshot/cota preservados, histórico com labels intacto e tarefa alheia inalterada. |
| 3 — virada e concorrência | Exclusão direta no dia seguinte remove vencida normalizada sem restituição, conserva consumo anterior e deixa nova cota zero; variante sem data usa relógio do servidor. Teste em `tasks_test.exs` disputa exclusão com excluir/devolver/concluir em conexões distintas com espera comprovada no lock PostgreSQL: duas exclusões têm exatamente um sucesso; restituição ocorre no máximo uma vez; conclusão vencedora preserva histórico/cota e rejeita exclusão. Rejeição de concluída é também coberta deterministicamente fora da corrida. |
| 4 — rollback completo | Constraint de cota provoca falha após remoção e compactação, preservando snapshot e vínculos. Constraint de posição provoca falha após remoção de retry normalizada, restaurando tarefas/vínculos e impedindo criação do plano diário. Não há botão, evento web ou hook novo. |

TDD enxuto: sete casos iniciais falharam pela API inexistente (setup válido), passaram após implementação; warnings de comparação constante no teste parametrizado foram eliminados usando tags. Os 58 testes específicos então executados passaram. Primeiro CI apontou profundidade de função; extração de helper privado manteve a mesma transação e o gate subsequente passou.

Validações via RTK, usando ajudas Mix já consultadas nesta sessão: `mix test test/planner/task_deletion_test.exs` (vermelho e verde); `mix test test/planner/task_deletion_test.exs test/planner/tasks_test.exs` (**58 aprovados**); `mix precommit` (**174 aprovados**); `mix ci` (**174 aprovados**, cobertura total **93,50%**, Tasks **97,94%**, mínimo 70% preservado, Credo estrito sem achados, assets compilados e npm audit sem vulnerabilidades); `git diff --check` aprovado.

Autoavaliação pelo fluxo de review: **approved no escopo técnico validado**, sem achados bloqueantes, avaliando os três arquivos de código/testes locais contra a base acima. Cobertura total anterior: 93,37%; atual: 93,50%. A métrica é de linhas Elixir, não comprova todos os interleavings; a corrida real valida resultados serializáveis e testes determinísticos cobrem rejeição de histórico. Não é revisão independente e não avança o marco independente. Teste JS adicional não se aplica, pois hook não mudou. Sem validação de interface nesta entrega de domínio.

Estado `in_review`: aguarda conferência operacional e commit de integração pelo coordenador. Sem staging, commit, publicação ou início de consumidoras pelo implementador.
