---
id: "TASK-017"
status: "planned"
execution_level: "standard"
execution_rationale: "A capacidade deverá ser reavaliada quando o contrato desta evolução estiver definido."
specs: []
depends_on: ["TASK-008"]
provides: ["timezone-settings"]
consumes: ["verified-mvp"]
write_scope: ["lib/planner/accounts.ex", "lib/planner_web/live/user_live/settings.ex", "priv/gettext/", "test/planner/accounts_test.exs", "test/planner_web/live/user_live/settings_test.exs"]
blockers: ["Fora do MVP; revisar escopo e contratos antes de iniciar a evolução."]
---

# 017 — Gerenciamento de fuso

## Evolução futura

Integrar o formulário de fuso à conta real conforme política temporal futura.

Fora do MVP. Não executável nem gate da entrega mínima. O contrato de produto e o aceite serão definidos ao retomar esta etapa; não aplicar o comportamento futuro às specs atuais do MVP.
