---
id: "SPEC-005"
status: ready
requirements: ["RF08", "RF13", "CA13", "CA17"]
---

# 005 — Contas, magic link e isolamento

## Escopo e origem

MVP de produção autorizado em 11/10/2026: cadastro aberto por e-mail, login exclusivamente por magic link e autenticação padrão do Phoenix instalado. O responsável confirmou que dados antigos ficam isolados, sem migração para conta real. O MVP local sem login permanece uma entrega histórica aceita (TASK-009/TASK-037); seus critérios CA-005-01–06 não são gates do fluxo autenticado.

## Arquitetura e casos de uso

Reutilizar `Planner.Accounts.User` e tabela `users`, adaptando o scaffold Phoenix com tokens, notifier, sessão, `Accounts.Scope`, plugs e hooks gerados. Accounts resolve a identidade; o servidor fornece `current_scope.user` às APIs de tarefas/labels/cota e, posteriormente, temas. Não gerar outro contexto de identidade nem sobrescrever migrations já aplicadas. A interface não escolhe proprietário.

### Regras

- RN08: visitante pode registrar e-mail e receber link para confirmar posse e entrar; conta existente solicita novo link. Usar cadastro e solicitação do scaffold, com feedback genérico na solicitação de login. Não criar login, definição ou recuperação de senha, OAuth ou convites neste MVP; remover superfícies de senha geradas que não pertencem ao contrato.
- RN09: manter construção, hash persistido, expiração, confirmação, revogação e sessão do gerador instalado. Magic link de login expira em 15 minutos conforme template local consultado em 11/10/2026; consumo não pode autenticar novamente com o mesmo token. Link inválido/expirado/usado não abre sessão e permite solicitar outro. Preservar proteção CSRF, renovação de sessão e logout com revogação do padrão Phoenix.
- RN10: `/` leva o visitante ao login (`/users/log-in`); autenticado acessando `/` ou login vai a `/tasks`. Após consumir link, destino padrão é `/tasks`; retornos só podem ser internos autorizados, nunca URL externa fornecida pelo cliente. Logout volta ao login.
- RN11: `/tasks`, `/tasks/new` e toda entrada de planejamento exigem identidade válida tanto no HTTP quanto no mount/reconexão LiveView. Não há fallback para usuário padrão em dev/test/prod após integração da TASK-045. Sessão ausente/revogada impede leitura/comando e exige login conforme os helpers gerados.
- RN12: tarefas, labels, histórico, cota e preferências pertencem ao usuário autenticado. IDs/params de outro usuário têm o mesmo resultado de IDs inexistentes; nunca listar, mover, excluir, concluir, associar ou alterar dados alheios. Não confiar em user_id de params, eventos, formulário ou armazenamento local. Duas contas têm cotas independentes.
- RN13: preservar o usuário legado `default`, seus IDs, tarefas, labels, histórico e cota, mas sem e-mail de login/token nem acesso por visitantes/novas contas. Não associar seus dados ao primeiro cadastro, não criar e-mail fictício e não apagar o banco. Migrations aditivas acomodam usuários legados sem e-mail; contas autenticáveis exigem e-mail válido com unicidade normalizada. Cadastro novo não herda `identifier=default` nem depende desse campo legado obrigatório.
- RN14: desenvolvimento usa Swoosh local e `/dev/mailbox`, já existentes, para capturar links com host/porta locais configurados. Não requer credencial nem envio externo. Produção não expõe mailbox/LiveDashboard de desenvolvimento; o provedor de envio real pode ser configurado posteriormente pelo usuário, fora do aceite local da SPEC-008. Interface/e-mails usam Gettext com mensagens-base em inglês e pt-BR.

- RN15: se o envio do link falhar após persistir o cadastro, preservar a conta e suas concessões, sem abrir sessão, anunciar entrega ou encerrar a LiveView por erro não tratado. Redirecionar ao login com mensagem de erro traduzida que informe a falha e oriente solicitar novo link. A recuperação usa a conta existente e o fluxo de solicitação, sem repetir cadastro, criar conta duplicada ou alterar o protocolo de tokens. Esclarecimento do contrato RN08 e SPEC-008 RN02 após R3 da revisão de 13/10/2026.

## Cenários de aceite

