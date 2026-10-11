---
id: "TASK-018"
status: "done"
execution_level: "standard"
execution_rationale: "Modela vínculos muitos-para-muitos com unicidade e compatibilidade de proprietário."
specs: ["SPEC-006"]
depends_on: ["TASK-005"]
provides: ["task-label-storage"]
consumes: ["task-scaffold", "user-label-catalog"]
write_scope: ["lib/planner/tasks/task_label.ex", "lib/planner/tasks/task.ex", "lib/planner/labels/label.ex", "priv/repo/migrations/", "test/planner/task_label_test.exs"]
blockers: []
---

# 018 — Criar a relação muitos-para-muitos de labels

## Entrada e limite

[SPEC-006](../specs/006-labels.md) RN02/RN03; consumir task-scaffold e user-label-catalog. Referência Ecto.

## Scaffold

```sh
mix phx.gen.schema Tasks.TaskLabel task_labels task_id:references:tasks label_id:references:labels user_id:references:users --no-scope
```

Consultar `mix help` antes de executar. O comando pertence à implementação desta tarefa; não foi executado no planejamento.

## Ajustes desta entrega

Ajustar associação gerada para many_to_many e constraints: vínculo único, FKs válidas e proprietário compatível nos dois lados. Se usar FKs compostas, criar índices necessários nesta migration. Não criar CRUD público de vínculo nem formulário.

## Aceite e teste de intenção

1. Persistir duas labels próprias para uma tarefa funciona; repetição não duplica vínculo.
2. Constraints/validações impedem associação com tarefa ou label de outro proprietário.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Implementador `/root/implement_task005`, em 25/09/2026, base `6a6e56a2b4dfed0827558c0dda40f716440f3a7d` de `feat/mvp`. Dependências TASK-005 e TASK-010 aprovadas e integradas. Scaffold exato executado após consultar `mix help phx.gen.schema`. Alvo: TaskLabel, associações de Task/Label, migration `20260925120812_create_task_labels`, testes `task_label_test.exs` e este registro. Sem staging/commit.

Contrato `task-label-storage` para a consumidora:

- `Task.labels` e `Label.tasks` são associações `many_to_many` por `Planner.Tasks.TaskLabel`; permitem preload e reuso de uma label em múltiplas tarefas. Não há ordem de labels contratada.
- A operação interna de persistência usa `%TaskLabel{user_id: user.id} |> TaskLabel.changeset(%{task_id: task.id, label_id: label.id}) |> Repo.insert()`. O usuário é resolvido no servidor; `user_id` não entra no cast. Todos os três IDs são obrigatórios.
- O changeset converte violações de unicidade e FKs em erros. Repetir o par retorna erro de unicidade em `task_id` e mantém apenas um vínculo. A TASK-019 normalizará IDs repetidos antes de inserir e comporá a transação integral; essa normalização não pertence ao storage.
- A migration exige IDs não nulos, FK de usuário, FKs compostas `(task_id, user_id)` e `(label_id, user_id)`, e unicidade `(task_id, label_id)`. Índices únicos `(id, user_id)` de tasks/labels são criados nesta mesma migration. A compatibilidade é imposta no banco, sem depender de consulta prévia.
- Nenhum CRUD público de vínculo, formulário ou cadastro atômico foi criado. A consumidora deve atribuir explicitamente o owner ao vínculo e reverter sua transação ao receber erro; associação Ecto não substitui esse comando composto.

| Aceite | Evidência |
| --- | --- |
| 1 — várias labels e vínculo único | Teste carrega tarefa sem labels, persiste duas labels próprias, reutiliza uma em outra tarefa e confirma preloads nos dois sentidos. Segundo teste tenta repetir o par e verifica erro e contagem exatamente um. |
| 2 — FKs e owner compatível | Testes rejeitam tarefa alheia, label alheia, owner diferente do par completo e IDs inexistentes, com contagem zero após rejeição. Testes adicionais exigem os três IDs e confirmam que owner forjado em attrs atom/string é ignorado. |

