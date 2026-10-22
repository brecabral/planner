---
id: "SPEC-008"
status: ready
requirements: ["RF11", "CA16", "CA19"]
---

# 008 — Entrega de código Phoenix e release local

## Escopo e origem

Decisão do responsável em 13/10/2026: entregar código Phoenix funcional; infraestrutura e operação remota ficam sob sua responsabilidade. Substitui o contrato remoto anterior desta spec, preservando os IDs. Prontidão do contrato não significa implementação concluída.

## Regras

- RN01: release contém assets e migrations, executa com configuração externa e PostgreSQL; não inicia Compose de desenvolvimento nem cria conta compartilhada acessível. Não inclui segredos na imagem/repositório. Assets usam dependências e lockfiles existentes.
- RN02: e-mail reutiliza Planner.Mailer/Swoosh e os fluxos Phoenix existentes. Desenvolvimento captura mensagens na mailbox local; testes capturam mensagens sem envio externo. A configuração de adapter, credenciais e remetente reais cabe posteriormente ao usuário. Não criar abstração de provedores nem escolher serviço para esta entrega. Falha de envio não autentica nem anuncia entrega efetiva não confirmada.
- RN03: rotas de desenvolvimento ficam ausentes na configuração de produção. A estrutura do banco é criada e evoluída pelas migrations do Ecto; o runtime usa a estrutura previamente migrada, sem criar ou reparar tabelas, índices ou constraints. Scripts de migration não resetam nem transferem dados legados.
- RN04: backup, retenção e restauração de ambiente remoto estão fora da entrega de código e sob responsabilidade do usuário; não constituem gate do release local.
- RN05: aceite integrado exercita cadastro, captura de link, login/logout, duas contas isoladas, exclusão e retry → backlog, temas. Não exige teste de durabilidade do banco ou de persistência após reinício do release. Gates mantêm cobertura mínima de 70%. Evidências distinguem testes da aplicação, smoke test do release e limites de navegador.

## Cenários de aceite

- CA-008-01: dado banco isolado e configuração de teste, construir e iniciar o release permite migrations e acesso sem Mix no runtime; artefato contém assets e não contém segredos locais.
- CA-008-02: dado adapter local em desenvolvimento ou de teste nos testes, solicitar link captura destinatário/URL corretos; consumir o link autentica e reuso/expiração são rejeitados conforme SPEC-005. Falha de envio não concede sessão. Na configuração de produção, rotas de desenvolvimento estão ausentes. Nenhum envio externo é exigido.
- CA-008-03: retirado por decisão do responsável em 17/10/2026. Persistência após reinício não constitui aceite da aplicação; ID reservado para preservar referências históricas.
- CA-008-04: dado release identificado por versão/base, consolidar evidências das SPEC-002/004/005/007, gates e smoke test permite entregar o código ao usuário, com limites explícitos. Não exige domínio, publicação ou provedor real. Testes com captura de e-mail não comprovam entrega externa.

## Incremento Resend — decisão de 19/10/2026

O responsável escolheu Resend e solicitou uma tarefa de integração. Este incremento substitui a proibição de escolher/configurar serviço de RN02 somente para a nova entrega; mantém o aceite local histórico e a operação remota sob responsabilidade do usuário.

- RN06: produção usa `Swoosh.Adapters.Resend` no `Planner.Mailer`, com cliente Req existente e chave `RESEND_API_KEY`. Exigir chave e `MAIL_FROM_EMAIL` não vazios; ausência impede inicialização com mensagem que identifica a variável, sem revelar valores. `MAIL_FROM_NAME` é opcional, com padrão `Just Three`. Não criar abstração multiprovedor nem dependência adicional.
- RN07: o notifier lê o remetente da configuração da aplicação. Desenvolvimento conserva adapter Local e remetente local; testes conservam adapter Test. Nenhum dos dois exige credenciais Resend. Não alterar tokens, sessão, conteúdo/tradução das mensagens, fluxo de recuperação de falha ou regras de cadastro.
- RN08: a configuração de produção é exercitada por testes automatizados sem envio externo. Release E2E e CI recebem valores sintéticos explícitos para as variáveis exigidas; as fixtures continuam preparando tokens sem chamar o provedor. Não habilitar mailbox nem fallback Local em produção. Credenciais reais, domínio/DNS e comprovação de entrega externa pertencem à operação posterior.

