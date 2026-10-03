---
id: "TASK-026"
status: "in_review"
execution_level: "standard"
execution_rationale: "Integra seleção múltipla e criação de labels ao formulário e cadastro atômico existentes."
specs: ["SPEC-004", "SPEC-006"]
depends_on: ["TASK-006"]
provides: ["task-label-form"]
consumes: ["task-live-scaffold", "task-create-with-labels", "user-label-catalog"]
write_scope: ["lib/planner_web/live/task_live/form.ex", "priv/gettext/", "test/planner_web/live/task_live_test.exs"]
blockers: []
---

# 026 — Adicionar múltiplas labels ao formulário gerado

## Entrada e limite

[SPEC-006](../specs/006-labels.md) CA-006-01 a CA-006-04; consumir task-live-scaffold e task-create-with-labels. Referências formulários e LiveView.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Estender formulário gerado com seleção de labels próprias e nomes de novas labels, enviando uma única chamada ao cadastro atômico. Reusar to_form e componentes existentes. Não criar tela separada de CRUD de labels.

## Aceite e teste de intenção

1. Selecionar várias existentes e criar novas funciona; erro não deixa registros parciais.
2. Formulário não lista labels alheias; ID forjado é rejeitado pelo contexto.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Implementador `/root/implement_task025`, em 03/10/2026. Base `5a5df3a`, com TASK-006 integrada em `ca84dfd`. Alvo: diff local de `lib/planner_web/live/task_live/form.ex`, `test/planner_web/live/task_live_test.exs`, `priv/gettext/default.pot`, `priv/gettext/pt_BR/LC_MESSAGES/default.po` e este registro. Alterações preexistentes de instruções/documentação preservadas; sem staging/commit.

Contrato `task-label-form`: Form carrega catálogo do usuário padrão resolvido no servidor, oferece seleção múltipla por ID e novas labels em campo textual com um nome por linha. Campo inteiramente vazio significa nenhuma nova label; linhas com nomes vazios são rejeitadas pelo contexto. Uma submissão chama `Tasks.create_task/2` uma única vez com todas as labels e o título. Erros do cadastro atômico são apresentados em pt-BR nos respectivos campos, preservando título, seleção e nomes informados. Reabertura do formulário lista as labels recém-criadas. Não foi criado CRUD separado nem alterado o contexto.

| Aceite | Evidência |
| --- | --- |
| 1 — existentes/novas e atomicidade | Teste LiveView seleciona duas labels próprias e cria duas novas, verifica as quatro associações e catálogo no cadastro seguinte. Teste existente continua cobrindo cadastro sem labels. Título inválido e segunda nova label vazia não deixam tarefas/labels parciais; seleção e entradas são preservadas para correção. |
| 2 — isolamento e rejeição | Opções não incluem label de outra conta. Eventos com ID alheio ou inexistente recebem erro traduzido em labels existentes, sem tarefa ou nova label persistida e sem revelar o nome privado. |

TDD: **3 testes novos falharam** pela ausência dos campos/erros antes da implementação; depois **6 testes LiveView aprovados**. `rtk mix precommit` e `rtk mix ci`: **112 testes aprovados**, compilação/formatação/Credo estrito aprovados, **90,46% de cobertura total**, Form **96,77%**, Tasks **98,31%**, mínimo 70% preservado. `rtk git diff --check` aprovado. Ajuda Mix já consultada nesta sessão; extração/merge restritos ao catálogo pt_BR, sem traduções fuzzy.

Autoavaliação pelo fluxo de review: critérios atendidos, sem bloqueadores identificados. Reuso de componentes, `to_form`, catálogo autorizado e transação do contexto. Cobertura do Form não inclui o ramo defensivo que repassa valores não textuais forjados de novas labels ao contexto; os caminhos reais do formulário e rejeições de IDs foram exercitados. Testes via LiveViewTest, sem navegador real; exibição de labels nas listas é entrega posterior. Estado `in_review`, aguardando conferência superficial e integração pelo coordenador. Nenhuma revisão independente alegada; TASK-027 não iniciada.
