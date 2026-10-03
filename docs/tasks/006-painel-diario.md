---
id: "TASK-006"
status: "done"
execution_level: "standard"
execution_rationale: "Integra LiveViews geradas a APIs existentes e remove superfícies CRUD fora do escopo."
specs: ["SPEC-001", "SPEC-002", "SPEC-004", "SPEC-005"]
depends_on: ["TASK-025"]
provides: ["task-live-scaffold"]
consumes: ["task-scaffold", "default-user", "ptbr-interface"]
write_scope: ["lib/planner_web/live/task_live/", "lib/planner_web/router.ex", "lib/planner_web/controllers/page*", "priv/gettext/", "test/planner_web/live/task_live_test.exs", "test/planner_web/controllers/task_controller_test.exs"]
blockers: []
---

# 006 — Gerar o painel e cadastro simples do MVP

## Objetivo e entrada

[SPEC-004](../specs/004-experiencia-e-acesso.md) e [SPEC-005](../specs/005-contas-e-acesso.md). Reusar Index/Form gerados sobre task-scaffold existente; resolver default-user no servidor ao abrir a página e passá-lo às APIs. Sem login, session guard ou seletor de conta. Remover Show/edição/exclusão, ajustar chamadas/testes e exibir mensagens em pt-BR via Gettext. Não manter subscribe/broadcast que sincronize abas automaticamente.

## Contrato do teste de rotas

A TASK-006 é responsável por adaptar `test/planner_web/controllers/task_controller_test.exs`, herdado da TASK-002 já concluída. Autorizar `GET /tasks` e `GET /tasks/new` para Index/Form do MVP; manter rejeitados `POST /tasks`, `GET /tasks/1`, `GET /tasks/1/edit`, `PUT /tasks/1`, `PATCH /tasks/1` e `DELETE /tasks/1`. Preservar o teste da página inicial. Não restaurar controllers ou superfícies do CRUD experimental.

A falha registrada no BLOCK-003 é estado inicial permitido desta retomada, não resultado final. Ajustar as asserções de intenção para distinguir as rotas LiveView autorizadas das superfícies rejeitadas e executar testes específicos, `mix precommit` e `mix ci` com o limiar vigente.

## Scaffold

```sh
mix phx.gen.live Tasks Task tasks title:string --no-context --no-scope
```

Consultar `mix help` antes de executar; adaptar o resultado conforme o contrato acima.

## Aceite

1. Abrir painel sem login permite cadastrar título no backlog do usuário padrão.
2. Recarga mantém os dados; erro de título aparece em pt-BR; params não trocam proprietário.
3. GET `/tasks` e `/tasks/new` resolvem para Index/Form; os seis métodos/caminhos CRUD listados acima continuam sem rota. A página inicial permanece disponível e os gates completos passam.

## Evidência e revisão

Execução interrompida em 03/10/2026 pelo implementador `/root/implement_task025`, base `d6a43e9`. [BLOCK-003](../blocks/003-escopo-teste-rotas-painel.md) registra conflito com teste preexistente fora do escopo, que exige ausência das rotas do painel. Diff preservado e não integrado; nenhuma revisão independente realizada.

Gerador exato executado após consulta à ajuda. Testes de intenção inicialmente falharam nas rotas ausentes; após adaptação do scaffold, **3 testes LiveView aprovados**: cadastro no backlog/default-user sem login, recarga/dados/pt-BR, validação e submissão inválida sem persistência, proprietário/estado forjados ignorados, Show/edição/exclusão indisponíveis. Index usa snapshot e stream de backlog; Form recebe usuário do servidor. Show removido, sem subscribe/broadcast. Página inicial preservada com acesso ao painel em `/tasks`; cadastro em `/tasks/new`.

`rtk mix precommit` e `rtk mix ci`: **107/108 testes aprovados**, falha única no teste legado de rotas. Compilação/formatação/Credo aprovados; cobertura total **90,40%**, Index e Form **100%**, limiar 70% preservado. Gate reprovado; pendentes resolução do impedimento, gates completos, autoavaliação final e conferência operacional/integração pelo coordenador.

