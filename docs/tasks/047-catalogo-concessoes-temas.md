---
id: "TASK-047"
status: "planned"
execution_level: "advanced"
execution_rationale: "Modela propriedade única, preparação de contas existentes/futuras e preferência autorizada transacional."
specs: ["SPEC-007", "SPEC-005"]
depends_on: ["TASK-046"]
provides: ["user-theme-entitlements"]
consumes: ["local-magic-link-testing"]
write_scope: ["lib/planner/themes.ex", "lib/planner/themes/", "lib/planner/accounts.ex", "lib/planner/accounts/user.ex", "priv/repo/migrations/", "priv/repo/seeds.exs", "test/planner/", "test/support/", "docs/tasks/047-catalogo-concessoes-temas.md"]
blockers: []
---

# 047 — Criar catálogo, concessões e preferência de temas

## Objetivo e entradas

Implementar SPEC-007 RN01–RN03/RN06 e CA-007-01/03. Ler design D19, Accounts/cadastro autenticado, referências Ecto/Elixir/testes. Recurso novo: contexto pequeno Themes com catálogo/concessões e referência de preferência no usuário; usar migration aditiva, sem gerar CRUD ou interfaces de loja. Nenhum gerador de domínio específico é necessário; não duplicar Accounts/User.

## Aceite e testes

1. Catálogo contém códigos estáveis planner/planner_dark. Contas existentes e futuras recebem ambos com origem gratuita e unicidade usuário/tema; repetir preparação e tentativas concorrentes não duplicam.
2. Preferência inicial é planner; operação autenticada só aceita tema concedido e proprietário do servidor. Tema desconhecido/não concedido e user_id forjado não alteram preferência nem propriedade.
3. Falha transacional não deixa cadastro/concessão/preferência parcial. Migration/backfill preserva contas e dados legados; legado permanece sem login. Testar bases novas e com contas já criadas.
4. Não introduzir carteira, saldo, preços, endpoint de compra ou código de pagamentos. A relação de concessão é a base suficiente para propriedade futura. Integração CSS/seletor é exclusiva da TASK-048.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.
