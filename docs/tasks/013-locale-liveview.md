---
id: "TASK-013"
status: planned
execution_level: advanced
execution_rationale: "Integra preferência, isolamento por usuário, ciclo HTTP/LiveView e preservação de estado durante troca de locale."
specs: ["SPEC-001"]
depends_on: ["TASK-059", "TASK-045"]
provides: ["liveview-locale"]
consumes: ["just-three-visual-identity", "private-user-planning"]
write_scope: ["lib/planner/accounts/", "lib/planner/accounts.ex", "lib/planner_web/", "priv/repo/migrations/", "test/planner/", "test/planner_web/", "test/support/", "docs/tasks/013-locale-liveview.md"]
blockers: ["Confirmar persistência e precedência da preferência na SPEC-001."]
---

# 013 — Persistir preferência e resolver locale HTTP/LiveView

## Objetivo, contrato e aceite

Produzir contrato único de resolução/alteração de locale para HTTP e LiveView, validação da lista permitida (`pt_BR` e `en`), isolamento e persistência que o responsável escolher. Definir operação consumida pela TASK-014 e registrar seu contrato no arquivo da tarefa antes da integração. Não produzir seletor nem catálogos; a cobertura visual completa pertence à consumidora.

Aceite: SPEC-001 RN07–RN10/CA-I06 e preservação pública de CA-I08, com testes versionados para locale inválido, falha de persistência, processos independentes, montagem/reconexão e precedência definida na spec final. Preservar rascunhos e dados ao preparar a atualização de locale. Incluir resolução não autenticada e conservação da escolha entre login, `/join` e `/users/register`, recarga e reconexão. Não criar migration até a decisão sobre persistência; se a escolha for conta, a estrutura de preferência pertence exclusivamente a esta tarefa.

## Contexto e limites

Ler evolução de 17/10/2026 na SPEC-001, SPEC-004 RN25, design D23, referências Gettext, LiveView, HEEx, formulários e testes; consultar Elixir/Ecto se houver persistência. Layout, root e painel atuais são entradas; a TASK-059 fornece marca e controles de tema/saída. TASK-056 ancestral fornece suíte E2E autenticada. As dependências precisam estar integradas antes da execução.

Retomada autorizada em 17/10/2026 substitui o adiamento genérico anterior. Ainda planejada, não executável: spec draft e decisão de persistência/precedência pendente. Não implementar solução parcial presumindo as respostas. Serialização 059 → 013 → 014 evita disputa nos layouts, painel e testes.

## Validação e evidências

TDD enxuto na suíte versionada, autoavaliação pelo fluxo de review, `mix precommit`, cobertura mínima de 70% e E2E completo conforme README. Registrar commit, contratos entregues, resultados e limitações; não usar testes avulsos ou avaliação manual para complementar aceite. Nenhuma implementação ou validação de código nesta rodada documental.
