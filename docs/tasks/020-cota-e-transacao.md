---
id: "TASK-020"
status: "done"
execution_level: "advanced"
execution_rationale: "Define bloqueio e contrato atômico reutilizado por todos os comandos; erro compromete cota e isolamento."
specs: ["SPEC-002", "SPEC-003"]
depends_on: ["TASK-019"]
provides: ["daily-quota-transaction"]
consumes: ["current-day", "task-scaffold", "default-user"]
write_scope: ["lib/planner/tasks/daily_plan.ex", "lib/planner/user_transaction.ex", "priv/repo/migrations/", "test/planner/user_transaction_test.exs"]
blockers: []
---

# 020 — Criar cota diária e fronteira transacional

## Objetivo e entrada

[SPEC-002](../specs/002-planejamento-diario.md) RN06/RN07 e [SPEC-003](../specs/003-dia-e-historico.md) RN01/RN03. Usar current-day e default-user. Ajustar migration: proprietário/data únicos, consumo 0–3, zero inicial e campos obrigatórios. Bloquear a linha do usuário antes de obter a cota da data capturada, protegendo também o conjunto vazio. Publicar fronteira para seleção, devolução, ordem e conclusão; não expor CRUD do contador nem implementar política de fuso.

## Scaffold

```sh
mix phx.gen.schema Tasks.DailyPlan daily_plans day:date used_choices:integer user_id:references:users --no-scope
```

Consultar `mix help` antes de executar; adaptar o resultado conforme o contrato acima.

## Aceite

1. Transações concorrentes serializam criação da cota vazia; rollback reverte consumo.
2. Reinício não zera registros; valores fora de 0–3 são rejeitados.

## Evidência e revisão

Implementador `/root/implement_task020`, em 25/09/2026. Base `93dec0b7fd223d7177cc244289519472a5c865d8` de `feat/mvp`, com TASK-019 e contratos current-day/default-user integrados. Alvo: arquivos locais `lib/planner/tasks/daily_plan.ex`, `lib/planner/user_transaction.ex`, `priv/repo/migrations/20260925175957_create_daily_plans.exs`, `test/planner/user_transaction_test.exs` e este registro. Sem staging/commit.

Scaffold solicitado executado após consulta à ajuda. Schema e migration ajustados com zero inicial, campos obrigatórios, FK para usuário, unicidade usuário/data e check de consumo entre zero e três. A versão inicial do scaffold foi aplicada durante o teste red; somente essa migration nova foi revertida no banco de testes e reaplicada com as constraints finais, verificadas por inserções diretas que ignoram o changeset.

Contrato `daily-quota-transaction` para a TASK-021 e demais consumidoras:

- `Planner.UserTransaction.run(user, operation, date \\ nil)` recebe usuário persistido resolvido no servidor e callback de aridade dois. A transação bloqueia a linha desse usuário com `FOR UPDATE`, captura uma única data e busca/cria a cota correspondente antes de invocar `operation.(day, daily_plan)`. O lock protege também a ausência inicial da cota e dura até commit/rollback.
- Sem data explícita, chama `Planner.Day.current/0` depois de adquirir o lock. O terceiro argumento é a `Date` controlada pelo chamador servidor/teste já admitida por `Planner.Day.current/1`; não é parâmetro de formulário, política de fuso ou estado global. As consumidoras reutilizam o `day` recebido durante toda a operação.
- O callback retorna `{:ok, value}` para commit ou `{:error, reason}` para rollback integral. `run` devolve a mesma forma, sem tupla adicional. Exceções também revertem a transação e são propagadas. Usuário inexistente levanta `Ecto.NoResultsError` antes da criação da cota/callback.
- `DailyPlan` tem `user_id`, `day` e `used_choices` (default zero). Seu changeset interno aceita somente alteração de `used_choices`; proprietário/data são atribuídos pelo servidor. Comandos futuros devem atualizar tarefa/cota/posições dentro do callback e filtrar seus dados pelo usuário recebido. Não foi publicado CRUD do contador no contexto.
- A TASK-021 ainda deve inserir a normalização de pendências vencidas nessa fronteira antes do callback e construir o snapshot. Esta entrega não movimenta tarefas, não monta coleções e não implementa seleção, devolução, ordem ou conclusão.

