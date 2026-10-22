---
id: "TASK-059"
status: done
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

Implementada em 17/10/2026 sobre a base `9e3dc7c`; TASK-056 já integrada. Entrega local encaminhada ao coordenador para conferência operacional e commit; não há aprovação independente nem publicação remota.

| Aceite | Evidência e resultado |
| --- | --- |
| 1 — Marca, título e A fazer | Layout compartilhado usa Just Three, `hero-bars-3` e link `/`; título do navegador atualizado. Painel remove somente o título redundante e conserva Nova tarefa. Testes de home, páginas públicas, locale e LiveView verificam identidade, títulos/vazios, menus de retry/devolução e mensagens. Tarefa “Planner Backlog” e label “Backlog” permanecem intactas, com cota e transferências exercitadas. |
| 2 — Controles por ícone | Tema usa `hero-puzzle-piece`, botão com nome traduzido/estado de abertura e opções inicialmente fechadas. Saída usa `hero-arrow-right-start-on-rectangle`, nome Sair e rota/método existentes. Hook fecha por novo acionamento, clique externo ou Escape (devolvendo foco); sucesso fecha, falha conserva opções/seleção confirmada; espera impede repetição. Testes de hook e `theme_test.exs` preservam erros, desconexão, persistência e isolamento. |
| 3 — Navegador e regressões | Suíte E2E completa: 9/9 cenários aprovados. Marca em login, `/join`, `/users/register`, confirmação e painel; navegação da marca, ausência do título redundante, Nova tarefa, teclado/menu, paleta computada em ambas as direções, patches/recarga, logout e segunda conta. Centros dos controles alinhados com tolerância de 1 px em 320 e 1280 px, inclusive com `/tasks/new` aberto; áreas equivalentes no painel e ausência de rolagem horizontal. |
| 4 — Gates e autoavaliação | `just precommit`: 246 testes aprovados. `just ci`: 246 testes, Credo sem achados, assets, testes JavaScript, tooling e auditoria npm aprovados. Cobertura agregada dos relatórios HTML: 93,84% (1005 linhas cobertas/1071 instrumentadas), acima de 70%; TaskLive.Index 98,71%. `git diff --check` sem erros. |

### Autoavaliação

Implementador `task059`, alvo: alterações locais dos 17 arquivos desta tarefa sobre `9e3dc7c`, seguindo o fluxo de review. Conclusão técnica: `approved` em autoavaliação, sem revisão independente ou avanço do marco em `docs/review.md`. Escopo conferido: componentes/layout, home, painel, hook, catálogo pt-BR/POT e testes web/JS/E2E. Nenhuma alteração em domínio, autenticação, paletas, códigos de temas ou seleção de idioma.

Evidências E2E finais em `tmp/e2e/run-brmwsUod/`: relatório, logs e `exit-code.txt` igual a 0, incluindo coleta e limpeza. Primeira execução (`tmp/e2e/run-oI00MH4u/`) revelou que o flash de confirmação interceptava o clique inicial no cenário de tema; o teste passou a fechar a notificação pelo controle existente antes de interagir. Reexecução completa passou sem retries, skips ou cliques forçados. Na fase vermelha, testes de identidade/acionador falharam pelo comportamento ausente; execução isolada do teste de locale também expôs sua dependência do arquivo fixture, depois carregada normalmente pela suíte web/completa.

Limites: falha de persistência é coberta por rejeição real no banco em ExUnit e pelo hook; não foi introduzido mecanismo de falha artificial no navegador. Cobertura de linhas não mede todos os estados JavaScript; estes têm testes próprios e E2E. Arquivos de catálogo tiveram referências de origem sincronizadas após formatação, sem mudança adicional de mensagens. Commit e estado `done` ficam para a conferência do coordenador; TASK-013/014 não iniciadas nesta entrega.

### Conferência operacional — 17/10/2026

Coordenador `/root`: entrega integrada na base local em `65b7698`, após conferência do registro, arquivos do escopo, autoavaliação e gates relatados aprovados (246 testes, cobertura 93,84%, E2E 9/9), sem impedimentos. Conclusão operacional registrada após commit bem-sucedido; não houve reprodução de testes pelo coordenador, revisão independente ou CI remoto nesta rodada.

TASK-013 fica elegível, com TASK-045 e TASK-059 concluídas e integradas. Por solicitação do responsável para parar após a tarefa atual, a rodada termina nesta entrega; TASK-013 e TASK-014 permanecem planejadas, sem implementação de troca de idiomas. Sem publicação remota.
