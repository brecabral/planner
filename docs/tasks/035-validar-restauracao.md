---
id: "TASK-035"
status: "planned"
execution_level: "standard"
execution_rationale: "Verifica recuperação em base isolada com procedimento definido e preservação de relações."
specs: ["SPEC-008"]
depends_on: ["TASK-033"]
provides: ["database-recovery-verified"]
consumes: ["production-runtime"]
write_scope: ["README.md", "docs/tasks/035-validar-restauracao.md"]
blockers: ["Definir destino/retenção de backup e ambiente isolado de restauração na SPEC-008."]
---

# 035 — Validar backup e restauração do MVP de produção

## Objetivo e entradas

Entregar SPEC-008 RN04/CA-008-03 com runtime definido. Ler contratos de proprietário/tarefas/temas e procedimento de operação do destino após decisão. Não criar serviço ou estratégia de backup sem contrato.

## Aceite e limites

1. Backup de dados de teste com duas contas, tarefas/labels/cota/histórico e temas é restaurado em banco isolado; comparar relações, contagens e preferências sem expor dados sensíveis.
2. Aplicação autenticada inicia sobre base restaurada; login e isolamento continuam válidos, respeitando expiração/revogação de tokens. Banco ativo não é sobrescrito.
3. Documentar exclusivamente no README o procedimento executado, destino/retenção aprovados e recuperação; registrar nesta tarefa evidência resumida e limites. Sem reset ou teste destrutivo no ambiente ativo.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.
