---
id: "TASK-045"
status: "planned"
execution_level: "advanced"
execution_rationale: "Integra identidade em HTTP, LiveView e comandos, com risco transversal de acesso entre usuários."
specs: ["SPEC-005", "SPEC-002", "SPEC-004", "SPEC-006"]
depends_on: ["TASK-015"]
provides: ["private-user-planning"]
consumes: ["authenticated-user-scope"]
write_scope: ["lib/planner/", "lib/planner_web/", "config/config.exs", "config/dev.exs", "priv/repo/seeds.exs", "priv/gettext/", "test/", "README.md", "docs/tasks/045-isolar-planejamento-autenticado.md"]
blockers: []
---

# 045 — Proteger dashboard e isolar dados por conta

## Objetivo e entradas

Aplicar SPEC-005 RN10–RN13/CA-005-09–11 a todas as entradas do planejamento; SPEC-004 RN20. Ler scope/auth da TASK-015, router, TaskLive.Index/Form, Tasks/Labels/UserTransaction, seeds e referências Phoenix/LiveView/Ecto/testes. Consumir o scaffold, não executar phx.gen.auth novamente.

## Aceite e testes

1. `/` leva visitante a `/users/log-in` e autenticado a `/tasks`; login de autenticado também leva a `/tasks`. Link concluído abre dashboard; logout retorna ao login, sem redirect externo controlado por params.
2. `/tasks` e `/tasks/new` exigem sessão no HTTP e no mount/reconexão LiveView. Derivar usuário de current_scope no servidor; remover fallback público/auto-criação default em todos os ambientes. Preservar legado isolado e não reassociar dados.
3. A/B têm catálogo, tarefas, histórico e cotas independentes. Testes exercitam leitura, cadastro, labels alheias, seleção, retorno, retry → backlog, reordenação, arraste, conclusão e exclusão com IDs forjados, inclusive formulário acessado diretamente.
4. Fixture autenticada adapta testes do painel sem perder regressões funcionais. Seeds não criam acesso compartilhado em produção. Atualizar README para descrever autenticação implementada, sem antecipar instruções de e-mail ainda não entregues pela TASK-046.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.
