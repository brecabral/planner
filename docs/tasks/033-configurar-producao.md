---
id: "TASK-033"
status: "planned"
execution_level: "advanced"
execution_rationale: "Integra configuração de release, domínio e entrega de autenticação sem expor segredos ou dados."
specs: ["SPEC-008", "SPEC-005"]
depends_on: ["TASK-011"]
provides: ["production-runtime"]
consumes: ["release-scaffold"]
write_scope: ["config/runtime.exs", "config/prod.exs", ".env.example", "lib/planner/mailer.ex", "test/planner/", "test/planner_web/", "README.md", "docs/tasks/033-configurar-producao.md"]
blockers: ["Definir hospedagem, domínio, provedor/remetente de e-mail e fechar SPEC-008 antes de implementar configuração específica."]
---

# 033 — Configurar runtime e envio real de magic link

## Objetivo e entradas

Entregar SPEC-008 RN01–RN03/CA-008-02 quando o destino estiver definido. Consumir release TASK-011; ler Mailer/auth/config/runtime e referências Phoenix/Mix. Reutilizar Swoosh e, se necessário ao adapter escolhido, Req; não escolher fornecedor por inferência.

## Aceite condicionado ao contrato pronto

1. Configuração externa cobre banco, secret, host/HTTPS e remetente/credenciais; ausência necessária falha claramente sem revelar segredo. Não versionar credenciais nem embuti-las no artefato.
2. Envio controlado no destino homologado produz link para o host correto, com login/expiração/reuso conforme auth; falha de envio não autentica nem mostra entrega efetiva indevida. Registrar destinatário de teste autorizado sem expor token em documentação.
3. Não há mailbox/dashboard dev nem fallback default em prod. README registra variáveis e procedimentos verificados. Não publicar serviço como consequência da configuração; TASK-034 possui a entrega remota.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.
