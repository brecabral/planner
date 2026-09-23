---
id: "TASK-008"
status: "planned"
execution_level: "standard"
execution_rationale: "Consolida critérios do MVP local e evidências de comportamento e cobertura."
specs: ["SPEC-001", "SPEC-002", "SPEC-003", "SPEC-004", "SPEC-005", "SPEC-006"]
depends_on: ["TASK-032"]
provides: ["verified-mvp"]
consumes: ["accessible-planner-ui", "default-user", "github-quality-gate"]
write_scope: ["docs/tasks/008-aceite-mvp.md", "docs/specs/"]
blockers: []
---

# 008 — Executar o aceite do MVP mínimo

## Objetivo e entrada

Conferir PRD CA01–CA13 e CA15 e as evidências das produtoras. Executar fluxo no ambiente de teste com usuário padrão, sem depender de login, fuso, idioma alternativo, publicação ou backup. Não implementar correções aqui; devolvê-las à produtora. Não reabrir o gate humano já aceito.

## Aceite

1. Cadastro com labels → selecionar → devolver ao backlog → selecionar → concluir → histórico funciona em pt-BR.
2. Devolução restitui uma vez; conclusão não restitui. Virada é observada após recarga e comandos antigos revalidam data.
3. Reinício mantém dados do usuário padrão, labels e cota. Matriz de critérios aponta evidências; precommit e CI passam com pelo menos 70% de cobertura.

## Evidência e revisão

Pendentes. Registrar teste de intenção, precommit e CI com cobertura mínima de 70%, revisor independente, alvo/base, critérios, achados e integração.