- CA-005-07: cadastrar e-mail novo e seguir link confirma a conta, inicia sessão e abre dashboard vazio próprio; repetir cadastro não duplica e-mail normalizado. Conta existente pode entrar por novo magic link; senha não tem rota/formulário utilizável.
- CA-005-08: token inválido, expirado, já consumido e duas tentativas concorrentes não geram autenticação adicional; primeira confirmação e logout preservam revogações do scaffold. Testes usam tempo controlado quando necessário.
- CA-005-09: visitante em `/`, `/tasks` e `/tasks/new` termina no login sem dados privados; autenticado em `/`/login termina em `/tasks`. Mount direto/reconexão sem sessão não recuperam dados; logout invalida a sessão de acordo com o fluxo gerado.
- CA-005-10: A e B cadastram tarefas/labels; consultas e todos os comandos com IDs forjados não cruzam contas, inclusive histórico, exclusão, movimentos e cota. Seleções em A não consomem escolhas de B.
- CA-005-11: aplicar migration sobre banco com `default` e dados preserva registros/FKs; criar duas contas reais não revela nem transfere o legado. Fixtures e seeds deixam de depender de acesso público ao default; banco novo e existente funcionam.
- CA-005-12: solicitar link em dev entrega mensagem somente na mailbox local; abrir link permite login e sair/entrar com outra conta testa isolamento. Em configuração prod, rotas dev não existem. README contém o procedimento somente após implementado.

- CA-005-13: dado e-mail novo e adapter retornando erro, submeter cadastro mantém uma única conta persistida, não autentica e leva ao login com erro pt-BR e orientação de nova solicitação, sem flash de envio bem-sucedido nem exceção da LiveView. Restaurado o adapter, solicitar link para o mesmo e-mail e consumi-lo permite entrar nessa mesma conta; a unicidade e as concessões iniciais permanecem intactas. O caminho de envio bem-sucedido continua funcionando.

## Dados, limites e entregas

Tokens e preferências não pertencem ao usuário padrão compartilhado. Sem migração de propriedade, exclusão de conta, alteração de e-mail, senha ou gestão administrativa neste incremento. Preservar mecanismos internos necessários do scaffold; não expor telas extras apenas porque foram geradas.

TASK-015 produz auth/schema/scope e telas de entrada; TASK-045 protege o planejamento e substitui a resolução padrão; TASK-046 prepara e documenta teste de e-mail local. A TASK-051 corrige a falha de envio no cadastro (RN15/CA-005-13) antes do release. As três entregas originais são sequenciais e não autorizam publicação intermediária. Sem dúvidas bloqueantes de produto; provedor de produção é responsabilidade posterior do usuário e não bloqueia a entrega do código.

## Página join — planejamento de 14/10/2026

Origem: pedido de planejar uma página de join, com confirmação do responsável de que se trata de criar conta no Planner. A composição e a compatibilidade de rotas abaixo são decisões deste planejamento, dentro do cadastro aberto RF08. Não representam implementação concluída.

### Regras

- RN16: `/join` é a entrada pública de criação de conta e reutiliza a Registration LiveView e Accounts existentes. `/users/register` permanece compatível, redirecionando visitantes para `/join`. Links internos de criação de conta passam a apontar para `/join`. Acessar qualquer uma dessas entradas autenticado leva a `/tasks`. A regra de `/` e o destino de logout permanecem RN10.
- RN17: apresentar marca Planner, título “Crie sua conta”, explicação curta “Organize suas tarefas e escolha até três prioridades por dia.”, campo “E-mail”, botão “Criar conta” e “Já tem uma conta? Entrar”, com destino `/users/log-in`. Antes do envio, explicar “Você receberá um link por e-mail para confirmar sua conta e entrar. Não é necessário criar senha.” Textos são a versão pt-BR; implementação usa mensagens-base em inglês via Gettext. Não solicitar nome, senha, convite ou pagamento.
- RN18: composição em coluna única com largura limitada, apresentação antes do formulário, espaçamento consistente com os componentes e tokens existentes. Em 320 px e em desktop, conteúdo e ações ficam acessíveis sem rolagem horizontal. Campo possui rótulo associado; foco visível e ordem de teclado seguem a leitura. Erros ficam associados ao campo e feedback de envio é perceptível por tecnologia assistiva. Não criar seletor público nem persistência de tema para visitantes.
- RN19: submissão indica processamento e impede repetição enquanto pendente. E-mail inválido ou já cadastrado mantém o formulário com erro traduzido, preserva a entrada e permite correção ou ida ao login. Cadastro válido com envio bem-sucedido leva ao login com orientação de conferir o e-mail, sem autenticar antes de consumir o link. Falha de envio segue RN15; nunca anunciar sucesso nesse caminho. Preservar unicidade normalizada, concessões iniciais, tokens e isolamento existentes.

