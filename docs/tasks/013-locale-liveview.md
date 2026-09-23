---
id: "TASK-013"
status: "planned"
execution_level: "standard"
execution_rationale: "A capacidade deverá ser reavaliada quando o contrato desta evolução estiver definido."
specs: []
depends_on: ["TASK-008"]
provides: ["liveview-locale"]
consumes: ["verified-mvp"]
write_scope: ["lib/planner_web/live/locale_hook.ex", "test/planner_web/live/locale_hook_test.exs", "test/support/"]
blockers: ["Fora do MVP; revisar escopo e contratos antes de iniciar a evolução."]
---

# 013 — Locale variável em LiveView

## Evolução futura

Integrar montagem e reconexão quando houver preferência de idioma.

Fora do MVP. Não executável nem gate da entrega mínima. O contrato de produto e o aceite serão definidos ao retomar esta etapa; não aplicar o comportamento futuro às specs atuais do MVP.
