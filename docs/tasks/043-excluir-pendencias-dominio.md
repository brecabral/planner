---
id: "TASK-043"
status: "planned"
execution_level: "advanced"
execution_rationale: "Remoção definitiva exige atomicidade, compactação e disputa com conclusão e virada."
specs: ["SPEC-002", "SPEC-003", "SPEC-006"]
depends_on: ["TASK-042"]
provides: ["delete-pending-task"]
consumes: ["retry-to-backlog"]
write_scope: ["lib/planner/tasks.ex", "lib/planner/tasks/", "priv/repo/migrations/", "test/planner/", "docs/tasks/043-excluir-pendencias-dominio.md"]
blockers: []
---

# 043 — Excluir pendências preservando histórico e cota

## Objetivo e entradas

Implementar somente a operação de domínio de exclusão (SPEC-002 RN12–RN13/CA-002-13–14). Ler Tasks, TaskLabel, UserTransaction, constraints/FKs vigentes e referências Elixir/Ecto/testes. Usar recurso existente; nenhuma geração de CRUD. Nova migration somente se indispensável para o contrato, preservando migrations aplicadas e dados existentes.

## Aceite e testes

1. Pendência própria removida de backlog/retry/hoje deixa posições consecutivas; vínculos somem, labels permanecem. Hoje restitui exatamente uma escolha; demais listas não alteram consumo.
2. Concluída/ID ausente/alheio/repetido retornam indisponível sem revelar proprietário ou alterar cota. Repetir não restitui novamente.
3. Após virada, pendência vencida é retry e sua exclusão não reduz cota nova. Concorrência com excluir/devolver/concluir serializa e preserva invariantes; concluir vencedor mantém histórico não excluível.
4. Falha provocada de persistência reverte tarefa, vínculos, posições, cota e normalização. Testes de domínio verificam efeitos observáveis. Não expor botão antes da consumidora TASK-044.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.
