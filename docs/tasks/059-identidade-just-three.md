---
id: "TASK-059"
status: planned
execution_level: standard
execution_rationale: "Integra marca, controles de layout, interação do tema e regressões E2E com contratos existentes e comportamento definido."
specs: ["SPEC-004", "SPEC-007"]
depends_on: ["TASK-056"]
provides: ["just-three-visual-identity"]
consumes: ["navbar-theme-selection", "e2e-authenticated-suite"]
write_scope: ["lib/planner_web/components/", "lib/planner_web/controllers/page_html/", "lib/planner_web/controllers/page_controller.ex", "lib/planner_web/live/", "assets/css/app.css", "assets/js/account_theme.js", "assets/js/account_theme.test.mjs", "assets/e2e/", "priv/gettext/", "test/planner_web/", "docs/tasks/059-identidade-just-three.md"]
blockers: []
---

# 059 — Aplicar identidade Just Three e controles por ícone

## Objetivo e limites

Entregar SPEC-004 RN21–RN25/CA-004-17–19 e SPEC-007 RN09–RN10/CA-007-08. Uma única tarefa produz a marca e os controles compartilhados, evitando conflito entre layout, painel e testes. Aplicar “A fazer” consistentemente na interface pt-BR, preservando conteúdo do usuário. A engrenagem de idioma será produzida pela TASK-014 após esta entrega. Não alterar cota, autenticação, catálogo, códigos de temas, dados, nomes técnicos ou paletas.

## Contexto de entrada

- PRD: identidade de 17/10/2026; design D22; specs e aceites acima, além de SPEC-007 RN03–RN08/CA-007-02–07 para persistência, falhas e isolamento.
- Layout em `lib/planner_web/components/layouts.ex`, título em `components/layouts/root.html.heex`, home em `controllers/page_html/home.html.heex`, telas em `live/user_live/`, painel em `live/task_live/index.ex`.
- Hook e testes em `assets/js/account_theme.js` e `account_theme.test.mjs`; E2E em `assets/e2e/smoke.spec.ts` e `authenticated.spec.ts`; regressões de tema em `test/planner_web/theme_test.exs`.
- TASK-056 integrada fornece fixtures e suíte autenticada; TASK-054 ancestral fornece seleção na navbar. Ambas estão done na base deste planejamento. Consultar referências HEEx, formulários, LiveView, interop JS, interface, Gettext e testes antes de modificar essas áreas.

## Entrega e aceite

1. Marca Just Three nas superfícies especificadas, três traços no símbolo e remoção apenas do título redundante acima de Hoje. Preservar Nova tarefa e conteúdo do usuário. Traduzir backlog como A fazer conforme RN25/CA-004-19 e cobrir títulos, menus e mensagens por testes versionados.
2. Saída por ícone mantendo método/rota e nome acessível; tema por quebra-cabeça abre e fecha opções conforme RN09. Teclado, seleção atual, estado de gravação e falha seguem contrato.
3. Atualizar testes versionados de estrutura/LiveView e hook conforme comportamento afetado. E2E deve cobrir marca em páginas públicas e autenticadas, ausência do título redundante, funcionamento de Nova tarefa, abertura/fechamento do menu, alternância real de paleta, persistência e logout pelo novo ícone. Conferir alinhamento dos centros dos controles em 320 e 1280 px no navegador, com tolerância de 1 px. Preservar cobertura de erro e isolamento; não substituir asserções de CSS efetivo por apenas `data-theme`.
4. Autoavaliação pelo fluxo de review, suíte E2E completa e `mix precommit` conforme README, mantendo cobertura mínima de 70%. Testes exclusivamente na suíte versionada; sem auditoria geral de acessibilidade ou testes manuais adicionais.

## Evidências e progresso

Planejada em 17/10/2026; nenhuma implementação ou validação de código realizada nesta rodada. Registrar commit, cenários/testes executados, resultado dos gates e limitações antes da conferência de integração. Dependências concluídas e specs ready tornam a tarefa elegível; planejamento não significa entrega.
