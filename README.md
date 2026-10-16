# Planner

Planner pessoal para escolher prioridades do dia, manter um backlog e consultar tarefas concluídas. O MVP local está concluído e aprovado em [revisão independente](docs/review.md), com aceite do responsável confirmado em 11/10/2026. O [plano do MVP de produção](docs/prd.md#7-mvp-de-produção--plano-autorizado-em-11102026) adiciona contas por magic link, isolamento, ajustes de tarefas e temas. Contas e isolamento já estão implementados; as demais entregas seguem o plano de tarefas.

A aplicação usa Phoenix, Elixir e PostgreSQL. O servidor roda na máquina; o banco local roda em Docker, com dados persistidos em volume.

## Como rodar

Requer Elixir compatível com `mix.exs` (`~> 1.17`), Erlang/OTP compatível, Node.js/npm para as dependências de frontend e Docker ativo com Compose que suporte `up --wait`.

```sh
cp .env.example .env
```

Edite a senha no `.env` e execute:

```sh
mix setup
mix phx.server
```

Abra [localhost:4000](http://localhost:4000). Para usar o console interativo, execute `iex -S mix phx.server`.

## Comandos úteis

| Comando | O que faz |
| --- | --- |
| `mix setup` | Instala dependências, prepara o banco e compila os assets. |
| `mix phx.server` | Inicia o banco e o servidor. |
| `mix db.up` | Inicia apenas o PostgreSQL e aguarda sua disponibilidade. |
| `mix ecto.setup` | Inicia o banco, cria a base, aplica migrations e seeds. |
| `mix test` | Inicia o banco e executa os testes. |
| `mix ci` | Verifica compilação, formatação, Credo estrito e testes com cobertura mínima de 70%. |
| `mix assets.build` | Instala o frontend pelo lockfile (`npm ci`) e compila CSS/JS. |
| `mix precommit` | Compila com warnings como erros, verifica dependências, formata e testa. |
| `mix cmd node --test assets/test/task_drag.test.mjs` | Testa o ciclo técnico do hook de arraste com SortableJS instalado, sem navegador. Executar após instalar os assets. |
| `mix run priv/repo/seeds.exs` | Executa o arquivo de seeds, atualmente sem criação ou alteração de dados. |
| `mix ecto.reset` | Apaga e recria a base do ambiente atual. |
| `docker compose stop postgres` | Para o banco sem apagar o volume. |

Após atualizar o código de uma instalação existente, aplique as migrations com `mix ecto.migrate` antes de iniciar o servidor. A migration de ordenação preserva os dados e inicializa as posições de backlog/retry.

## Configuração e banco

Mix e Compose leem o `.env`, ignorado pelo Git. Variáveis exportadas no processo têm precedência. Use `KEY=value` sem aspas, espaços, interpolação ou comentários ao final; linhas vazias e comentários em linhas próprias são aceitos.

O Compose usa PostgreSQL 17, publica a porta apenas em `127.0.0.1` e preserva dados no volume `postgres_data`. Os aliases aguardam o healthcheck por até 60 segundos e interrompem a execução se o banco falhar. Desenvolvimento e testes usam bases distintas (`POSTGRES_DB` e `POSTGRES_TEST_DB`); testes paralelos acrescentam `MIX_TEST_PARTITION` ao nome da base.

Alterar credenciais no `.env` não altera um volume já inicializado: ajuste também o usuário no banco existente. Para CI ou banco externo, exporte `PLANNER_SKIP_COMPOSE=true` e as variáveis de conexão de `.env.example`. Produção usa `config/runtime.exs` e não inicia Compose automaticamente.

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

## Temas por conta

O seletor **Tema** no painel oferece **Claro** e **Escuro**, gratuitos para todas as contas. A escolha é confirmada após salvar e acompanha a conta em recargas e novos dispositivos. Login e páginas públicas usam claro; preferências antigas do navegador não são aplicadas. Falhas conservam o último tema confirmado e mostram uma mensagem.

Para alterações na sincronização de tema, execute `mix cmd node --test assets/js/account_theme.test.mjs`. O teste verifica montagem, atualização, reconexão e saída em DOM mínimo; não comprova contraste ou interação real no navegador.

## Sobre o projeto

O fluxo implementado permite selecionar tarefas do backlog para hoje, ordenar prioridades e registrar conclusões. O escopo está no [PRD](docs/prd.md): contas por magic link, interface pt-BR com Gettext, data corrente sem configuração de fuso e recarga manual. A correção de falhas no cadastro foi concluída na [TASK-038](docs/tasks/038-tratar-falha-cadastro.md).

Consulte as [decisões de arquitetura](docs/design.md), o [vocabulário do domínio](docs/ddd.md) e as [tarefas planejadas](docs/tasks/README.md) para acompanhar a evolução.

## CI

O workflow `CI` executa o check **quality** em PRs para `main` e pushes na `main`, usando Elixir 1.20.3, OTP 29 e o Compose existente. Para reproduzir localmente, execute `mix ci` com Docker ativo e `.env` configurado. O comando também instala e compila os assets e verifica vulnerabilidades npm de severidade alta ou crítica. A versão resolvida do SortableJS está em `assets/package-lock.json`. O comando verifica formatação sem corrigir arquivos; a cobertura deve atingir pelo menos 70%, conforme o limiar já configurado em `mix.exs`.

O responsável confirmou a configuração da proteção da `main` e do check obrigatório **quality**.

Para alterações no hook de arraste, execute também o teste JavaScript listado acima; ele é separado dos aliases `precommit` e `ci`. O harness usa o SortableJS do lockfile com DOM e timers mínimos controlados. Cobre cancelamento, restauração e retomada, mas não simula layout, propagação completa de eventos, mouse/touch reais ou patches do LiveView no navegador.

## Testes E2E em containers

O `compose.e2e.yaml` é independente do Compose de desenvolvimento. Constrói o release pelo `Dockerfile` existente e executa Playwright/Chromium na imagem oficial, sem instalar navegadores no Fedora. Requer Docker com Compose; downloads de imagens e dependências ocorrem durante o build.

```sh
docker compose -f compose.e2e.yaml build
docker compose -f compose.e2e.yaml up --abort-on-container-exit --exit-code-from playwright
```

O segundo comando retorna o código de saída dos testes. A aplicação aguarda o PostgreSQL, aplica migrations e passa pelo healthcheck antes de iniciar o navegador. O projeto Compose chama-se `planner-e2e`: não execute esta configuração com o nome do projeto de desenvolvimento.

Os serviços usam rede interna, sem portas publicadas, bind mounts, socket Docker ou acesso ao perfil do navegador pessoal. O runner usa `pwuser`, sem capabilities adicionais, e memória compartilhada própria. Ele compartilha apenas a rede do container da aplicação para acessar `localhost:4000`, compatível com a configuração HTTP local do release. Isso não compartilha a rede do Fedora. Containers compartilham o kernel do host; este ambiente não é uma VM nem uma garantia contra código malicioso.

O banco E2E usa credenciais sintéticas declaradas no Compose e armazenamento em memória (`tmpfs`), perdido quando o container é parado. Não utiliza o `.env` ou o volume `postgres_data` do desenvolvimento. A rede interna impede acesso externo durante os testes; o build precisa de internet. O código e as dependências são copiados para imagens próprias, sem compartilhar `node_modules` com o host.

Antes de remover os containers, copie as evidências:

```sh
docker compose -f compose.e2e.yaml cp playwright:/e2e/playwright-report assets/playwright-report
docker compose -f compose.e2e.yaml cp playwright:/e2e/test-results assets/test-results
docker compose -f compose.e2e.yaml down
```

Relatórios e traces ficam fora do Git. Para repetir com ambiente novo, execute `down` antes de `up`; após alterar testes ou código, execute também `build`. A versão da imagem em `assets/Dockerfile.e2e` deve corresponder exatamente ao Playwright resolvido no lockfile; o build verifica essa correspondência.

Os cenários em `assets/e2e` verificam conexão LiveView na página de login, navegação para cadastro e redirecionamento de visitantes em `/tasks`. Não substituem ExUnit, os testes JavaScript existentes ou o aceite humano. O release não tem `/dev/mailbox`: fluxos autenticados por magic link ainda precisam de infraestrutura própria de e-mail de teste. O ambiente E2E não foi adicionado automaticamente ao CI.

Validação em 15/10/2026: build das duas imagens, migrations no banco descartável e dois testes Chromium aprovados, com saída 0 e cópia do relatório. `mix precommit` e `mix ci` passaram com 245 testes e cobertura de 93,71%. Os containers e a rede E2E foram removidos após a conferência; imagens e relatório local foram preservados.

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

Decisão de 16/10/2026, ainda não implementada: [TASK-055](docs/tasks/055-comando-e2e.md) entregará `mix e2e` como entrada local separada de `mix ci` e `mix precommit`, incluindo preparação, execução, coleta de evidências e limpeza. Até sua integração, esse comando não está disponível; o esboço em containers está incluído nesta entrega, mas ainda não fornece o comando Mix nem integração ao CI.

A [TASK-056](docs/tasks/056-cenarios-e2e.md) ampliará a cobertura para fluxos autenticados. A [TASK-057](docs/tasks/057-e2e-github-ci.md) executará o mesmo comando no check obrigatório `quality` do GitHub, com artefatos em falhas. Tarefas de front e toda revisão de código/autoavaliação seguirão a [política E2E](docs/prd.md#e2e-obrigatório--decisão-de-16102026). Pré-requisitos e opções definitivos serão documentados aqui na entrega do runner.