### Cenários de aceite

- CA-005-14 (RN16): visitante abre `/join` e vê o cadastro; abre `/users/register` e termina em `/join`; segue o link de cadastro no login e chega a `/join`. Autenticado abre cada uma dessas entradas e termina em `/tasks`, sem formulário de cadastro.
- CA-005-15 (RN17/RN18): visitante vê apresentação, explicação de magic link e somente o campo de e-mail. Pelo teclado, preenche, submete e acessa “Entrar” com foco visível. Em larguras de 320 e 1280 px não há corte de ações nem rolagem horizontal; rótulo e erros têm associação verificável. Conferência em navegador registra o que foi efetivamente observado.
- CA-005-16 (RN19): dado e-mail inválido, submeter mantém valor e apresenta erro sem criar conta. Dado e-mail já registrado, inclusive variante de caixa/espaços aceita pela normalização existente, submeter não duplica a conta e oferece acesso ao login. Enquanto envio estiver pendente, o controle apresenta processamento e não permite nova submissão pela interface.
- CA-005-17 (RN19): dado e-mail novo, cadastrar por `/join` com adapter local/de teste bem-sucedido cria uma conta com concessões iniciais e leva ao login com orientação de confirmação; consumir o link abre `/tasks` da conta. Com adapter retornando erro, repetir o cenário de CA-005-13 a partir de `/join`, preservando recuperação e ausência de sessão antecipada.

### Dados e entrega

Sem nova entidade, migration, protocolo de autenticação ou provedor. A [TASK-052](../tasks/052-pagina-join.md) é a única produtora da página e da compatibilidade de rotas, consumindo as entregas existentes de autenticação e recuperação. Sem dúvidas bloqueantes após a confirmação do significado de join. Este incremento não é pré-requisito retroativo do aceite do release já planejado.

## Correção de acesso ao cadastro — 14/10/2026

Origem: responsável relatou que “Criar conta” fica escondido e pediu aparência de botão equivalente a entrar.

- RN20: no login público, “Criar conta” é uma ação visível com o mesmo padrão de botão, altura, largura e destaque do botão de entrar. Posicionar abaixo da ação de entrar, com espaçamento entre ambas, sem depender de hover. Preservar semântica de link para `/join`, fora da submissão do formulário; navegar não exige preencher e-mail nem solicita magic link. Tema público permanece claro e textos usam Gettext.
- CA-005-18: visitante abre `/users/log-in` e identifica as duas ações com aparência de botão; com e-mail vazio, ativa “Criar conta” por clique ou teclado e chega a `/join` sem validação do login ou envio de e-mail. Em 320 e 1280 px, ambas estão legíveis, sem sobreposição ou rolagem horizontal e com foco visível. Entrar continua submetendo o fluxo existente.

Entrega: [TASK-053](../tasks/053-destacar-criar-conta-login.md). Sem mudanças de dados ou autenticação e sem dúvidas bloqueantes.

## Proteção de pedidos de magic link — 19/10/2026

Origem: responsável pediu limites de uso do Resend, confirmou espera na mesma tela e configuração dos limites por ambiente. Valores abaixo são padrões iniciais propostos pelo planejador, ajustáveis na operação; não representam limites universais ou garantia de disponibilidade contra ataques distribuídos.

