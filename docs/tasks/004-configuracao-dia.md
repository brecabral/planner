---
id: "TASK-004"
status: "planned"
execution_level: "standard"
execution_rationale: "A capacidade deverá ser reavaliada quando o contrato desta evolução estiver definido."
specs: []
depends_on: ["TASK-008"]
provides: ["user-timezone-storage"]
consumes: ["verified-mvp"]
write_scope: ["lib/planner/accounts/user.ex", "priv/repo/migrations/", "test/planner/accounts/user_test.exs"]
blockers: ["Fora do MVP; revisar escopo e contratos antes de iniciar a evolução."]
---

# 004 — Fuso configurável na conta

## Evolução futura

Definir política de escolha inicial e alteração de fuso; revisar migrations e conta após autenticação.

Fora do MVP. Não executável nem gate da entrega mínima. O contrato de produto e o aceite serão definidos ao retomar esta etapa; não aplicar o comportamento futuro às specs atuais do MVP.
