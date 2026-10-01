---
id: "TASK-021"
status: "in_review"
execution_level: "advanced"
execution_rationale: "Virada, normalização e snapshot precisam compartilhar atomicidade e data com comandos concorrentes."
specs: ["SPEC-002", "SPEC-003"]
depends_on: ["TASK-020"]
provides: ["planning-snapshot"]
consumes: ["current-day", "daily-quota-transaction"]
write_scope: ["lib/planner/tasks.ex", "lib/planner/user_transaction.ex", "test/planner/tasks_test.exs"]
blockers: []
---

# 021 — Normalizar a virada ao consultar ou executar comandos

## Objetivo e entrada

[SPEC-003](../specs/003-dia-e-historico.md) RN02/RN03/RN07 e [SPEC-002](../specs/002-planejamento-diario.md) RN02/RN07. Consumir current-day e daily-quota-transaction. Normalizar pendências vencidas para retry e limpar posições antes do snapshot/comando. Entregar listas de backlog/hoje/retry, data e cota do usuário padrão. Não usar timer, scheduler ou atualização automática de tela.

## Aceite

1. Mudar a data controlada e consultar move pendências anteriores para retry sem concluir; repetição é idempotente.
2. Depois de reinício, snapshot mantém cota e coleções coerentes; comando antigo é revalidado.

## Evidência e revisão

Implementador `/root/implement_task021`, em 01/10/2026. Base `ed37fdbe7c91fed6cb6eb9c1ab95ee1deda125d8` de `feat/mvp`, com TASK-020 integrada e revisão independente aprovada. Alvo: diff local de `lib/planner/tasks.ex`, `lib/planner/user_transaction.ex`, `test/planner/tasks_test.exs` e este registro. Sem staging/commit; integração e revisão independente pendentes.

Contrato `planning-snapshot` para consumidoras:

- `Planner.Tasks.snapshot(user, date \\ nil)` recebe o usuário resolvido no servidor e retorna `{:ok, snapshot}`. O mapa contém `day`, `used_choices`, `available_choices`, `backlog`, `today` e `retry`. Cota disponível é três menos o consumo persistido, sem dedução pela quantidade de pendências. A data opcional segue o contrato servidor/testes da TASK-020, nunca parâmetros do navegador.
- As três listas contêm somente pendências próprias com labels carregadas. Backlog/retry seguem criação crescente e ID crescente; hoje contém apenas a data capturada, por posição e ID. Concluídas ficam fora de todas as listas.
- `UserTransaction.run/3` agora normaliza tarefas próprias `today`, sem conclusão e com `scheduled_for` anterior à data capturada, antes de chamar a operação. Define `kind: :retry`, limpa posição e atualiza timestamp técnico, preservando identidade, título, labels e data da seleção. O lock do usuário cobre normalização, cota e leitura das coleções.
- Erro do callback reverte também a normalização e criação da cota; uma consulta posterior reaplica a virada. Consumidoras devem consultar/revalidar o estado dentro do callback e reutilizar sua data. Não foram implementadas seleção, devolução, ordem ou conclusão antecipadamente; suas rejeições específicas pertencem às tarefas seguintes.

| Aceite | Evidência |
| --- | --- |
| 1 — virada e idempotência | Snapshot transforma pendência vencida em retry com posição nula, sem concluir ou mudar identidade/título/labels/data da seleção. Preserva concluída, pendência corrente e tarefa de outro usuário. Repetição retorna snapshot idêntico. Ordenação de backlog/retry por criação e desempate por ID; hoje por posição. Data padrão vem do servidor. |
| 2 — reinício e revalidação | Teste grava coleções/cotas em Repo dedicado, encerra seu processo/pool com confirmação `DOWN`, reinicia com PID e conexão PostgreSQL distintos e recupera snapshot idêntico. Ao avançar a data, move vencida para retry e reutiliza consumo já persistido da nova data; cota antiga permanece intacta. Callback simulando comando antigo recebe tarefa já normalizada e data/cota coerentes; rejeição reverte toda a transação, e consulta seguinte normaliza novamente. |

TDD: cinco falhas esperadas antes da implementação (quatro por snapshot ausente, uma por callback ainda observar `today` vencido), depois **20 testes de Tasks aprovados**. Ajuda de `test`, `precommit` e `ci` consultada. `rtk mix precommit`: **77 testes aprovados**, compilação/formatação sem falhas. Primeira execução de CI apontou ordenação de alias no teste; corrigida. `rtk mix ci` final: **77 testes aprovados**, Credo estrito/formatação/compilação aprovados, **87,46% de cobertura total**, Tasks **98,15%**, UserTransaction **100%**, mínimo de 70% preservado. `rtk git diff --check` aprovado.

Autoavaliação pelo fluxo de review: critérios cobertos no escopo produtor, sem achado bloqueante; somente os quatro arquivos acima alterados. O reinício cobre Repo/pool, não VM ou PostgreSQL inteiro; revalidação de comando usa callback de teste, pois comandos concretos são entregas futuras. Testes da fronteira existente continuam verificando serialização em conexões independentes; não se afirma cobertura de todos os interleavings. Esta autoavaliação não representa aprovação independente nem avança o marco de review. Encaminhado ao coordenador para revisão independente e integração.

### Revisão independente — 01/10/2026

Revisor `/root/review_task021`, sem participação na implementação: **approved**, sem achados bloqueantes. Base e HEAD `ed37fdbe7c91fed6cb6eb9c1ab95ee1deda125d8`; alvo é exclusivamente o diff local dos três arquivos executáveis e deste registro identificados acima, sem alterações staged ou arquivos não rastreados. TASK-020 integrada e aceite independente conferidos. O marco de `docs/review.md` foi consultado e preservado: HEAD ainda não contém esta entrega.

Aceites 1 e 2 atendidos no escopo produtor. Inspeção e testes confirmam normalização sob lock antes do callback, data única, filtro de proprietário e pendências vencidas, preservação de identidade/labels/conclusões, limpeza de posição, idempotência, ordenação das coleções, consumo persistido independente da quantidade de pendências e rollback conjunto da normalização/cota. Reinício real do Repo/pool recupera coleções e cotas, inclusive consumo previamente gravado na data seguinte. A suíte existente de concorrência continua aprovada com conexões PostgreSQL distintas.

Verificação independente: aliases e ajuda de `ci` consultados; `rtk mix ci` aprovado, saída 0, **77 testes**, compilação/formatação/Credo estrito aprovados, **87,46% de cobertura total**, Tasks **98,15%**, UserTransaction **100%**, mínimo de 70% preservado. `precommit` permanece evidência relatada pelo implementador; o revisor reproduziu o gate sem correção automática. Não foi remedida a base para afirmar variação de cobertura.

Limites: reinício validado no Repo/pool, não na VM ou no servidor PostgreSQL; rejeição do comando antigo demonstrada por callback, sem aprovar antecipadamente comandos das consumidoras futuras. Cobertura de linhas e serialização da fronteira não demonstram todos os interleavings. Aprovação técnica do diff local não representa integração, commit ou autorização de publicação remota.