- RN21: cadastro e solicitação de login compartilham a mesma proteção no servidor, antes de criar token ou chamar o mailer. Limites são lidos e validados uma vez na inicialização: `AUTH_EMAIL_COOLDOWN_SECONDS=60`, `AUTH_EMAIL_MAX_PER_HOUR=5`, `AUTH_IP_MAX_PER_HOUR=20`, `AUTH_EMAIL_MAX_PER_DAY=90`. Aceitar somente inteiros positivos; valor inválido interrompe inicialização com identificação da variável. Aplicar intervalos móveis para cooldown e hora; teto global de chamadas ao mailer reinicia à meia-noite UTC. Alterações de ambiente passam a valer após reinício. Não consultar ambiente em cada tick/evento.
- RN22: usar e-mail normalizado pelas regras existentes e IP obtido pelo servidor, nunca por params/eventos. Registrar tentativas admissíveis para e-mails existentes e inexistentes de modo equivalente nos limites individuais. Verificação/reserva deve ser atômica entre abas, conexões e requisições concorrentes e persistir no PostgreSQL para que reinício não zere a proteção. Reserva negada não cria token nem chama mailer; no cadastro, verificar os limites antes de persistir conta. Falha da proteção deve impedir envio. Tentativas bloqueadas não prolongam janelas.
- RN23: orçamento diário global conta tentativas de entrega reservadas imediatamente antes de chamar o mailer, inclusive falhas/timeouts; não conta consulta de e-mail inexistente, validação rejeitada ou operação bloqueada antes de envio. Não reembolsar tentativa de resultado incerto nem repetir automaticamente. Reservar de forma concorrente sem exceder o teto, incluindo confirmação de cadastro e login. Após persistir cadastro, falha de envio/orçamento preserva conta e recuperação via login conforme RN15.
- RN24: permanecer em `/users/log-in` após solicitação, preservando e-mail; mostrar orientação genérica e botão de envio desabilitado com tempo restante. Ao expirar, habilitar somente ação manual, sem envio automático. Não bloquear navegação para cadastro nem correção do e-mail. Cadastro bem-sucedido continua levando ao login, com e-mail preenchido e espera correspondente. O servidor retorna espera aplicável, inclusive janelas horárias/diárias; navegador só apresenta a contagem. Remontagem, recarga, reconexão, nova aba, troca de e-mail e eventos forjados não burlam limites persistidos. Expirar contagem não garante envio: servidor sempre revalida.
- RN25: no login, respostas não confirmam existência de conta nem entrega efetiva. Manter comportamento de erro de cadastro previsto em RN15/RN19; não reabrir o contrato de enumeração do cadastro neste incremento. Limites por IP precisam tratar IPv4/IPv6 e proxy: por padrão usar endereço de conexão; `AUTH_TRUST_FLY_PROXY=true` habilita uso validado de `Fly-Client-IP` somente em implantação com entrada exclusiva pelo proxy Fly. Header ausente/inválido nesse modo não autoriza envio. Não confiar em `X-Forwarded-For` arbitrário ou em IP fornecido pelo evento. A informação confiável deve chegar também ao mount/conexão LiveView; limiter só em Plug HTTP não é suficiente.
- RN26: estado mínimo de proteção não guarda tokens nem endereço/IP em texto aberto; usar identificadores derivados por hash com chave e retenção limitada às janelas necessárias. Remover registros expirados de forma limitada durante operações admitidas; não manter histórico de navegação ou endpoint público de contadores. Usar PostgreSQL existente, sem Redis, fila ou dependência de rate limit neste incremento.

- CA-005-19: primeira tentativa válida admite envio; repetição dentro do cooldown e excesso por e-mail/IP são negados sem novo token/envio. Cobrir fronteiras exatas das janelas, normalização, cadastro/login compartilhados, e-mail inexistente, IPv4/IPv6 e tentativa de falsificar IP. Valores de env diferentes alteram os limites após carregar configuração; valores inválidos falham.
- CA-005-20: concorrentes disputando a última permissão têm no máximo um vencedor; orçamento global nunca é excedido. Falha de mailer mantém a reserva, não abre sessão nem dispara retry; reinício do componente/reconexão não zera contadores persistidos. Falha de banco impede envio. Fixtures e relógio controlado exercitam fronteiras, sem esperas reais longas.
- CA-005-21: em navegador, login mantém e-mail e orientação, mostra contagem, impede envio enquanto bloqueado e permite nova tentativa manual após liberação; recarga/reconexão não burla limite. Navegar ao cadastro e corrigir endereço continuam possíveis. Cadastro preserva redirecionamento e erro/recuperação. Testes usam adapter/captura local ou fixture privada, nunca Resend real.

