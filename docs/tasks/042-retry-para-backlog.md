---
id: "TASK-042"
status: "done"
execution_level: "advanced"
execution_rationale: "Amplia transição transacional e contrato de arraste, preservando concorrência e cota."
specs: ["SPEC-002", "SPEC-004"]
depends_on: ["TASK-041"]
provides: ["retry-to-backlog"]
consumes: ["task-menu-layout"]
write_scope: ["lib/planner/tasks.ex", "lib/planner_web/live/task_live/index.ex", "assets/js/task_drag.js", "assets/test/", "priv/gettext/", "test/planner/", "test/planner_web/live/task_live_test.exs", "docs/tasks/042-retry-para-backlog.md"]
blockers: []
---

# 042 — Permitir enviar retry ao backlog

## Objetivo e entradas

Implementar SPEC-002 RN11/CA-002-12 e SPEC-004 RN18/CA-004-15. Ler fronteira de movimento/lock existente, hook e testes, design D16/D18 e referências Elixir/Ecto/LiveView/interop/testes. Reutilizar APIs de movimento e menu; não gerar contexto/schema nem criar segunda implementação de ordenação.

## Aceite e testes

1. Retry → backlog pelo menu insere ao final; arraste aceita início/meio/fim/destino vazio. Identidade e labels permanecem, posições compactam e cota não muda mesmo esgotada.
2. Backlog → retry e hoje → retry continuam rejeitados pelo servidor e hook. Payload alheio/antigo/incompleto não produz alteração parcial.
3. Cobrir virada, concorrência e rollback na mesma fronteira transacional; regressão das transferências já permitidas. Testes técnicos do hook cobrem destino permitido e preservam cancelamento/restauração; não atribuir gesto real ao harness.
4. Interface em pt-BR recompõe estado confirmado, mostra erro e envia um único evento por drop. Não alterar exclusão, auth ou temas nesta entrega.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.


## Entrega — 12/10/2026

Implementador `/root/implement_task042`, capacidade advanced; base `97726be5b0bbbca539e533685d3c78015110bf13`, árvore inicialmente limpa na branch `feat/ux`. TASK-041 `done` e integrada; SPEC-002 e SPEC-004 `ready`, sem bloqueios. Alterações restritas ao `write_scope`.

A API existente `return_to_backlog` aceita retry e compacta a origem sem escrever restituição na cota. O movimento com ordens completas reutiliza essa operação na mesma transação e whitelist; menu de retry oferece “Enviar ao backlog” via evento existente. O hook permite retry → backlog preservando sua restauração e processamento existentes. Nenhuma alteração em exclusão, auth ou temas.

| Aceite | Evidência e resultado |
| --- | --- |
| 1 — menu/arraste e cota | Três casos parametrizados em `task_movement_test.exs` inserem retry no início/meio/fim com consumo 3, verificam identidade, título, labels e posições consecutivas; retorno pelo menu acrescenta ao final e preserva consumo. Caso adicional cobre destino vazio com consumo zero. LiveView verifica recarga persistida. |
| 2 — rejeições atômicas | Casos de domínio preservam snapshot em payload incompleto/alheio/duplicado/origem antiga; repetição do movimento rejeitada. Teste explícito rejeita hoje → retry; regressão existente rejeita backlog → retry. Harness verifica ambas as proibições também no hook. |
| 3 — virada/concorrência/rollback | Drag enviado como hoje após virada é rejeitado sem reinterpretar origem; snapshot posterior recompõe retry. Menu normaliza dia e devolve sem restituir escolha vencida, conforme RN11/D18, atualizando expectativa histórica. Concorrência menu/drag usa conexões distintas e espera comprovada no lock PostgreSQL, preservando uma única tarefa e consumo 3. Constraint injetada após transferência força falha de ordenação e comprova rollback de movimento, normalização e criação do plano diário. Regressões das transferências anteriores permanecem verdes. |
| 4 — interface/hook | LiveView verifica ação em pt-BR, transferência de ambas as tarefas, labels, consumo 3, estado recarregado e erro sem anúncio de sucesso na repetição. Harness com SortableJS instalado verifica destino permitido, restauração dos mesmos nós antes do evento e emissão única por drop; mantém cenários de cancelamento por patch/desconexão, touch adiado e callback antigo. |

TDD: antes da implementação, cinco novos testes de domínio falharam por transição ainda rejeitada/ausência da falha transacional esperada, e o teste JS retry → backlog falhou na whitelist; setup e regressões existentes válidos. Após implementação, os 64 testes específicos então presentes passaram. Casos adicionais de concorrência, integração e virada entraram nos gates completos.

Comandos via RTK, após consulta das respectivas ajudas Mix: `mix test test/planner/task_movement_test.exs` (fase vermelha); `mix test test/planner/task_movement_test.exs test/planner/tasks_test.exs` (64 aprovados naquele estágio); `mix gettext.extract --merge --no-fuzzy` (mensagem pt-BR traduzida); `mix precommit` (**166 aprovados**); `mix ci` (**166 aprovados**, cobertura **93,37%**, Tasks **97,79%**, TaskLive.Index **98,36%**, limiar 70% preservado, Credo estrito sem achados, assets compilados e npm audit sem vulnerabilidades); `mix cmd node --test assets/test/task_drag.test.mjs` (**8 aprovados**); `git diff --check` aprovado.

Autoavaliação pelo fluxo de review: **approved no escopo técnico validado**, sem achados bloqueantes, sobre os nove arquivos de código/teste/catálogo locais contra a base acima. Autoavaliação não é revisão independente e não avança o marco de review. Cobertura total anterior informada pela TASK-041: 93,45%; atual 93,37%, preservando caminhos críticos testados e mínimo de 70%. Cobertura de linhas Elixir não mede ramos JavaScript ou layout. Harness usa DOM/timers mínimos e chamadas da dependência; não comprova gesto real mouse/touch, layout ou patches LiveView em navegador. Não houve validação visual em navegador nesta entrega.

Estado `in_review`: aguarda conferência operacional e commit de integração pelo coordenador. Sem staging, commit, publicação ou início de consumidoras pelo implementador.

### Conferência operacional — 12/10/2026

Coordenador `/root`: entrega integrada em `7c8903f` na branch `feat/ux`. Conferidos escopo dos arquivos, autoavaliação, gates relatados aprovados (166 testes Elixir, 8 JavaScript, cobertura 93,37%) e ausência de impedimentos. Sem reprodução de testes ou revisão independente. Estado anterior histórico; conclusão operacional libera TASK-043. Limites de navegador preservados.
