---
id: "TASK-044"
status: "planned"
execution_level: "standard"
execution_rationale: "Integra operação pronta com confirmação e atualização de streams e contadores."
specs: ["SPEC-004", "SPEC-002"]
depends_on: ["TASK-043"]
provides: ["pending-task-deletion-ui"]
consumes: ["delete-pending-task"]
write_scope: ["lib/planner_web/live/task_live/", "priv/gettext/", "test/planner_web/live/task_live_test.exs", "docs/tasks/044-excluir-pendencias-interface.md"]
blockers: []
---

# 044 — Confirmar e excluir pendências pelo painel

## Objetivo e entradas

Implementar SPEC-004 RN19/CA-004-16 consumindo a operação da TASK-043. Ler painel/menu, diálogos existentes e referências HEEx/formulários/LiveView/Gettext/testes. Sem scaffold; reutilizar composição do painel.

## Aceite e testes

1. Menu de cada pendência oferece excluir com confirmação explícita da remoção definitiva da tarefa identificada; cancelar não envia mutação. Histórico não oferece ação.
2. Confirmar chama domínio com usuário do servidor; eventos forjados para concluída/ID alheio não removem dados. Sucesso atualiza listas, contadores e cota somente após persistência.
3. Falha mantém estado e informa erro pt-BR; conflito recupera snapshot. Testar cancelar/confirmar, cada origem e ausência no histórico, sem prometer validação de diálogo real por LiveViewTest.
4. Não adicionar desfazer, reabertura ou exclusão de labels. Preservar menus à esquerda e cadastro com rascunho.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.
