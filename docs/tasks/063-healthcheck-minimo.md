---
id: "TASK-063"
status: planned
execution_level: standard
execution_rationale: "Integra rota mínima ao pipeline HTTP e ao release, preservando HTTPS e comprovando ausência de dados e dependências na resposta."
specs: ["SPEC-008"]
depends_on: ["TASK-062", "TASK-014"]
provides: ["minimal-http-healthcheck"]
consumes: []
write_scope: ["lib/planner_web/router.ex", "lib/planner_web/controllers/health_controller.ex", "config/prod.exs", "test/planner_web/controllers/health_controller_test.exs", "assets/e2e/smoke.spec.ts", "README.md", "docs/tasks/063-healthcheck-minimo.md"]
blockers: []
---

# 063 — Expor healthcheck HTTP mínimo

## Objetivo e entradas

Implementar SPEC-008 RN10/CA-008-10: sinal público de processo HTTP respondendo, sem informações de projeto ou diagnóstico. Consultar router, endpoint, `force_ssl`, teste E2E público e referências Phoenix/testes. TASK-062 serializa README; TASK-014 serializa router, testes web e E2E. Não há requisito funcional de idiomas para a rota.

## Entrega e aceite

1. `GET /health` retorna 200 e somente `ok`, `text/plain` e `Cache-Control: no-store`; HEAD retorna 200 sem corpo. Sem HTML, JSON diagnóstico, versão, nome do app, ambiente, commit, métricas, detalhes de dependências ou valores fornecidos em query/cookies.
2. Rota fora do pipeline de sessão/autenticação, sem consulta ao Repo ou Mailer e sem `Set-Cookie`. Cookie inválido ou usuário anônimo não muda a resposta. Usar controller/roteamento Phoenix existentes, sem biblioteca, dashboard ou endpoint de debug.
3. Excluir somente `/health` do redirecionamento SSL para a sondagem HTTP interna; preservar proteção das demais rotas e ausência de `/dev` em prod. Não configurar Fly ou publicar.
4. Testes de controller verificam status, corpo, headers, HEAD, ausência de cookie e independência de consultas externas. Acrescentar verificação automatizada ao E2E público do release, sem dados de conta e sem requisições externas. Não parar o banco do runner para provar o contrato.
5. README explica que esse endpoint não comprova disponibilidade do banco ou Resend e descreve status/caminho para o responsável configurar seu monitor externo. Não criar readiness de banco neste escopo.

## Execução e conclusão

Aplicar TDD enxuto, referências e ajuda Mix. Executar precommit, qualidade/cobertura mínima de 70% e suíte E2E completa conforme README. Registrar autoavaliação pelo fluxo de review, evidências e limites; revisão independente só se solicitada. Conferência operacional e integração precedem `done`; impedimentos seguem `docs/blocks`.

Planejada em 19/10/2026; não implementada, aguardando dependências.
