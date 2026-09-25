---
id: "TASK-019"
status: "done"
execution_level: "standard"
execution_rationale: "Compõe tarefa, labels e vínculos em uma transação com rollback integral."
specs: ["SPEC-002", "SPEC-006"]
depends_on: ["TASK-018"]
provides: ["task-create-with-labels"]
consumes: ["task-label-storage", "user-label-catalog"]
write_scope: ["lib/planner/tasks.ex", "test/planner/tasks_test.exs", "test/support/fixtures/tasks_fixtures.ex"]
blockers: []
---

# 019 — Cadastrar tarefa e labels em uma transação

## Entrada e limite

[SPEC-006](../specs/006-labels.md) RN02–RN05, CA-006-01 a CA-006-04; consumir task-label-storage e catálogo transacional. Referência Ecto.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Estender cadastro por título para aceitar IDs próprios e nomes de novas labels. Compor criação de tarefa/labels/vínculos em uma transação; normalizar IDs repetidos. Não criar edição nem seleção para hoje.

## Aceite e teste de intenção

1. Sem labels, com várias existentes e com existentes+novas produz vínculos corretos.
2. Título/nome inválido, ID alheio e falha de persistência revertem toda a tentativa.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Implementador `/root/implement_task019`, em 25/09/2026. Base `38e460f6c60a065f368f1037484b3e19e5d294d0` de `feat/mvp`, com TASK-018 e TASK-010 integradas. Alvo: diff local em `lib/planner/tasks.ex`, `test/planner/tasks_test.exs` e este registro; sem staging/commit. Nenhum scaffold ou migration foi criado.

Contrato `task-create-with-labels` para consumidoras:

- `Planner.Tasks.create_task(user, attrs \\ %{})` continua retornando `{:ok, task}` ou `{:error, changeset}` nas falhas de validação. `attrs` recebe `title`, `label_ids` e `new_label_names` em mapa com chaves atom ou string. Os dois campos de labels são listas opcionais; omissão equivale a lista vazia. IDs próprios podem ser inteiros ou strings decimais e são normalizados e deduplicados. Os nomes novos são criados como identidades próprias, sem fusão por texto.
- `user` é o proprietário resolvido no servidor. A tarefa é criada no backlog; o vínculo usa o mesmo `user_id`. IDs alheios ou inexistentes produzem erro em `label_ids`, sem diferenciar os dois casos. Nome inválido produz erro em `new_label_names`; título inválido mantém o erro em `title`. Campos de proprietário/estado forjados continuam ignorados.
- Uma transação engloba tarefa, criação de novas labels e vínculos. Falhas esperadas de validação retornam changeset e revertem a tentativa. Erros inesperados do banco podem lançar exceção, com rollback da transação. A tarefa retornada em sucesso tem `labels` ainda não carregadas; usar `Repo.preload/2` quando necessário.

| Aceite | Evidência |
| --- | --- |
| 1 — zero/várias existentes e combinação com novas | Teste preexistente de título agora verifica zero vínculos; teste com duas labels próprias e ID repetido em inteiro/string confirma exatamente dois vínculos; teste com uma existente e duas novas confirma três vínculos e novas labels no catálogo. |
| 2 — rollback integral | Título inválido não cria tarefa/label; segundo nome inválido reverte tarefa, primeira nova label e vínculos, preservando a preexistente; IDs alheio/inexistente e entradas malformadas não deixam registros; constraint de teste faz o banco rejeitar o vínculo depois da criação da tarefa/label nova, e a exceção reverte a tentativa inteira. |

TDD: quatro falhas esperadas com os testes de intenção iniciais, por vínculos ausentes e entradas inválidas aceitas; após a implementação, 13 testes do contexto passaram. Testes adicionais cobriram entrada malformada e rejeição do banco. Validação final: `mix precommit` e `mix ci` aprovados com **62 testes**, Credo estrito sem achados, cobertura total **85,98%** e `Planner.Tasks` **97,78%**; limiar de 70% preservado. `git diff --check` aprovado antes do registro documental.

Autoavaliação: critérios da TASK-019 cobertos pelos cenários acima, sem achado bloqueante identificado no diff local. A constraint de teste existe apenas na transação isolada do teste e é revertida pelo sandbox. Cobertura de linhas não prova todos os interleavings concorrentes; FKs compostas da TASK-018 mantêm a compatibilidade de proprietário no banco caso uma label desapareça após a consulta. A TASK-019 não cria formulário, edição ou seleção para hoje. Revisão detalhada independente e integração permanecem pendentes; esta autoavaliação não equivale a aprovação independente.

### Aceite operacional excepcional — 25/09/2026

Coordenador `/root`: conferência superficial do diff contra o escopo e os dois critérios, evidências dos gates acima e `git diff --check` aprovado. Solicitada e entregue evidência adicional de rollback por falha de persistência. O usuário autorizou explicitamente: “Liberar após conferência superficial nesta rodada, registrando revisão detalhada pendente.” Nesta rodada, `done` registra a entrega operacional e permite consumidoras após o commit local, por exceção à exigência habitual de revisão prévia. A revisão detalhada independente permanece **pendente**; não houve revisão independente nem avanço do marco em `docs/review.md`. A entrega será identificada pelo commit com TASK-019 que inclui este registro; a pendência histórica de integração acima é superada quando esse commit estiver na base da consumidora.

### Revisão detalhada independente — 25/09/2026

Revisor `/root`, nesta sessão sem participação na implementação: **approved**, sem achados bloqueantes. Base `9ec53063065ac434895baa70333d49824ee8fb91`, alvo integrado `6b8030933cdf64c7390709e3cc825d4300106fc3`, sem divergência executável local. Cadastro e deduplicação, isolamento de proprietário e rollback integral conferidos contra os dois aceites e SPEC-006. Tasks: 97,78% de cobertura. `rtk mix ci` reproduzido: 72 testes aprovados, cobertura total 86,97%, limiar 70% preservado. A pendência de revisão detalhada registrada acima fica encerrada; evidências e limites em [docs/review.md](../review.md).