- CA-008-05: dada configuração de produção com chave e remetente sintéticos, carregar a configuração seleciona Resend/Req; uma mensagem construída pelo notifier usa o endereço configurado e o nome informado ou `Just Three` quando omitido. O teste captura a mensagem sem acesso ao serviço externo.
- CA-008-06: dada chave ou endereço ausente ou vazio, carregar configuração de produção falha identificando a variável, sem expor segredos. Dev e test carregam sem essas variáveis e preservam seus adapters.
- CA-008-07: dadas fixtures privadas e variáveis sintéticas, a suíte E2E completa continua executando sobre release prod sem envio real ou rotas dev. Regressões existentes de autenticação e recuperação de falha permanecem aprovadas.

TASK-060 produz este incremento, ainda não implementado; configuração Neon, mudança de banco local para URL e deploy ficam fora da tarefa.

## TLS e healthcheck mínimo — 19/10/2026

Pedido do responsável: configurar TLS para Neon e um healthcheck sem informações públicas do projeto. Operação Fly e backups permanecem fora do desenvolvimento.

- RN09: produção conecta ao PostgreSQL com TLS e verificação de cadeia e hostname por padrão, usando as CAs do sistema. Não usar `verify_none` nem fallback após falha de certificado. `DATABASE_SSL` aceita somente `true` ou `false`, com padrão `true` em prod; `false` é exceção explícita para bancos isolados de E2E/CI sem TLS. Parâmetros da URL não podem enfraquecer a política; configuração contraditória deve falhar sem exibir a URL. Dev/test conservam o contrato local da TASK-061. O mesmo runtime atende migrations e servidor.
- RN10: `GET /health` é público e responde status 200, corpo literal `ok`, tipo `text/plain` e `Cache-Control: no-store`; `HEAD /health` responde 200 sem corpo. Não consulta banco, e-mail ou serviços externos, não carrega sessão/conta, não emite cookie e não expõe versão, ambiente, commit, dependências, métricas, host, credenciais ou detalhes de erro. É sinal de processo HTTP respondendo, não de prontidão de dependências. A rota pode responder HTTP interno sem redirecionamento SSL; preservar HTTPS nas demais rotas.
- CA-008-08: configuração prod padrão resulta em TLS com CA e verificação de hostname; flags inválidas e URL que tente desativar TLS são rejeitadas sem segredos. Exceção `DATABASE_SSL=false` permite os gates isolados existentes, explicitamente configurados, sem mudar o padrão seguro.
- CA-008-09: testes versionados verificam as opções TLS efetivas e a rejeição da configuração conflitante; o release E2E continua iniciando/migrando com a exceção local explícita. Isso não comprova conexão a uma conta Neon real.
- CA-008-10: GET/HEAD do healthcheck obedecem RN10 inclusive sem autenticação e com cookie inválido; a rota não chama Repo/Mailer e funciona sem depender deles durante a requisição. Teste no release confirma resposta mínima e ausência de redirecionamento no HTTP interno. Não exige parar o banco ou alterar o runner para simular infraestrutura caída.

Entregas: TASK-062 (TLS) e TASK-063 (healthcheck). A configuração do monitor Fly é do responsável.

## Histórico da entrega local

TASK-011 produz o release local; TASK-050 consolida o aceite do código e do artefato. TASK-033, TASK-034 e TASK-035 foram canceladas por retirada da operação remota do escopo, sem alegação de execução. Não há dúvida externa bloqueante neste contrato. Procedimentos efetivamente testados e pontos de configuração ficam exclusivamente no README.