Entrega: TASK-064. Integração do adapter é TASK-060; limites e UI não estão implementados nesta rodada.

## Proteção de tokens em logs — 19/10/2026

- RN27: logs da aplicação não devem registrar magic link/token, cookies de sessão ou credenciais em caminhos HTTP, params de controller/LiveView, conexões/reconexões e falhas de autenticação tratadas. Mascarar ou omitir somente dados sensíveis, mantendo status, identificação da requisição e diagnóstico não sensível. O token permanece na URL de confirmação consumida pelo fluxo Phoenix; não alterar o protocolo para corrigir logging. Desabilitar RequestLogger de desenvolvimento em produção. Respostas de autenticação usam `Referrer-Policy: no-referrer` para não transportar a URL do link por Referer.
- CA-005-22: captura de logs com sentinelas sintéticas em GET de confirmação, POST de login inválido/válido e eventos/mount LiveView demonstra ausência dos valores sensíveis. Testes cobrem produção e debug configurável sem mascarar o próprio resultado do teste; outras rotas mantêm registro útil. Headers de autenticação e ausência do RequestLogger em prod são verificados; não desligar CSRF, origin check ou autenticação.

Entrega: TASK-065. Logs de proxy/Fly/serviços externos são responsabilidade operacional; o teste da aplicação não comprova sua configuração.

## Contrato histórico do MVP local — substituído no incremento de produção

RN01–RN07 e CA-005-01–06 abaixo preservam a rastreabilidade das TASK-009/037 e de seus aceites. Não autorizam acesso compartilhado depois da TASK-045; as regras vigentes do novo incremento são RN08–RN15 acima.


- RN01: preparar os dados cria o usuário padrão uma única vez, com identificador estável. Repetir seeds não duplica o usuário nem altera seus dados de planejamento.
- RN02: abrir o painel usa automaticamente esse usuário, sem redirecionar para login ou pedir escolha de conta.
- RN03: proprietário de tarefa/label vem do usuário padrão no servidor, nunca de um campo editável ou parâmetro do navegador. Vínculos entre tarefa e label continuam exigindo proprietário compatível.
- RN04: testes criam sua fixture de usuário sem depender de seed global; validações de proprietário podem usar outra fixture para rejeitar IDs incompatíveis. Isso não cria um fluxo de múltiplas contas na interface.

- RN05: em ambiente de desenvolvimento (`dev` da configuração Elixir), acessar o painel ou diretamente o formulário de cadastro garante a existência do usuário de identificador `default` antes de resolver o proprietário. Se ausente, cria somente esse usuário; acessos repetidos, remontagens LiveView e acessos simultâneos reutilizam a mesma identidade. Não escolher o primeiro registro arbitrário do banco.
- RN06: criação automática no acesso fica desabilitada por padrão e em `test`/`prod`. Nesses ambientes, ausência do usuário continua exigindo preparação explícita; testes usam fixtures. Seeds explícitos mantêm seu contrato idempotente. A configuração vem do servidor, nunca de parâmetros da requisição.
- RN07: banco e migrations são pré-requisitos. A criação automática não cria banco, aplica migrations ou mascara erros de persistência; não insere tarefas/labels demonstrativas nem altera dados existentes.

## Cenários de aceite

- CA-005-01: repetir preparação mantém um único usuário padrão.
- CA-005-02: abrir painel permite usar o planejamento sem login; recarregar preserva proprietário e dados.
- CA-005-03: enviar user_id forjado no cadastro não troca o proprietário; label incompatível é rejeitada sem gravação parcial.

- CA-005-04: dado banco migrado em `dev` sem usuário padrão, abrir `/tasks` ou, em cenário independente, `/tasks/new` cria `default` e permite usar a tela sem executar seeds previamente; repetir acesso e conexão LiveView mantém sua identidade.
- CA-005-05: dado usuário padrão com tarefas e labels, repetir acesso em `dev` preserva identidade, timestamps e dados. Se existir apenas outro usuário, cria `default` sem assumir ou alterar a identidade existente. Criações simultâneas convergem para um único `default` pela unicidade já existente.
- CA-005-06: com criação automática desabilitada, resolver usuário ausente não insere registros e mantém o erro de ausência; usuário previamente preparado continua utilizável. Configurações de `test` e `prod` não habilitam a criação automática.
