---
id: "TASK-065"
status: planned
execution_level: advanced
execution_rationale: "Evita exposição de tokens entre logging HTTP, LiveView e headers, sem quebrar diagnóstico ou autenticação gerada."
specs: ["SPEC-005"]
depends_on: ["TASK-064"]
provides: ["auth-token-log-redaction"]
consumes: []
write_scope: ["config/config.exs", "config/prod.exs", "lib/planner_web/endpoint.ex", "lib/planner_web/router.ex", "lib/planner_web/plugs/", "lib/planner_web/telemetry.ex", "test/planner_web/", "assets/e2e/smoke.spec.ts", "README.md", "docs/tasks/065-proteger-tokens-logs.md"]
blockers: []
---

# 065 — Evitar exposição de magic links em logs e Referer

## Objetivo e diagnóstico

Implementar SPEC-005 RN27/CA-005-22. A inspeção de planejamento identificou que `Phoenix.Logger.phoenix_endpoint_start/4` registra `conn.request_path`; a rota `/users/log-in/:token` inclui o segredo no caminho. Filtrar somente parâmetros não cobre esse registro. O Endpoint também instala `Phoenix.LiveDashboard.RequestLogger` fora da condição de desenvolvimento. Esta tarefa não pressupõe exploração ou vazamento remoto comprovado.

Ler Endpoint, Router, Telemetry, login/confirmação e implementação instalada do logger Phoenix, transport e LiveView. Consultar referências Phoenix/LiveView/testes. TASK-064 serializa endpoint, testes e docs. Não alterar dependências, protocolo do magic link ou domínio.

## Entrega e aceite

1. Usar opções/extensões existentes de logging para omitir/mascarar o segmento sensível e parâmetros de token/sessão nos caminhos de autenticação, inclusive mount/reconexão de LiveView. Preservar logs úteis das demais rotas e identificador/status da requisição. Não reescrever URL antes do roteamento nem desligar logging global.
2. Habilitar RequestLogger somente em desenvolvimento. Não abrir dashboard/mailbox em prod. Aplicar `Referrer-Policy: no-referrer` nas páginas/rotas de autenticação, preservando os demais headers seguros.
3. Testes versionados com CaptureLog e sentinelas cobrem GET confirmação, POST login, inválido/expirado e conexões/eventos LiveView. Verificar ausência do token em caminho e params tanto no nível info quanto com debug habilitado para o caso testado. Não imprimir secrets nos próprios testes.
4. Verificar headers e funcionamento de confirmação/login/logout, CSRF e proteção de origem sem relaxar configurações. Executar E2E completo e acrescentar asserção do header no cenário público pertinente. Não alegar proteção de logs gerados fora do app; README delimita logs Fly/proxy/provedor como operação externa.

## Execução e conclusão

TDD enxuto, referências e ajuda Mix; precommit, qualidade com cobertura mínima de 70% e E2E completo conforme README. Registrar autoavaliação pelo fluxo de review, resultados e limites, sem aprovação independente presumida. Integração/conferência operacional precedem `done`; impedimentos seguem `docs/blocks`.

Planejada em 19/10/2026; nenhuma correção de código ou auditoria completa executada nesta rodada.
