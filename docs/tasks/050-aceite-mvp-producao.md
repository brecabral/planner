---
id: "TASK-050"
status: "planned"
execution_level: "advanced"
execution_rationale: "Consolida contratos transversais de autenticação, isolamento, tarefas e recuperação no artefato final."
specs: ["SPEC-002", "SPEC-004", "SPEC-005", "SPEC-007", "SPEC-008"]
depends_on: ["TASK-035"]
provides: ["verified-production-candidate"]
consumes: ["database-recovery-verified"]
write_scope: ["test/", "docs/specs/", "README.md", "docs/tasks/050-aceite-mvp-producao.md"]
blockers: []
---

# 050 — Validar o candidato ao MVP de produção

## Objetivo e entradas

Verificar CA17–CA19/CA16 do PRD e SPEC-008 RN05/CA-008-04 no candidato de release, antes de publicação. Carregar contratos/registro das entregas 041–048, 015, 011, 033 e 035 e referências testes/Mix. Não presumir prontidão a partir da documentação ou do antigo aceite local.

## Aceite e evidências

1. Reproduzir fluxo de duas contas: cadastro e entrega do link, entrada/home/logout, isolamento de todos os comandos e preservação do legado. Login, tokens e dados persistem/revogam conforme contrato após reinício.
2. Comprovar retry → backlog, exclusão de pendências com cota/histórico corretos e seleção persistida de ambos os temas. Cobrir regressões e evidências de falha/concorrência das tarefas produtoras.
3. Compilar/validar artefato e gates; relacionar testes aos IDs de aceite e registrar resultado da restauração, domínio/configuração homologados e limitações de navegador. Não criar avaliação humana de UI obrigatória nem supor publicação.
4. Falha exige correção com evidência antes de encerrar. Revisão independente apenas se solicitada. Não implementar novas features nesta consolidação; encaminhar falta de contrato ao planejador.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.
