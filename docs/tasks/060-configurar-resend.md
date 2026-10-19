---
id: "TASK-060"
status: planned
execution_level: standard
execution_rationale: "Integra adapter existente, configuração de runtime e remetente, com isolamento de ambientes e regressão do release sem envio externo."
specs: ["SPEC-005", "SPEC-008"]
depends_on: ["TASK-013", "TASK-050", "TASK-056"]
provides: ["resend-production-mailer"]
consumes: ["verified-local-release", "e2e-authenticated-suite"]
write_scope: ["config/config.exs", "config/runtime.exs", "config/prod.exs", "lib/planner/accounts/user_notifier.ex", "test/planner_mailer/", "compose.e2e.yaml", ".github/workflows/ci.yml", ".env.example", "README.md", "docs/tasks/060-configurar-resend.md"]
blockers: []
---

# 060 — Configurar Resend e remetente de produção

## Objetivo e contexto

Implementar SPEC-008 RN06–RN08 e CA-008-05–07, preservando SPEC-005 e os fluxos existentes de magic link. Escolha confirmada pelo responsável em 19/10/2026, registrada em D24. O código atual usa adapter Local na configuração base e remetente fixo `Planner <contact@example.com>`; o Swoosh instalado já fornece `Swoosh.Adapters.Resend` e produção já seleciona Req como cliente HTTP.

Ler `config/config.exs`, `config/runtime.exs`, `config/prod.exs`, `Planner.Mailer`, `Planner.Accounts.UserNotifier`, o adapter Resend instalado e os testes de magic link/recuperação da TASK-051. Consultar referências Elixir, testes e Mix antes de implementar. Reutilizar os recursos existentes, sem gerador ou nova dependência.

TASK-050 fornece aceite do release; TASK-056 fornece a suíte autenticada. A dependência TASK-013 serializa a alteração de `user_notifier.ex` com o escopo `lib/planner/accounts/` dessa tarefa; não é requisito funcional de idiomas para o Resend. Depois dessa integração, TASK-014 e TASK-060 têm escopos de escrita distintos. Não alterar os testes web compartilhados: acrescentar testes próprios em `test/planner_mailer/` e executar as regressões existentes.

## Entrega e limites

- Configurar Resend somente em produção, exigindo `RESEND_API_KEY` e `MAIL_FROM_EMAIL` não vazios; `MAIL_FROM_NAME` opcional com padrão `Just Three`. Mensagens técnicas de erro em inglês, identificando a variável sem imprimir valores.
- Tornar o remetente do notifier configurável pela aplicação, mantendo o remetente local atual fora de produção. Preservar adapter Local em dev e Test nos testes, sem exigir chave real.
- Preservar cliente Req, conteúdo/tradução dos e-mails, retornos de entrega, cadastro, recuperação de falhas e segurança de tokens/sessões. Não criar fila, retry automático, rate limit, abstração de provedores ou páginas novas.
- Atualizar configuração E2E e workflow para passar chave/remetente sintéticos ao release e à execução de migrations. Não chamar Resend, habilitar mailbox ou introduzir fallback Local em prod. Preservar fixtures privadas de autenticação.
- Atualizar os exemplos e a operação no README para distinguir variáveis obrigatórias, configuração implementada e verificação externa ainda pendente. Não editar `.env` privado nem registrar credenciais reais.
- Fora do escopo: instalar CLI, criar conta Resend, verificar domínio/DNS, publicar na Fly, configurar Neon/TLS, mudar banco local para URL, escolher domínio/remetente real ou comprovar entrega externa. Esses valores não bloqueiam testes com configuração sintética.

## Aceite e testes

1. CA-008-05: teste versionado carrega a configuração prod com valores sintéticos e verifica Resend e Req. Teste do notifier captura a mensagem e verifica remetente configurado, nome explícito e padrão quando omitido, preservando destinatário e link. Nenhuma chamada HTTP externa.
2. CA-008-06: cobrir chave e endereço ausentes e vazios; inicialização/configuração falha com identificação da variável e sem exposição dos valores. Dev/test continuam carregando sem credenciais, com seus adapters originais. Restaurar configuração/ambiente após cada teste; evitar interferência entre testes concorrentes.
3. CA-008-07: executar regressões existentes de cadastro, falha de envio, recuperação, login e isolamento. Executar a suíte E2E completa sobre release com variáveis sintéticas; não substituir Resend por Local no runtime prod para obter aprovação. As fixtures não solicitam entrega externa.
4. Exemplos e README correspondem às variáveis efetivamente consumidas. Registrar limites: os testes não atestam DNS, reputação, quota ou recebimento real de e-mail. Não declarar o ambiente público pronto.

## Execução e conclusão

Conferir dependências integradas e specs prontas antes de iniciar. Aplicar TDD enxuto e autoavaliação pelo fluxo de review, sem revisão independente automática. Testes novos pertencem à suíte versionada; não usar scripts temporários como aceite. Consultar ajuda Mix antes das tarefas e executar os gates do README, incluindo precommit, qualidade/cobertura mínima de 70% e E2E completo. Registrar resultados, limites e artefatos nesta tarefa. Conferência operacional e commit de integração precedem `done`; impedimentos seguem o protocolo de `docs/blocks`.

## Estado do planejamento

Criada em 19/10/2026; nenhuma implementação, credencial, envio ou publicação nesta rodada. Aguarda TASK-013; TASK-050 e TASK-056 estão concluídas. A configuração por URL em desenvolvimento e a preparação Fly/Neon permanecem decisões documentadas para trabalho posterior.
