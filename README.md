# Planner

Planner pessoal para escolher prioridades do dia, manter um backlog e consultar tarefas concluídas. O MVP local está concluído e aprovado em [revisão independente](docs/tasks/008-aceite-mvp.md), com aceite do responsável confirmado em 11/10/2026. O [plano do MVP de produção](docs/prd.md#7-mvp-de-produção--plano-autorizado-em-11102026) adiciona contas por magic link, isolamento, ajustes de tarefas e temas. Contas e isolamento já estão implementados; as demais entregas seguem o plano de tarefas.

A aplicação usa Phoenix, Elixir e PostgreSQL. O servidor roda na máquina; o banco local roda em Docker, com dados persistidos em volume.

## Como rodar

Requer Elixir compatível com `mix.exs` (`~> 1.17`), Erlang/OTP compatível, Node.js/npm para as dependências de frontend Just, Bash, GNU coreutils (`timeout`) e Docker ativo com Compose que suporte `up --wait`. Python 3 é usado nos testes de tooling.

```sh
cp .env.example .env
```

Edite a senha no `.env` e execute:

```sh
just setup
just run
```

Abra [localhost:4000](http://localhost:4000). Para usar o console interativo, execute `just console`.

## Comandos úteis

| Comando | O que faz |
| --- | --- |
| `just` | Lista os comandos locais para desenvolvedores e todos os perfis de agentes. |
| `just setup` / `just run` | Prepara dependências/banco/assets; ou sobe o banco local e inicia Phoenix. |
| `just db-up` / `just db-down` | Inicia com healthcheck ou remove containers/rede, preservando o volume local. |
| `just db-clean` | Remove também os dados locais; exige confirmação. Não é chamado automaticamente. |
| `just db-status` / `just db-logs` | Inspeciona disponibilidade e logs do banco local. |
| `just db-test-up` / `just db-test-down` / `just db-test-clean` | Opera o PostgreSQL descartável exclusivo dos testes; parar já descarta seus dados. |
| `just test [arquivo/opções]` | Sobe banco de teste e executa ExUnit, aceitando argumentos. |
| `just ci` | Qualidade Elixir, cobertura mínima de 70%, assets, testes JavaScript e auditoria npm. |
| `just precommit` | Sobe banco de teste e executa o alias Mix de formatação, compilação e testes. |
| `just js-test` | Instala frontend pelo lockfile e testa arraste e sincronização de tema. |
| `just tooling-test` | Testa isolamento das receitas de banco e falhas, interrupção e coleta do runner com Docker simulado. |
| `just e2e` | Constrói imagens, sobe banco/app isolados, executa toda a suíte, coleta evidências e derruba os recursos. |
| `just check` | Executa qualidade e E2E para revisão de código/autoavaliação. |
| `just status` / `just diff` / `just tasks` | Inspeção de alterações e cabeçalhos do plano para qualquer perfil. |
| `just commit "mensagem"` | Comita somente o que já foi selecionado no staging; não adiciona arquivos. |
| `just migrate` | Sobe banco local e aplica migrations. |
| `mix assets.build` / `mix assets.deploy` | Compila assets Phoenix, com instalação npm pelo lockfile. |
| `mix run priv/repo/seeds.exs` | Executa seeds, atualmente sem criação ou alteração de dados. |
| `mix ecto.reset` | Apaga e recria a base configurada; exige banco previamente disponível. |

Just concentra operação local. Mix executa tarefas Elixir/Phoenix e build de assets; nenhum alias inicia Docker. Planejamento e revisões documentais usam inspeção documental, sem precisar subir banco ou navegador. Cada perfil comita suas alterações ao encerrar a rodada, selecionando os arquivos próprios antes de `just commit`.

Após atualizar o código de uma instalação existente, aplique as migrations com `mix ecto.migrate` antes de iniciar o servidor. A migration de ordenação preserva os dados e inicializa as posições de backlog/retry.

## Configuração e banco

Mix e Compose leem o `.env`, ignorado pelo Git. Variáveis exportadas no processo têm precedência. Use `KEY=value` sem aspas, espaços, interpolação ou comentários ao final; linhas vazias e comentários em linhas próprias são aceitos.

O Compose usa PostgreSQL 17, publica a porta apenas em `127.0.0.1` e preserva dados no volume `postgres_data`. As receitas Just aguardam o healthcheck por até 60 segundos e interrompem a execução se o banco falhar. O banco de desenvolvimento é persistente. `just test`, `just ci` e `just precommit` usam outro projeto Compose (`planner-test`), com PostgreSQL em memória na porta 55432 e credenciais sintéticas. A opção de projeto nas receitas fixa `planner-test` mesmo quando `COMPOSE_PROJECT_NAME` está exportado; subida, parada e limpeza usam essa mesma identidade, com arquivo Compose e env-file explícitos. `PLANNER_TEST_PORT` permite mudar essa porta. Esses comandos mantêm o banco de teste disponível; `just db-test-down` o remove. Testes paralelos acrescentam `MIX_TEST_PARTITION` ao nome da base.

Alterar credenciais no `.env` não altera um volume já inicializado: ajuste também o usuário no banco existente. Para CI ou banco externo, exporte as variáveis de conexão de `.env.example` e use Mix diretamente; `PLANNER_SKIP_COMPOSE` foi removida. Produção usa `config/runtime.exs` e não inicia Compose automaticamente.

## Publicação planejada na Fly.io com Neon e Resend

Decisão de 19/10/2026: Fly.io com uma única instância de aplicação, PostgreSQL no Neon e Resend via Swoosh. A escolha está registrada em [D24](docs/design.md#d24--flyio-neon-resend-e-configuração-por-url). Ainda faltam nome do app, região, domínio e remetente. Não há publicação ou integração remota comprovada por este registro.

O responsável cuidará da Fly por fora do desenvolvimento. “App” é o identificador escolhido na Fly; região é a localização da aplicação e do banco Neon, preferencialmente próximas para reduzir latência. O domínio próprio será comprado posteriormente; a configuração pode usar inicialmente o host atribuído pela Fly. Credenciais ficam em Fly Secrets, não no repositório. Essas escolhas operacionais não impedem implementar/testar com valores sintéticos.

Backup e recuperação também ficam na operação, sem tarefa de desenvolvimento. O Neon oferece recuperação dentro de uma janela de histórico que depende do plano/configuração; conferir a janela no projeto escolhido, sem pressupor retenção ilimitada. Referência: [restauração Neon](https://neon.com/docs/postgres/backup-restore/branch-restore).

O `.env.example` inclui uma `DATABASE_URL` literal para a mudança do desenvolvimento planejada na [TASK-061](docs/tasks/061-database-url-desenvolvimento.md). **Hoje `config/database.exs` ainda usa os campos `POSTGRES_*`, não essa URL.** Quando a mudança for implementada, mantenha usuário, senha, porta e banco da URL alinhados aos campos usados pelo Compose; caracteres especiais nas credenciais devem ser codificados para URL. Testes continuarão com configuração própria e `MIX_TEST_PARTITION`, sem consumir a URL de desenvolvimento. O `.env` privado existente não é modificado por esta documentação.

Os exemplos de produção estão comentados. O release lê variáveis do processo, não carrega o `.env` local. Na Fly, use Secrets para `DATABASE_URL`, `SECRET_KEY_BASE` e `RESEND_API_KEY`; valores públicos como `PHX_HOST`, `PORT` e remetente podem ficar no ambiente do app. `PHX_HOST` recebe apenas o host, sem esquema; `PORT` deve corresponder à porta interna do serviço Fly. A integração Neon ainda exige configurar TLS com verificação de certificado. Não usar as credenciais sintéticas de teste em produção.

`SECRET_KEY_BASE` é o segredo do endpoint para derivar chaves criptográficas. Consulte `mix help phx.gen.secret` e gere-o com `mix phx.gen.secret`; mantenha o mesmo valor entre deploys. Sua troca invalida dados assinados com a chave anterior. Não copiar o segredo de desenvolvimento para produção.

A integração Resend está planejada na [TASK-060](docs/tasks/060-configurar-resend.md): `RESEND_API_KEY`, `MAIL_FROM_EMAIL` e `MAIL_FROM_NAME` ainda não são lidas pelo código. A tarefa implementará o adapter e o remetente configuráveis; conta, credenciais e domínio verificado são preparados pelo responsável. Desenvolvimento permanece com mailbox local e testes sem envio externo.

Preparação adicional ainda não implementada: [TLS Neon](docs/tasks/062-tls-postgresql-neon.md), [healthcheck](docs/tasks/063-healthcheck-minimo.md), [limites de e-mail](docs/tasks/064-limitar-envio-magic-link.md) e [proteção de tokens em logs](docs/tasks/065-proteger-tokens-logs.md). O healthcheck planejado é GET/HEAD `/health`, com 200 e corpo mínimo `ok` no GET, sem diagnóstico ou consulta ao banco/Resend; não comprova prontidão das dependências. Configurar o monitor Fly permanece operação externa.

As variáveis abaixo são **contrato planejado**, ainda sem efeito no código. Serão lidas/validadas na inicialização, sem leitura por tentativa ou tick; mudar valores exige reiniciar a aplicação.

| Variável | Padrão planejado | Efeito |
| --- | --- | --- |
| `DATABASE_SSL` | `true` em prod | TLS PostgreSQL verificado; `false` somente como exceção explícita para bancos isolados de teste. |
| `AUTH_EMAIL_COOLDOWN_SECONDS` | `60` | Intervalo mínimo por e-mail. |
| `AUTH_EMAIL_MAX_PER_HOUR` | `5` | Máximo por e-mail na janela móvel de uma hora. |
| `AUTH_IP_MAX_PER_HOUR` | `20` | Máximo por IP na janela móvel de uma hora. |
| `AUTH_EMAIL_MAX_PER_DAY` | `90` | Teto global de tentativas de entrega por dia UTC, incluindo falhas. |
| `AUTH_TRUST_FLY_PROXY` | `false` | Habilitar somente com entrada exclusiva pelo Fly Proxy para obter IP validado de `Fly-Client-IP`. |

Limites valem no servidor para cadastro/login e eventos LiveView; o botão e a contagem na mesma tela apenas apresentam a espera. Reserva no PostgreSQL persiste entre reinícios. IPs compartilhados por redes/NAT compartilham limite; teto diário protege o gasto, mas não garante disponibilidade sob abuso. Env de limites aceita somente inteiros positivos. A quota do provedor pode ser consumida por outros envios fora do app; limites Resend e erros 429 continuam aplicáveis ([documentação](https://resend.com/docs/api-reference/rate-limit)).

Tokens também podem aparecer em logs de proxy e serviços externos: o responsável deve tratar esses sistemas na operação. A TASK-065 cobre somente logging/headers da aplicação, sem comprovar políticas externas.

Instale a CLI pela [documentação oficial da Fly](https://docs.fly.io/flyctl/install). Na futura preparação do app, `fly launch --no-deploy --no-db` evita publicação imediata e banco Fly adicional. Revise os arquivos gerados preservando o Dockerfile existente. O `fly.toml` deverá configurar `release_command = "/app/bin/migrate"` na seção `[deploy]`; `fly deploy` construirá a imagem e executará essa etapa antes de atualizar a aplicação. Esses comandos criam ou alteram recursos remotos e não foram executados nesta rodada. Definir uma única instância explicitamente na operação; essa escolha não oferece redundância da aplicação.

O script versionado é `rel/overlays/bin/migrate` (singular), copiado para `bin/migrate` no release e disponível como `/app/bin/migrate` na imagem. Ele chama `Planner.Release.migrate/0`, que usa `Ecto.Migrator` para aplicar as migrations pendentes de `priv/repo/migrations`. Phoenix não faz isso automaticamente ao iniciar o servidor; `bin/server` inicia a aplicação. Falha na etapa de release interrompe o deploy, mas não desfaz automaticamente migrations já aplicadas. Referência: [configuração da Fly](https://docs.fly.io/reference/configuration).

## Autenticação e dados por conta

O cadastro é aberto por e-mail e o acesso usa exclusivamente magic link, sem senha. `/` leva visitantes a `/users/log-in`; contas autenticadas seguem para `/tasks`. O cadastro de tarefas em `/tasks/new` também exige sessão. Após confirmar o link, o usuário acessa seu planejamento; “Sair” encerra a sessão e retorna ao login. Links expiram em 15 minutos e só podem ser consumidos uma vez.

Tarefas, labels, histórico e as três escolhas diárias pertencem à conta autenticada. Novas contas começam sem os dados das demais. A identidade antiga `default` e seus registros são preservados sem e-mail de acesso, não são transferidos para o primeiro cadastro e não ficam disponíveis a visitantes. Nenhum ambiente cria ou resolve automaticamente um usuário compartilhado. Seeds não criam contas nem alteram o legado; testes preparam fixtures isoladas.

### Testar magic link localmente

Com a aplicação iniciada em desenvolvimento pelos passos acima, o Swoosh usa `Swoosh.Adapters.Local`: nenhuma credencial de e-mail é necessária e nenhuma mensagem é enviada para fora da aplicação.

1. Abra `/users/register`, cadastre `primeira@example.com` (ou outro endereço ainda não cadastrado) e aguarde o redirecionamento para login.
2. Abra [a mailbox local](http://localhost:4000/dev/mailbox) em outra aba. Selecione a mensagem destinada à conta cadastrada e copie a URL de confirmação para a barra do navegador. Na página aberta, confirme a conta usando um dos botões de entrada. O dashboard em `/tasks` começa vazio.
3. Crie uma tarefa para essa conta e clique em **Sair**. Cadastre `segunda@example.com`, abra sua mensagem na mailbox e confirme a entrada. O dashboard da segunda conta não deve mostrar a tarefa da primeira.
4. Saia novamente. Em `/users/log-in`, solicite um link para a primeira conta; atualize a mailbox e abra a mensagem mais recente desse destinatário. Conclua a entrada pelo botão da página para voltar às tarefas da primeira conta.
5. Para testar expiração, solicite outro link sem consumi-lo e aguarde mais de 15 minutos. Abrir esse link deve retornar ao login com aviso de link inválido ou expirado. Solicite um novo link no formulário de login e use a mensagem mais recente. Para testar uso único, saia após consumir um link e tente abri-lo novamente: ele também deve ser recusado. Não altere o TTL nem registros do banco para este procedimento.

Use sempre o mesmo host nas abas de login e mailbox. Por padrão, o endereço é `http://localhost:4000`; `PORT=4107 mix phx.server` muda a porta HTTP e os links locais gerados. Para usar outro host local, configure `url: [host: "127.0.0.1"]` no `PlannerWeb.Endpoint` de `config/dev.exs`, reinicie e abra `http://127.0.0.1:4107`. Se definir `url: [port: ...]` explicitamente, mantenha essa porta igual à HTTP configurada por `PORT`. O servidor continua vinculado ao loopback.

A mailbox guarda mensagens em memória e é esvaziada ao reiniciar a aplicação; contas e tarefas persistem no banco. Depois de reiniciar, solicite novo link em vez de cadastrar novamente o mesmo e-mail. A mensagem genérica de login não comprova entrega: confira a mailbox. Em testes, `Swoosh.Adapters.Test` captura destinatário e link sem envio real; `mix test test/planner_web/local_magic_link_test.exs` verifica também o adapter local, troca de contas e falha de entrega sem sessão indevida.

`/dev/mailbox` e `/dev/dashboard` só são habilitados em desenvolvimento e ficam ausentes na configuração de produção. O teste local valida a aplicação, mas não comprova entrega externa, reputação de remetente ou configuração de domínio. O usuário pode configurar posteriormente o adapter Swoosh, as credenciais e o remetente do provedor real. Essa configuração e a publicação estão fora da entrega de código; o adapter local não envia e-mail externo.

Os pontos existentes para essa configuração são `config/runtime.exs` (adapter de `Planner.Mailer` e credenciais externas), `config/prod.exs` (cliente HTTP do Swoosh, quando necessário) e `lib/planner/accounts/user_notifier.ex` (remetente atual `Planner <contact@example.com>`). O remetente é definido no código; não há variável de ambiente para substituí-lo. `PHX_HOST` em produção define o host dos links, com HTTPS na URL pública. Os exemplos comentados de adapter não representam um provedor configurado. Não coloque credenciais no repositório nem habilite as rotas de desenvolvimento no release para capturar mensagens.

## Temas por conta

O seletor **Tema** no painel oferece **Claro** e **Escuro**, gratuitos para todas as contas. A escolha é confirmada após salvar e acompanha a conta em recargas e novos dispositivos. Login e páginas públicas usam claro; preferências antigas do navegador não são aplicadas. Falhas conservam o último tema confirmado e mostram uma mensagem.

Para alterações na sincronização de tema, execute `mix cmd node --test assets/js/account_theme.test.mjs`. O teste verifica montagem, atualização, reconexão e saída em DOM mínimo; não comprova contraste ou interação real no navegador.

## Sobre o projeto

O fluxo implementado permite selecionar tarefas do backlog para hoje, ordenar prioridades e registrar conclusões. O escopo está no [PRD](docs/prd.md): contas por magic link, interface pt-BR com Gettext, data corrente sem configuração de fuso e recarga manual. A correção de falhas no cadastro foi concluída na [TASK-038](docs/tasks/038-tratar-falha-cadastro.md).

Consulte as [decisões de arquitetura](docs/design.md), o [vocabulário do domínio](docs/ddd.md) e as [tarefas planejadas](docs/tasks/README.md) para acompanhar a evolução.

## CI

O check protegido **quality** mantém PRs para `main` e pushes na `main`. O workflow usa Elixir 1.20.3/OTP 29, Node 24 e seu próprio serviço PostgreSQL 17, com bases separadas para ExUnit e E2E. Executa explicitamente compilação, formato, Credo, cobertura, build de assets, testes JavaScript e auditoria npm; não chama Just, Compose local ou `mix ci`. O gate local completo é `just check`. A cobertura mínima de 70% continua definida em `mix.exs`. O responsável já confirmou a proteção da `main` e o check obrigatório; esta entrega não altera essa configuração remota.

No mesmo job, o workflow instala Chromium pelo lockfile, constrói o release, aplica migrations na base E2E e espera HTTP por até 180 segundos antes de executar toda a suíte Playwright (limite de dez minutos). Falha de setup, teste ou gate impede `quality` verde. O job tem limite de 30 minutos. O container de release usa rede do runner efêmero; o serviço PostgreSQL é administrado pelo GitHub. Não reutiliza a rede interna do Compose local.

Logs de build/migration/aplicação e cleanup ficam em `tmp/ci-e2e`; Playwright produz `assets/playwright-report` e `assets/test-results`. Coleta/remoção e upload usam `always()`, com artefato `e2e-<run_id>-<run_attempt>` retido por 14 dias. Falhas precoces podem não produzir relatório. O workflow não depende de artefatos locais. A reprodução local dos passos não comprova execução remota: o resultado real deve ser conferido no PR após publicação autorizada.

## Testes E2E em containers

O `compose.e2e.yaml` é independente do Compose de desenvolvimento. Constrói o release pelo `Dockerfile` existente e executa Playwright/Chromium na imagem oficial, sem instalar navegadores no Fedora. Requer Docker com Compose; downloads de imagens e dependências ocorrem durante o build.

```sh
just e2e
```

Cada execução cria um projeto Compose exclusivo, sem ler `.env`, publicar portas ou compartilhar volumes de desenvolvimento. O banco usa `tmpfs` e credenciais sintéticas. A aplicação aplica migrations e aguarda healthcheck; readiness tem limite de 180 segundos e testes de dez minutos. Playwright usa `pwuser`, rede interna compartilhada apenas com a aplicação, sem socket Docker ou perfil pessoal. Build precisa de rede; containers compartilham o kernel do host.

O caminho é impresso no começo e no fim: `tmp/e2e/run-XXXXXXXX/`. Contém `project.txt`, `build.log`, `startup.log`, `tests.log`, `containers.log`, `cleanup.log`, `exit-code.txt`, `playwright-report/index.html` e `test-results/` com traces/screenshots disponíveis. Falhas precoces podem não produzir relatório de navegador. Relatórios são copiados antes de remover containers, rede e volumes próprios, inclusive em falhas e sinais INT/TERM. Falha de coleta ou limpeza reprova uma execução anteriormente verde; a falha original é preservada no `exit-code.txt`. Just também retorna erro, podendo normalizar o código do script.

Em encerramento forçado (SIGKILL), queda da máquina ou falha de Docker, consulte `project.txt` e `cleanup.log`; após recuperar Docker, remova somente o projeto afetado:

```sh
docker compose --env-file /dev/null -f compose.e2e.yaml -p NOME_DO_PROJECT_TXT down --volumes --remove-orphans
```

Execuções concorrentes têm projetos e pastas distintos. Imagens/cache são preservados. A versão da imagem em `assets/Dockerfile.e2e` deve corresponder ao Playwright do lockfile; o build verifica isso. `just tooling-test` verifica o contrato do runner com Docker simulado, sem substituir E2E real.

A suíte mantém os cenários públicos e adiciona contas independentes para cota, labels, devolução, conclusão/histórico, isolamento entre contas, exclusão, ordem por menu/mouse/touch, diálogo e temas em desktop/320 px. Verifica resultados persistidos após recarga e cores computadas; não valida entrega real de e-mail nem substitui avaliação estética. Touch usa eventos do Chromium em contexto móvel, sem comprovar hardware físico.

As fixtures privadas em `test/support/e2e/accounts.exs` registram contas sintéticas e emitem tokens pelo mecanismo existente; os testes consomem o link pela tela normal de confirmação. Cada cenário recebe duas identidades próprias, sem compartilhar cota/dados. No Compose, a preparação executa no container de release após migrations e escreve um manifesto em volume temporário exclusivo, montado somente para leitura no Playwright. Não há endpoint de bypass nem socket Docker no navegador. O manifesto contém tokens sintéticos e desaparece com a limpeza do projeto.

No GitHub, o helper usa `docker exec "$E2E_CONTAINER" /app/bin/planner rpc` com o mesmo script privado, lido do checkout; não depende de Just nem de arquivo compilado no release. Falha na preparação, token incompatível ou ausência do container/manifesto reprova a suíte explicitamente. Os artefatos podem conter tokens dessas contas descartáveis. A configuração não faz retries; repetição da suíte pelo comando canônico cria nova base e novas contas.

## Release local

O `Dockerfile` gera um release de produção com assets compilados pelo lockfile, nove migrations e scripts `bin/server`/`bin/migrate`. O estágio final roda como `nobody`, sem Mix, Node.js ou Compose. `.dockerignore` exclui `.env`, chaves e artefatos de desenvolvimento. O build precisa de acesso aos registries de imagens, pacotes e assets; não publica a imagem.

Procedimento validado em 14/10/2026, com Docker e Python 3 para gerar configuração temporária. Use nomes livres para os recursos abaixo. O PostgreSQL de smoke tem rede interna própria, sem porta publicada nem volume compartilhado com desenvolvimento. A configuração é exclusiva desse teste; não reutilize o `.env` de desenvolvimento.

```sh
docker build -t planner:task-011 .
python3 - <<'PY'
import os, secrets
path = "/tmp/planner-release-task011.env"
fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
password = secrets.token_hex(24)
content = (
    "POSTGRES_USER=planner_smoke\nPOSTGRES_DB=planner_release_smoke\n"
    + "POSTGRES_PASSWORD=" + password + "\n"
    + "DATABASE_URL=ecto://planner_smoke:" + password
    + "@planner-release-db/planner_release_smoke\n"
    + "SECRET_KEY_BASE=" + secrets.token_hex(64) + "\n"
    + "PHX_HOST=localhost\nPORT=4000\n"
)
os.write(fd, content.encode())
os.close(fd)
PY
docker network create --internal planner-release-smoke
docker run -d --name planner-release-db --network planner-release-smoke \
  --env-file /tmp/planner-release-task011.env postgres:17
```

Confirme que o banco está pronto antes de aplicar as migrations. O comando de migration não cria banco, executa seeds nem reseta dados.

```sh
docker exec planner-release-db pg_isready -U planner_smoke -d planner_release_smoke
docker run --rm --network planner-release-smoke \
  --env-file /tmp/planner-release-task011.env planner:task-011 /app/bin/migrate
docker run -d --name planner-release-app --network planner-release-smoke \
  --env-file /tmp/planner-release-task011.env \
  -p 127.0.0.1:4107:4000 planner:task-011
```

Abra [localhost:4107](http://localhost:4107). `/`, `/tasks` e `/tasks/new` redirecionam visitantes ao login; `/users/log-in` e os assets respondem com sucesso. `/dev/mailbox` e `/dev/dashboard` retornam 404. Esse smoke usa HTTP no loopback, permitido pela configuração existente; a URL pública configurada em produção usa HTTPS. O release não configura entrega real de e-mail e não oferece mailbox: para exercitar cadastro e links sem envio externo, use o procedimento de desenvolvimento acima.

Para repetir migrations e reiniciar preservando o mesmo banco:

```sh
docker run --rm --network planner-release-smoke \
  --env-file /tmp/planner-release-task011.env planner:task-011 /app/bin/migrate
docker restart planner-release-app
```

A repetição foi validada com duas contas sintéticas: contas, tarefas, labels, cotas, tokens de sessão, concessões e preferências permaneceram idênticos; tokens continuaram válidos e consultas conservaram o isolamento. Essa verificação via API do release não substitui o aceite integrado em navegador. O OTP emitiu aviso sobre `libsctp.so.1` ausente; PostgreSQL e HTTP por TCP funcionaram normalmente.

Para encerrar o smoke sem apagar seus dados:

```sh
docker stop planner-release-app planner-release-db
```

Os containers, a rede, a imagem e o arquivo temporário ficam disponíveis para inspeção. Mantenha o arquivo de configuração restrito: ele contém credenciais de teste. Ao usar outro PostgreSQL, forneça `DATABASE_URL` e `SECRET_KEY_BASE` externamente; `PHX_HOST`, `PORT` e `POOL_SIZE` ajustam host público, porta de escuta e pool. `bin/server` habilita o servidor; `bin/migrate` aplica apenas migrations pendentes. Hospedagem, provedor de e-mail e publicação permanecem sob responsabilidade do usuário.

## Evolução planejada para produção

O [plano de tarefas](docs/tasks/README.md) prevê auth padrão Phoenix com magic link, home direcionada ao login/dashboard, teste local de e-mail com Swoosh, temas claro/escuro por conta e preparação de release. Autenticação, isolamento por conta e teste local de e-mail já estão implementados. A entrega dos agentes termina no código funcional e no release local validado, com procedimentos testados documentados aqui. Hospedagem, domínio, configuração do provedor de e-mail, publicação e backups ficam sob responsabilidade do usuário e não são pendências da fila de código. Créditos e loja ficam para evolução futura.

## Evolução planejada do E2E

A [TASK-055](docs/tasks/055-comando-e2e.md) fornece a operação local por Just. A [TASK-057](docs/tasks/057-e2e-github-ci.md) mantém infraestrutura própria no GitHub e executa todos os cenários disponíveis; a [TASK-056](docs/tasks/056-cenarios-e2e.md) amplia a suíte para fluxos autenticados. Tarefas de front e revisões de código/autoavaliações seguem a [política E2E](docs/prd.md#e2e-obrigatório--decisão-de-16102026). Os estados e evidências reais estão nos arquivos das tarefas.
