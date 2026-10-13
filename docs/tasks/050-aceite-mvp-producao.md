---
id: "TASK-050"
status: "planned"
execution_level: "advanced"
execution_rationale: "Consolida contratos transversais de autenticação, isolamento, tarefas e persistência no artefato local final."
specs: ["SPEC-002", "SPEC-004", "SPEC-005", "SPEC-007", "SPEC-008"]
depends_on: ["TASK-011"]
provides: ["verified-local-release"]
consumes: ["release-scaffold"]
write_scope: ["test/", "docs/specs/", "README.md", "docs/tasks/050-aceite-mvp-producao.md"]
blockers: []
---

# 050 — Validar o código Phoenix e o release local

## Objetivo e entradas

Verificar CA17–CA19/CA16 do PRD e SPEC-008 RN02–RN05/CA-008-02–04 no release local. Carregar contratos/registro das entregas 041–048, 015, 051 e 011, Mailer/configurações existentes e referências testes/Mix. Não presumir prontidão a partir da documentação ou do antigo aceite local.

## Aceite e evidências

1. Conferir a regressão de falha de envio e recuperação do cadastro (CA-005-13/TASK-051). Reproduzir fluxo de duas contas: cadastro e captura do link com adapter local/de teste, entrada/home/logout, isolamento de todos os comandos e preservação do legado. Login, tokens e dados persistem/revogam conforme contrato após reinício.
2. Comprovar retry → backlog, exclusão de pendências com cota/histórico corretos e seleção persistida de ambos os temas. Cobrir regressões e evidências de falha/concorrência das tarefas produtoras.
3. Validar o artefato local integrado pela TASK-011 e executar gates; relacionar testes aos IDs de aceite e registrar configuração isolada, persistência após reinício e limitações de navegador. Distinguir testes de e-mail da aplicação do smoke test do release, sem expor mailbox em produção. Não exigir domínio, provedor real, backup/restauração remota ou avaliação humana de UI. Documentar no README os pontos existentes para configuração posterior de e-mail pelo usuário, sem implementar adapter ou camada adicional.
4. Falha exige correção com evidência antes de encerrar. Revisão independente apenas se solicitada. Não implementar novas features nesta consolidação; encaminhar falta de contrato ao planejador.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.
