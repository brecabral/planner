---
id: "TASK-014"
status: planned
execution_level: standard
execution_rationale: "Consome resolução de locale definida e integra catálogos completos, controles compartilhados e cenários de navegador."
specs: ["SPEC-001"]
depends_on: ["TASK-013"]
provides: ["interface-locale-switching"]
consumes: ["liveview-locale", "just-three-visual-identity", "e2e-authenticated-suite"]
write_scope: ["lib/planner_web/", "priv/gettext/", "assets/js/", "assets/e2e/", "assets/css/app.css", "test/planner_web/", "docs/tasks/014-seletor-idioma.md"]
blockers: ["Confirmar idiomas iniciais e persistência da preferência na SPEC-001."]
---

# 014 — Traduzir toda a interface e oferecer idioma pela engrenagem

## Objetivo, contrato e aceite

Produzir a engrenagem entre tema e saída, as opções de idioma e a tradução completa dos textos da aplicação. Consumir a operação da TASK-013 sem criar persistência paralela. Atualizar também textos computados em montagem, flashes e validações já visíveis; não limitar a troca aos templates estáticos.

Aceite: SPEC-001 RN04–RN08/CA-I04–I07. Testes versionados de catálogos, LiveView e E2E devem cobrir todos os idiomas aprovados, formulários com rascunho/erro, menus, confirmações, plurais, estados vazios, títulos e nomes acessíveis, patches, recarga, reconexão e falhas. Verificar ordem tema → configurações → sair e centros alinhados (tolerância 1 px) em 320/1280 px. Manter regressões de tema e logout. Não traduzir conteúdo do usuário ou renomear Just Three.

## Contexto e limites

Ler evolução de 17/10/2026 na SPEC-001, SPEC-004 RN25, design D23, referências Gettext, LiveView, HEEx, formulários e testes; consultar Elixir/Ecto se houver persistência. Layout, root e painel atuais são entradas; a TASK-059 fornece marca e controles de tema/saída. TASK-056 ancestral fornece suíte E2E autenticada. As dependências precisam estar integradas antes da execução.

Retomada autorizada em 17/10/2026 substitui o adiamento genérico anterior. Ainda planejada, não executável: spec draft e decisões explícitas pendentes. Não implementar solução parcial presumindo as respostas. Serialização 059 → 013 → 014 evita disputa nos layouts, painel e testes.

## Validação e evidências

TDD enxuto na suíte versionada, autoavaliação pelo fluxo de review, `mix precommit`, cobertura mínima de 70% e E2E completo conforme README. Registrar commit, contratos entregues, resultados e limitações; não usar testes avulsos ou avaliação manual para complementar aceite. Nenhuma implementação ou validação de código nesta rodada documental.
