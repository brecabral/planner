---
id: "TASK-046"
status: "planned"
execution_level: "standard"
execution_rationale: "Integra o notifier autenticado à mailbox Swoosh já instalada e documenta o fluxo verificável."
specs: ["SPEC-005"]
depends_on: ["TASK-045"]
provides: ["local-magic-link-testing"]
consumes: ["private-user-planning"]
write_scope: ["config/dev.exs", "config/test.exs", "config/config.exs", "lib/planner/mailer.ex", "lib/planner/accounts/user_notifier.ex", "lib/planner_web/router.ex", "test/", "README.md", "docs/tasks/046-magic-link-dev.md"]
blockers: []
---

# 046 — Preparar teste local de magic link

## Objetivo e entradas

Entregar SPEC-005 RN14/CA-005-12. Ler Mailer/configuração Swoosh, notifier, router e README. A rota `/dev/mailbox` e Swoosh já existem; reutilizá-los sem serviço externo ou novo gerador.

## Aceite e testes

1. Em dev, cadastrar/solicitar magic link captura mensagem local com host/porta configurados; seguir URL permite entrar e chegar ao dashboard. Não requer credenciais de envio real.
2. Fluxo permite sair e testar segunda conta isolada. Em test, usar adapter apropriado e assertions de destinatário/link sem enviar e-mail real. Cobrir falha de envio sem sessão indevida.
3. Mailbox/LiveDashboard dev ausentes na configuração de produção. Documentar somente no README os passos executáveis de cadastro, mailbox, link expirado/reenvio e troca de conta, incluindo limites de teste local versus entrega externa.
4. Não escolher provedor de produção nem expor mailbox fora de dev. Não alterar TTL/revogação para facilitar teste.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.
