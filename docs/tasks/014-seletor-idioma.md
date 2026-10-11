---
id: "TASK-014"
status: "planned"
execution_level: "standard"
execution_rationale: "A capacidade deverá ser reavaliada quando o contrato desta evolução estiver definido."
specs: []
depends_on: ["TASK-008"]
provides: ["interface-locale-switching"]
consumes: ["verified-mvp"]
write_scope: ["lib/planner_web/controllers/locale_controller.ex", "lib/planner_web/router.ex", "lib/planner_web/components/layouts*", "priv/gettext/", "test/planner_web/"]
blockers: ["Fora do MVP; revisar escopo e contratos antes de iniciar a evolução."]
---

# 014 — Seletor de idioma

## Evolução futura

Definir idiomas adicionais e persistência da preferência antes de criar seletor.

Fora do MVP. Não executável nem gate da entrega mínima. O contrato de produto e o aceite serão definidos ao retomar esta etapa; não aplicar o comportamento futuro às specs atuais do MVP.