| Aceite | Evidência |
| --- | --- |
| 1 — criação concorrente e rollback | Duas conexões PostgreSQL distintas disputam cota inicialmente ausente. O teste observa `pg_blocking_pids` da segunda transação apontando para a primeira; após liberar a primeira, os consumos retornam um e dois, com uma única linha persistida. Outro usuário consegue commit durante o lock do primeiro. Erro do callback reverte criação inicial e, em registro existente, consumo e alteração adicional do usuário; exceção também reverte a tentativa. |
| 2 — persistência e faixa | Um Repo dedicado grava consumo, tem seu processo/pool encerrado com confirmação `DOWN`, reinicia com novo PID e nova conexão PostgreSQL e recupera exatamente o registro anterior. Changeset rejeita valores inválidos; inserções diretas no banco confirmam default zero, rejeição de -1/4, nulos, chave duplicada e proprietário inexistente. Novas datas/usuários começam em zero sem apagar a data anterior. |

TDD: seis falhas esperadas por ausência de `Planner.UserTransaction`; após implementação, os seis testes passaram. A suíte específica final tem dez testes, incluindo constraints e reinício real do pool. `mix precommit` e `mix ci` aprovados com **72 testes**, compilação/formatação e Credo estrito sem falhas. Cobertura total **86,97%**, `Planner.UserTransaction` e `Planner.Tasks.DailyPlan` **100%**, limiar de 70% preservado. Ajuda dos geradores, testes e gates consultada antes do uso.

Autoavaliação pelo fluxo de review: aceites cobertos, sem achado bloqueante no escopo local. A captura da data após lock foi conferida na implementação; teste confirma data padrão UTC e data coerente no callback. O teste de persistência reinicia o Repo/pool, sem reiniciar a VM inteira nem o servidor PostgreSQL. Cobertura de linhas não prova todos os interleavings; todos os comandos consumidores precisam adotar a mesma fronteira e o mesmo filtro de proprietário. Revisão detalhada independente permanece pendente; esta autoavaliação não equivale a aprovação independente. Entrega encaminhada ao coordenador para conferência superficial excepcional autorizada pelo usuário e eventual integração. A pedido do usuário, nenhuma tarefa seguinte foi iniciada.

### Aceite operacional excepcional e encerramento — 25/09/2026

Coordenador `/root`: conferência superficial dos arquivos entregues, limites do escopo, contrato e evidências dos dois aceites; `git diff --check` aprovado. Gates relatados pelo implementador: 72 testes, cobertura total 86,97%, sem mudanças posteriores no código. O usuário autorizou explicitamente liberar dependentes após conferência superficial nesta rodada, com revisão detalhada pendente. Por essa exceção, `done` registra conclusão operacional após o commit local com TASK-020 que inclui este registro, sem declarar aprovação independente. A revisão detalhada das TASK-019 e TASK-020 permanece **pendente** e o marco `docs/review.md` não foi alterado. A pedido posterior do usuário, a rodada termina nesta tarefa: TASK-021 não iniciada.

### Revisão detalhada independente — 25/09/2026

Revisor `/root`, nesta sessão sem participação na implementação: **approved**, sem achados bloqueantes. Base `9ec53063065ac434895baa70333d49824ee8fb91`, alvo integrado `6b8030933cdf64c7390709e3cc825d4300106fc3`, sem divergência executável local. Os dois aceites foram conferidos: serialização em conexões distintas, rollback, constraints e persistência após reinício do Repo/pool. UserTransaction e DailyPlan: 100% de cobertura. Não houve reinício da VM/PostgreSQL nem implementação de consumidoras. `rtk mix ci` reproduzido: 72 testes aprovados, cobertura total 86,97%, limiar 70% preservado. A pendência de revisão detalhada registrada acima fica encerrada; evidências e limites em [docs/review.md](../review.md).
