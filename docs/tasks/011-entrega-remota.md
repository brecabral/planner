---
id: "TASK-011"
status: "planned"
execution_level: "standard"
execution_rationale: "A capacidade deverá ser reavaliada quando o contrato desta evolução estiver definido."
specs: []
depends_on: ["TASK-008"]
provides: ["release-scaffold"]
consumes: ["verified-mvp"]
write_scope: ["lib/planner/release.ex", "rel/", "Dockerfile", ".dockerignore", "README.md"]
blockers: ["Fora do MVP; revisar escopo e contratos antes de iniciar a evolução."]
---

# 011 — Release de produção

## Evolução futura

Gerar e validar empacotamento de produção quando houver destino de entrega.

Fora do MVP. Não executável nem gate da entrega mínima. O contrato de produto e o aceite serão definidos ao retomar esta etapa; não aplicar o comportamento futuro às specs atuais do MVP.