TDD: oito testes escritos sobre o scaffold antes dos ajustes; sete falharam por associação ausente e falta de constraints/validação (um já passava por owner não entrar no cast). Após ajustes, oito passaram. A migration recém-gerada foi revertida e reaplicada apenas no banco test para validar seu conteúdo final; sem reset ou alteração do banco de desenvolvimento. O gerador de schema não produziu testes a preservar.

Gates: `mix precommit` e `mix ci` aprovados com **55 testes**, compilação/formatação/Credo estrito sem falhas; cobertura total **84,05%**, TaskLabel/Task/Label **100%**, limiar de 70% preservado. A entrega anterior registrava 83,48%; não houve medição isolada nova da base. `git diff --check` aprovado.

Autoavaliação pelo fluxo de review: critérios atendidos nos cenários descritos, sem achados bloqueantes identificados. Cobertura de linhas não equivale à prova de todos os ramos. Rollback integral de cadastro, deduplicação de entrada e UI pertencem à TASK-019 ou consumidoras posteriores e não foram avaliados aqui. Estado `in_review`: revisão independente e integração pendentes; não liberar consumidora antes desses passos. Por orientação atual do usuário, encerrar a rodada após concluir esta tarefa e não iniciar TASK-019.

### Revisão independente — 25/09/2026

Revisor `/root/review_task005`, independente do implementador, aplicando `review-code-diff` e o fluxo de review. Resultado **approved**, sem achados bloqueantes. Base/HEAD `6a6e56a2b4dfed0827558c0dda40f716440f3a7d`; alvo: diff local de Task/Label, novos TaskLabel, migration `20260925120812_create_task_labels.exs`, testes `task_label_test.exs` e registro desta tarefa, incluindo arquivos não rastreados. Staging vazio. Dependências integradas; marco `docs/review.md` preservado até a integração do código pelo coordenador.

Aceites atendidos: associações `many_to_many` nos dois sentidos permitem zero/várias labels e reuso. Índice único impede duplicar par tarefa/label; changeset traduz a violação. IDs obrigatórios, FK de usuário e FKs compostas para tarefa/label garantem proprietário compatível no banco, com índices de referência criados na própria migration. Atributo de owner fica fora do cast; testes rejeitam tarefa alheia, label alheia, owner incompatível com o par e IDs inexistentes, sem persistir vínculo. Preloads nos dois sentidos e contagem após duplicação verificam comportamento observável. Nenhuma API CRUD pública ou formulário acrescentado.

Validação independente: `mix help ci` consultado; `rtk mix ci` aprovado com **55 testes**, compilação/formatação/Credo estrito sem falhas, cobertura total **84,05%** e TaskLabel/Task/Label **100%**, mantendo o mínimo de 70%. Tentativa no sandbox encontrou bloqueio de lock TCP; repetição escalada passou. `rtk git diff --check` aprovado. Precommit e reaplicação prévia da migration são evidências relatadas, não repetidas nesta revisão. Não houve nova medição isolada da base, reset ou alteração do banco de desenvolvimento. Cobertura não demonstra todos os ramos; concorrência não foi exercitada em conexões independentes, embora a unicidade seja imposta por índice no banco.

Limites: esta aprovação cobre o storage da relação, não o cadastro composto nem deduplicação de IDs de entrada. Os testes usam savepoints para continuar verificando o estado após rejeições de constraints; a TASK-019 deve tratar o erro e reverter sua transação integral, conforme contrato. Nenhum código corrigido, staging ou commit pelo revisor. Aprovação técnica não comprova integração. Conforme orientação atual, encerrar após TASK-018 e não iniciar TASK-019.

### Integração aceita e encerramento — 25/09/2026

Coordenador `/root`: entrega aprovada por `/root/review_task005` e integrada em `feat/mvp`, commit `9ec53063065ac434895baa70333d49824ee8fb91`. Conteúdo staged conferido; nenhum código mudou após o gate independente (55 testes, 84,05%). Contrato `task-label-storage` liberado. Registros anteriores de pendência são históricos. Por solicitação do responsável, execução encerrada após TASK-018; TASK-019 não iniciada.
