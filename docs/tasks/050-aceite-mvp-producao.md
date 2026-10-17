---
id: "TASK-050"
status: "in_progress"
execution_level: "advanced"
execution_rationale: "Consolida contratos transversais de autenticação, isolamento, tarefas e persistência no artefato local final."
specs: ["SPEC-002", "SPEC-004", "SPEC-005", "SPEC-007", "SPEC-008"]
depends_on: ["TASK-058"]
provides: ["verified-local-release"]
consumes: ["release-scaffold"]
write_scope: ["test/", "docs/specs/", "README.md", "docs/tasks/050-aceite-mvp-producao.md"]
blockers: []
---

# 050 — Validar o código Phoenix e o release local

## Objetivo e entradas

Verificar CA17–CA19/CA16 do PRD e SPEC-008 RN02–RN05/CA-008-02 e CA-008-04 no release local. Carregar contratos/registro das entregas 041–048, 015, 051 e 011, Mailer/configurações existentes e referências testes/Mix. Não presumir prontidão a partir da documentação ou do antigo aceite local.

## Aceite e evidências

1. Conferir a regressão de falha de envio e recuperação do cadastro (CA-005-13/TASK-051). Reproduzir fluxo de duas contas: cadastro e captura do link com adapter local/de teste, entrada/home/logout, isolamento de todos os comandos e preservação do legado. Login e tokens seguem as regras de validade e revogação da SPEC-005.
2. Comprovar retry → backlog, exclusão de pendências com cota/histórico corretos e seleção persistida de ambos os temas. Cobrir regressões e evidências de falha/concorrência das tarefas produtoras.
3. Validar o artefato local integrado pela TASK-011 e executar gates; relacionar testes aos IDs de aceite e registrar configuração isolada e limitações de navegador. Distinguir testes de e-mail da aplicação do smoke test do release, sem expor mailbox em produção. Não exigir domínio, provedor real, backup/restauração remota ou avaliação humana de UI. Documentar no README os pontos existentes para configuração posterior de e-mail pelo usuário, sem implementar adapter ou camada adicional.
4. Falha exige correção com evidência antes de encerrar. Revisão independente apenas se solicitada. Não implementar novas features nesta consolidação; encaminhar falta de contrato ao planejador.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.

## Reconciliação de R7 — 16/10/2026

Aguardar a TASK-058 para usar os gates locais com isolamento corrigido, conforme [BLOCK-006](../blocks/006-isolamento-compose-teste.md). Dependências anteriores continuam alcançáveis pela cadeia; nenhuma implementação ou validação adicional nesta rodada.

## Retomada e impedimento — 17/10/2026

Base inspecionada: `fb9432377522049d66ff84dc810264a4e0871b1c`, árvore inicialmente limpa. TASK-058 integrada e BLOCK-006 resolvido; TASK-056 integrada com evidências de navegador. Inspeção inicial pelo implementador `/root/task050` identificou ausência de teste automatizado versionado e integrado para reinício do release sobre o mesmo banco, exigido por CA-008-03 e pelos critérios 1/3 desta tarefa.

O smoke histórico da TASK-011 usou verificador temporário; a suíte atual de navegador cobre recargas, mas seu runner não reinicia o release. O ExUnit usa aplicação de teste com Sandbox. Criar teste de reinício da aplicação de teste não comprovaria reinício do artefato de produção. Integração de controle do ciclo de vida do release precisa de planejamento dos recursos fora de `write_scope`, conforme [BLOCK-007](../blocks/007-aceite-automatizado-reinicio-release.md).

Execução interrompida na análise inicial, sem mudança de código ou novos testes/gates executados. Evidências históricas não foram reapresentadas como validação desta rodada. Critérios de aceite e autoavaliação técnica permanecem pendentes; não há aprovação nem entrega `in_review`. Preservados apenas estes registros documentais para o coordenador integrar e encaminhar ao planejador.

## Reconciliação do BLOCK-007 — 17/10/2026

Decisão explícita do responsável remove o aceite de persistência após reinício do release. CA-008-03 foi retirado e os critérios 1/3 foram ajustados; não há integração de controle de reinício a produzir. A estrutura é responsabilidade das migrations do Ecto, conforme SPEC-008 RN03. O diagnóstico acima permanece histórico. BLOCK-007 resolvido pela retirada do requisito; tarefa permanece `in_progress`, na análise inicial, com os demais aceites e gates pendentes. Nenhuma execução ou aprovação técnica nesta reconciliação.
