---
id: "TASK-015"
status: "planned"
execution_level: "advanced"
execution_rationale: "A capacidade deverá ser reavaliada quando o contrato desta evolução estiver definido."
specs: []
depends_on: ["TASK-008"]
provides: ["authenticated-user-scope"]
consumes: ["verified-mvp"]
write_scope: ["lib/planner/accounts*", "lib/planner_web/user_auth.ex", "lib/planner_web/live/user_live/", "lib/planner_web/controllers/user_session_controller.ex", "lib/planner_web/router.ex", "priv/gettext/", "test/planner/accounts*", "test/planner_web/"]
blockers: ["Fora do MVP; revisar escopo e contratos antes de iniciar a evolução."]
---

# 015 — Autenticação e contas reais

## Evolução futura

Definir entrada e criação de conta; planejar autenticação Phoenix sobre o User já existente sem sobrescrever schema ou dados do MVP.

Fora do MVP. Não executável nem gate da entrega mínima. O contrato de produto e o aceite serão definidos ao retomar esta etapa; não aplicar o comportamento futuro às specs atuais do MVP.
