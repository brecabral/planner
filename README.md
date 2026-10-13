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
| `mix run priv/repo/seeds.exs` | Prepara o usuário padrão; repetir preserva sua identidade e dados. |
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

`/dev/mailbox` e `/dev/dashboard` só são habilitados em desenvolvimento e ficam ausentes na configuração de produção. O teste local valida a aplicação, mas não comprova entrega externa, reputação de remetente ou configuração de domínio. A definição e validação do provedor real pertencem à preparação de produção; esta etapa não autoriza publicação.

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

## Evolução planejada para produção

O [plano de tarefas](docs/tasks/README.md) prevê auth padrão Phoenix com magic link, home direcionada ao login/dashboard, teste local de e-mail com Swoosh, temas claro/escuro por conta e preparação de release. Autenticação, isolamento por conta e teste local de e-mail já estão implementados. As tarefas de produção documentarão aqui configuração e recuperação depois de definidos e validados. Hospedagem, domínio e provedor de e-mail estão pendentes. Créditos e loja ficam para evolução futura.
