---
id: "TASK-049"
status: "planned"
execution_level: "advanced"
execution_rationale: "Futuro registro de valor exige autorização, idempotência e concorrência; contrato ainda pendente."
specs: ["SPEC-009"]
depends_on: ["TASK-048"]
provides: ["user-credit-grants"]
consumes: ["user-theme-switching"]
write_scope: ["lib/planner/", "priv/repo/migrations/", "test/planner/", "docs/tasks/049-creditos-usuarios.md"]
blockers: ["Fora do MVP de produção; definir autoridade, interface, unidade, limites, saldo inicial, reversão e auditoria de concessões na SPEC-009."]
---

# 049 — Adicionar créditos aos usuários após definição das regras

## Objetivo e limites

Reserva de evolução solicitada para adicionar créditos a usuários. O responsável confirmou em 11/10/2026 que créditos e loja vêm depois. Ler SPEC-009, SPEC-007 RN06 e design D19. Não iniciar implementação nem criar carteira vazia enquanto a spec estiver draft.

## Preparação necessária e aceite futuro

Definir quem concede, valores/unidade, processo/interface, saldo inicial, expiração, reversão e auditoria; então especificar testes de autorização, quantidade inválida, repetição idempotente, concorrência e rollback. Reavaliar nível e write_scope e decompor se necessário. Compras/preços/pagamentos exigem contratos e tarefas próprios; não fazem parte desta concessão inicial.

Concessões gratuitas de temas existentes permanecem disponíveis sem crédito. Esta tarefa não é dependência de release, runtime, aceite ou publicação do MVP de produção.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.
