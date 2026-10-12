---
id: "TASK-041"
status: "planned"
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
