---
id: "TASK-041"
status: "in_review"
execution_level: "standard"
execution_rationale: "Ajusta composição de cartões, menu e controles sem alterar eventos ou domínio."
specs: ["SPEC-004"]
depends_on: ["TASK-040"]
provides: ["task-menu-layout"]
consumes: ["persistent-task-drag"]
write_scope: ["lib/planner_web/live/task_live/index.ex", "assets/css/app.css", "test/planner_web/live/task_live_test.exs", "docs/tasks/041-ajustar-menu-tarefas.md"]
blockers: []
---

# 041 — Corrigir posição e espaço do menu de tarefas

## Objetivo e entradas

Corrigir os botões comprimidos e mover o menu de escolha para o canto esquerdo dos cartões. Ler SPEC-004 RN17/CA-004-14, design D18, `task_actions`/menu em TaskLive.Index e referências HEEx/interface/LiveView/testes. Sem scaffold; alterar a composição existente. O pedido de layout é um aceite específico, não uma revisão geral de UI.

## Aceite e limites

1. Em backlog/hoje/retry, acionador e menu ficam à esquerda, com abertura ancorada à esquerda, sem compressão dos controles de subir/descer/mover.
2. Títulos e labels longos não tomam o espaço reservado aos controles; concluir continua visível e alça conserva seu gesto/evento.
3. Testes estruturais e eventos existentes continuam válidos; registrar limite de validação visual. Não mudar ordenação, cota, autenticação ou adicionar ações ainda não implementadas.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.


## Entrega — 11/10/2026

Implementador `/root/implement_task041`; base local efetivamente encontrada `09b7f57bef62814f9257af3e73d14d5c7a469a27`, árvore inicialmente limpa. TASK-040 `done`, integrada no ancestral `367bf3555bc2b06e5ce90aedc2118e46e00986de`, com aceite humano registrado; SPEC-004 `ready`, sem bloqueios. Alterações limitadas aos quatro arquivos do `write_scope`.

Menu e alça passam para uma faixa própria no começo dos três cartões. O menu abre alinhado à esquerda, com largura explícita; os formulários de ordenação e a alça não encolhem. Texto e labels ficam em bloco separado, com quebra dos labels longos; concluir segue fora do menu. Eventos, IDs, domínio e hook preservados.

| Aceite | Evidência |
| --- | --- |
| 1 — menu esquerdo e controles | Novo teste estrutural verifica menu como primeiro elemento da faixa inicial em backlog/hoje/retry, `dropdown-start`, largura `w-56`, botões quadrados e formulários de ordenação `shrink-0`. Inspeção do CSS confirma faixa independente do texto. |
| 2 — textos longos, concluir e alça | Cenário usa títulos de 220 caracteres e label contínuo de 100 caracteres nas três listas. Verifica conteúdo em bloco separado, alça independente e concluir como filho direto do cartão de hoje. CSS permite quebra e altura variável dos labels. |
| 3 — regressão | 37 testes LiveView aprovados, incluindo movimento persistido, reordenação, conclusão, cota e rejeições existentes. Diff preserva eventos e não altera o hook nem acrescenta ações. |

TDD enxuto: teste novo falhou inicialmente na ausência da faixa inicial com menu primeiro (falha de intenção, setup válido); após implementação, arquivo completo passou. Ajuda de `test`, `precommit` e `ci` consultada antes da execução.

Validação: `mix test test/planner_web/live/task_live_test.exs` — **37 aprovados**; `mix precommit` — **158 aprovados**; `mix ci` — **158 aprovados**, cobertura total **93,45%** e TaskLive.Index **98,32%**, mínimo de 70% preservado, Credo estrito sem achados, assets compilados e npm audit sem vulnerabilidades; `git diff --check` aprovado. Comandos executados via RTK.

Autoavaliação pelo fluxo de review: **approved no escopo técnico validado**, sem achado bloqueante, comparando os três arquivos de código/teste locais contra a base acima; não é aprovação independente e não altera o marco de review. LiveViewTest verifica HTML/classes/eventos, não executa layout de navegador, mouse/touch ou viewport real. Não foi realizada inspeção visual no navegador; cobertura Elixir não mede CSS ou gestos. Hook não modificado, portanto teste JavaScript adicional não exigido.

Estado `in_review`: aguarda conferência operacional e commit de integração pelo coordenador. Sem staging, commit, publicação ou início de consumidoras pelo implementador.
