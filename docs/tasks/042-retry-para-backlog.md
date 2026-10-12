---
id: "TASK-042"
status: "planned"
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