## Decisão de retomada — 03/10/2026

BLOCK-003 resolvido por decisão documental de escopo solicitada pelo usuário: arquivo de teste incluído e contrato de rotas definido acima. TASK-006 permanece `in_progress`, pronta para retomar a correção e os gates; nenhuma entrega foi aprovada ou integrada por esta decisão. TASK-026 e consumidoras transitivas continuam aguardando sua conclusão.


## Entrega após retomada — 03/10/2026

Implementador `/root/implement_task025`, base `d6a43e9e8ba29d956b4086f89fbfae3e07b107dc` mais decisão documental de BLOCK-003. Ajustado somente o teste legado autorizado: as duas rotas de Index/Form agora são verificadas explicitamente; as seis superfícies CRUD continuam rejeitadas e o teste da página inicial foi preservado. Scaffold não foi regenerado.

| Critério | Evidência final |
| --- | --- |
| 1 — cadastro sem login | Teste LiveView navega Index → Form, cadastra título em inglês, confirma flash pt-BR e tarefa persistida no backlog do usuário padrão; conteúdo do usuário permanece intacto. |
| 2 — recarga/erros/proprietário | Nova montagem conserva tarefa e HTML `pt-BR`; validação e submissão vazias mostram erro traduzido e não gravam. Parâmetros de URL e evento com usuário/estado/data/posição forjados não trocam proprietário nem estado. Outra conta permanece inalterada e seus dados não aparecem no painel. |
| 3 — rotas e gates | Teste de rotas identifica Index/Form para GET `/tasks` e `/tasks/new`, rejeita seis rotas CRUD e mantém página inicial. Testes específicos de LiveView/rotas: **6 aprovados**. |

`rtk mix precommit` e `rtk mix ci`: **109 testes aprovados**, compilação, formatação e Credo estrito aprovados; cobertura **90,40% total**, `TaskLive.Index` e `TaskLive.Form` **100%**, limiar mínimo de 70% preservado. `rtk git diff --check` aprovado. Ajuda Mix já consultada nesta execução antes de utilizar tarefas/opções.

Autoavaliação pelo fluxo de review: aceites atendidos, sem achados bloqueantes no diff desta entrega. A experiência usa stream do backlog e APIs existentes, com proprietário explícito; nenhuma inscrição/broadcast ou superfície Show/edição/exclusão foi introduzida. Limitações: validação via LiveViewTest/HTML e testes de rotas, sem navegador real; acessibilidade completa, labels no formulário e demais listas pertencem às entregas seguintes.

Arquivos de implementação para integração seletiva: `lib/planner_web/live/task_live/index.ex`, `lib/planner_web/live/task_live/form.ex`, `lib/planner_web/router.ex`, `lib/planner_web/controllers/page_html/home.html.heex`, `priv/gettext/default.pot`, `priv/gettext/pt_BR/LC_MESSAGES/default.po`, `test/planner_web/live/task_live_test.exs` e `test/planner_web/controllers/task_controller_test.exs`, além deste registro e documentação de BLOCK-003. Alterações preexistentes do usuário em instruções/fluxos/skills/formato foram preservadas e não constituem implementação desta tarefa.

Estado `in_review`, sem staging/commit. Encaminhado ao coordenador para conferência superficial e integração; nenhuma revisão independente alegada. TASK-026 ainda não iniciada nem liberada por esta autoavaliação.

### Conferência operacional — 03/10/2026

Coordenador `/root`: registro e resumo conferidos superficialmente; gates locais relatados aprovados (109 testes, cobertura 90,40%), sem impedimentos pendentes. Entrega integrada em `ca84dfd`. TASK-026 liberada. Sem revisão independente ou verificação de CI remoto; alterações preexistentes de instruções preservadas fora do commit.
