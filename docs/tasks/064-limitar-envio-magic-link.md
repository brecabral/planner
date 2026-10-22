---
id: "TASK-064"
status: planned
execution_level: advanced
execution_rationale: "Integra reservas concorrentes persistentes, origem confiável em LiveView e feedback sem enumeração, cobrindo cadastro, login e orçamento de envio."
specs: ["SPEC-001", "SPEC-005", "SPEC-008"]
depends_on: ["TASK-063"]
provides: ["limited-auth-email-delivery"]
consumes: ["resend-production-mailer"]
write_scope: ["lib/planner/accounts.ex", "lib/planner/accounts/", "lib/planner_web/endpoint.ex", "lib/planner_web/plugs/", "lib/planner_web/live/user_live/", "config/config.exs", "config/runtime.exs", "priv/repo/migrations/", "priv/gettext/", "assets/js/", "assets/e2e/", "test/planner/", "test/planner_config/", "test/planner_web/", "test/support/", "compose.e2e.yaml", ".github/workflows/ci.yml", ".env.example", "README.md", "docs/tasks/064-limitar-envio-magic-link.md"]
blockers: []
---

# 064 — Limitar pedidos de e-mail e exibir espera na mesma tela

## Objetivo e contexto

Implementar SPEC-005 RN21–RN26/CA-005-19–21 sobre o Resend da TASK-060 e os idiomas da TASK-014, ambos ancestrais da TASK-063. Sequência serializa runtime, README, área web, assets e testes. Usuário confirmou mesma tela e limites por env em 19/10/2026. Não criar página de espera.

Ler Accounts, User.email_changeset, UserToken, UserNotifier, Login/Registration, UserAuth, Endpoint e fixtures E2E. Consultar referências Ecto/migrations, Phoenix, LiveView, interop JS, Gettext e testes. O envio atual cria token e chama mailer sem limiter; os eventos LiveView não passam novamente por plugs HTTP. Obter dados de conexão confiáveis com os mecanismos de endpoint/connect_info existentes. Fonte operacional do header: [Fly](https://docs.fly.io/networking/request-headers/).

## Contrato de implementação

- Ler os quatro limites positivos na inicialização; defaults 60 s, 5/e-mail/hora, 20/IP/hora e 90 chamadas/dia UTC. Configurar em dev/test via configuração isolada, sem mudar defaults para testes passarem. `AUTH_TRUST_FLY_PROXY` padrão false, aceitando apenas true/false. Documentar envs, atualização por reinício e limitação de IP compartilhado por NAT.
- Produzir armazenamento de reservas no PostgreSQL com migration aditiva e identificadores derivados por hash com chave, sem endereço/IP cru. Usar transação/lock para reservas atômicas; persistir cooldown, janelas horárias e orçamento diário entre reinícios. Chamadas externas ocorrem após commit, nunca segurando transação durante rede. Definir ordem estável dos locks; testes disputam a última permissão por conexões distintas.
- Por e-mail/IP, verificar e registrar solicitações válidas antes de lookup/cadastro para comportamento equivalente de contas existentes/inexistentes. Rejeições de validação não chamam mailer. Limite negado não cria token; cadastro verifica limite antes de criar conta. Reservar orçamento global imediatamente antes de entrega real; falha/timeouts não devolvem reserva. Não adicionar retry automático ou fila. Preservar conta se falhar depois da criação.
- Expor resultado interno de limite com espera restante em segundos; determinar espera pela restrição ativa mais longa. A UI não recebe contadores globais nem diagnóstico do provedor. Reavaliar no servidor em toda tentativa. Entrada desconhecida continua com feedback genérico; preservar erros de cadastro existentes.
- Integrar origem confiável também em conexões WebSocket/longpoll: não aceitar IP em formulário, params ou header arbitrário do cliente. No modo Fly, validar `Fly-Client-IP` e transportar o resultado pelo servidor até a LiveView; sobrescrever qualquer marcador interno recebido externamente. Documentar que esse modo exige ingresso exclusivo via Fly Proxy; sem header válido, negar envio. Fora desse modo, usar peer real. Não implementar cadeia de proxies ou confiar livremente em X-Forwarded-For.
- Login mantém e-mail, instruções e botão de envio com contagem regressiva. Não desabilitar navegação ao cadastro nem edição. Cadastro continua redirecionando ao login, com dados mínimos da espera sem endereço na query string. Consultar/revalidar estado na retomada e submissão; relógio do cliente não concede permissão. Expiração habilita ação manual, sem reenviar automaticamente. Traduzir mensagens via Gettext nos idiomas já integrados.
- Limpeza limitada de registros expirados durante operações admitidas; sem endpoint de contadores. Não introduzir Redis, CAPTCHA, biblioteca de rate limit ou defesa genérica contra DDoS. O teto limita gasto, mas pode ser esgotado por abuso; não prometer disponibilidade sob ataque.

## Aceite e evidências

1. Testes de intenção cobrem os valores de configuração, precedência, inválidos, normalização, janelas/fronteiras, limites por destinatário/IP/global, contas desconhecidas e tentativas bloqueadas sem token/envio. Usar relógio controlado e restaurar ambiente/configuração.
2. Testes concorrentes com conexões independentes demonstram respeito à última vaga e orçamento; falhas de banco impedem envio, falhas de adapter não reembolsam reserva, reinício do componente preserva estado no banco. Não testar reinício do release fora do runner existente.
3. Testes HTTP/LiveView cobrem origem válida, header falsificado, conexão sem IP no modo Fly, nova aba/reconexão/evento forjado, erro de cadastro e recuperação após janela. Capturar mailer sem enviar a Resend. Fixtures privadas continuam emitindo tokens sem bypass público.
4. E2E completo inclui espera na mesma tela, preenchimento preservado, liberação manual, tentativa durante cooldown, recarga e navegação ao cadastro. Exercitar solicitações de e-mails sintéticos inexistentes para não chamar Resend; o teste de envio/cadastro real fica na suíte com adapter Test. Usar cooldown curto somente no ambiente isolado E2E (Compose/CI) e polling por resultado; não alterar defaults de produção nem recorrer a sleeps longos. Fixtures privadas podem preparar estado de limite, sem endpoint público de bypass.
5. README documenta envs e defaults, reserva conservadora, reset diário UTC, alteração por reinício e fronteira de confiança do proxy. `.env.example` mantém exemplos de prod comentados. Registrar que quota Resend também pode ser consumida fora desta aplicação e que seus 429 continuam sendo falhas tratadas.

## Execução e conclusão

TDD enxuto e ajuda do gerador de migration antes de gerar; completar migration antes de aplicar. Executar precommit, qualidade/cobertura mínima de 70% e E2E completo pelos comandos do README. Autoavaliação pelo fluxo de review, sem revisão independente automática. Registrar evidências, limitações e integração; `done` só após conferência operacional. Bloqueios seguem protocolo existente.

Planejada em 19/10/2026; não implementada. Padrões numéricos são escolhas iniciais do planejamento, configuráveis pelo responsável.
