---
id: "TASK-029"
status: "done"
execution_level: "standard"
execution_rationale: "Converte ações de teclado em permutações e recupera a lista após conflito."
specs: ["SPEC-002", "SPEC-004"]
depends_on: ["TASK-028"]
provides: ["planning-order-ui"]
consumes: ["planning-selection-ui", "reorder-today"]
write_scope: ["lib/planner_web/live/task_live/index.ex", "priv/gettext/", "test/planner_web/live/task_live_test.exs"]
blockers: []
---

# 029 — Adicionar subir e descer prioridades

## Entrada e limite

[SPEC-002](../specs/002-planejamento-diario.md) CA-002-04/06 e [SPEC-004](../specs/004-experiencia-e-acesso.md) RN03; consumir planning-selection-ui e reorder-today.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Adicionar controles acessíveis de subir/descer que enviem permutação completa ao contexto. Recarregar conjunto após conflito de outra aba. Não usar drag-and-drop como única operação.

## Aceite e teste de intenção

1. Teclado reordena três tarefas e recarga preserva ordem; extremidades não oferecem movimento impossível.
2. Conjunto antigo é rejeitado e atualizado sem alterar cota.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Entrega pelo implementador `/root/implement_mvp` em 04/10/2026; base `d3b7168` com TASK-028 integrada. Alvo da autoavaliação: alterações locais em `index.ex`, `task_live_test.exs`, POT e catálogo pt_BR; este registro acompanha a entrega. Sem staging/commit. Conferência e integração pelo coordenador pendentes; não constitui revisão independente nem altera seu marco.

- Critério 1: teste LiveView seleciona três tarefas, sobe a terceira, desce a primeira, verifica ordem efetiva dos filhos no DOM e posições numeradas, recompõe o painel e confirma persistência. Confere botões desabilitados nas extremidades e cota inalterada. Controles são formulários/botões nativos, com nomes acessíveis incluindo o título, foco visível, `phx-disable-with` e foco útil no cabeçalho estável de hoje. Layout usa `flex-wrap`. Teclado físico, foco executado pelo cliente e viewport 360px não foram exercitados em navegador; inspecionados no template.
- Critério 2: outra sessão devolve a primeira tarefa antes da reordenação; o conjunto guardado na sessão é recusado pelo contexto e a interface recompõe a ordem atual, backlog e cota (duas escolhas). Nova tentativa com conjunto atualizado sucede, preserva cota e remove o erro.
- Entrada forjada: IDs alheios/malformados, proprietário arbitrário, direção inválida, movimento além da borda e evento sem parâmetros são rejeitados, sem mover tarefas próprias/alheias nem consumir escolhas. O servidor constrói a permutação completa a partir do snapshot da sessão e passa o usuário resolvido ao contexto; não relê antes de construir a permutação, preservando a detecção de conjunto antigo.
- TDD: primeira execução teve 12 testes existentes aprovados e 3 novos falhando por controles/evento ausentes. Após implementar e traduzir, 15 testes LiveView aprovados.
- Gates: `mix precommit` e `mix ci` aprovados com 121 testes, Credo estrito sem achados, cobertura total 91,60% e Index 97,22% (anterior: 91,14%/96,34%). Limiar de 70% preservado. Extração e mesclagem Gettext pt_BR atualizadas; `git diff --check` aprovado.
- Autoavaliação segundo fluxo de review: critérios funcionais atendidos, sem achados bloqueantes. Rejeição atômica/concorrência são fornecidas e testadas pelo contrato integrado de TASK-024; não houve alteração do contexto. Comandos compartilham tratamento de falhas de persistência já exercitado pela TASK-028. Coleções continuam em streams; apenas IDs do conjunto limitado de hoje são mantidos para construir a permutação correspondente à tela.
- Alterações operacionais preexistentes preservadas. TASK-030 não iniciada; aguarda liberação após integração.

### Conferência operacional — 04/10/2026

Coordenador `/root`: registro e resumo conferidos superficialmente, sem impedimentos. Gates locais relatados aprovados: 121 testes, cobertura 91,60%. Entrega integrada na branch `feat/mvp` em `8a23edf`; TASK-030 liberada. Sem revisão independente ou verificação de CI remoto. Validação visual permanece para a etapa de acessibilidade.
