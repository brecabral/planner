# Planner

Planner pessoal para escolher prioridades do dia, manter um backlog e consultar tarefas concluídas. O MVP local está concluído e aprovado em [revisão independente](docs/review.md).

A aplicação usa Phoenix, Elixir e PostgreSQL. O servidor roda na máquina; o banco local roda em Docker, com dados persistidos em volume.

## Como rodar

Requer Elixir compatível com `mix.exs` (`~> 1.17`), Erlang/OTP compatível e Docker ativo com Compose que suporte `up --wait`.

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
| `mix precommit` | Compila com warnings como erros, verifica dependências, formata e testa. |
| `mix run priv/repo/seeds.exs` | Prepara o usuário padrão; repetir preserva sua identidade e dados. |
| `mix ecto.reset` | Apaga e recria a base do ambiente atual. |
| `docker compose stop postgres` | Para o banco sem apagar o volume. |

## Configuração e banco

Mix e Compose leem o `.env`, ignorado pelo Git. Variáveis exportadas no processo têm precedência. Use `KEY=value` sem aspas, espaços, interpolação ou comentários ao final; linhas vazias e comentários em linhas próprias são aceitos.

O Compose usa PostgreSQL 17, publica a porta apenas em `127.0.0.1` e preserva dados no volume `postgres_data`. Os aliases aguardam o healthcheck por até 60 segundos e interrompem a execução se o banco falhar. Desenvolvimento e testes usam bases distintas (`POSTGRES_DB` e `POSTGRES_TEST_DB`); testes paralelos acrescentam `MIX_TEST_PARTITION` ao nome da base.

Alterar credenciais no `.env` não altera um volume já inicializado: ajuste também o usuário no banco existente. Para CI ou banco externo, exporte `PLANNER_SKIP_COMPOSE=true` e as variáveis de conexão de `.env.example`. Produção usa `config/runtime.exs` e não inicia Compose automaticamente.

## Usuário padrão do MVP

Em desenvolvimento, com banco criado e migrations aplicadas, abrir `/tasks` ou diretamente `/tasks/new` cria o usuário de identificador `default` se ele ainda não existir. Novos acessos e conexões reutilizam a mesma identidade, preservando timestamps, tarefas e labels. Não é necessário executar seeds antes desse primeiro acesso; o boot do servidor não cria usuários.

A opção `:auto_create_default_user` da aplicação `:planner` fica desabilitada em `config/config.exs` e habilitada somente em `config/dev.exs`. `Planner.Accounts.resolve_default_user!/0` aplica essa configuração nas duas telas. Em `test` e `prod`, a ausência da identidade continua gerando erro e exige preparação explícita; banco e migrations permanecem pré-requisitos em todos os ambientes.

`mix ecto.setup` (também chamado por `mix setup`) continua executando os seeds. Para repetir somente essa preparação em um banco já migrado, execute `mix run priv/repo/seeds.exs`: `Planner.Accounts.ensure_default_user!/0` garante a identidade sem duplicar ou substituir dados. A consulta `Planner.Accounts.get_default_user!/0` permanece estrita. Não há autenticação ou escolha de conta; testes usam fixtures isoladas, sem seeds globais.

## Sobre o projeto

O fluxo implementado permite selecionar tarefas do backlog para hoje, ordenar prioridades e registrar conclusões. O escopo mínimo está no [PRD](docs/prd.md): usuário padrão sem login, interface pt-BR com Gettext, data corrente sem configuração de fuso e recarga manual. A correção de falhas no cadastro foi concluída na [TASK-038](docs/tasks/038-tratar-falha-cadastro.md). A validação humana da interface permanece pendente, fora do gate do MVP.

Consulte as [decisões de arquitetura](docs/design.md), o [vocabulário do domínio](docs/ddd.md) e as [tarefas planejadas](docs/tasks/README.md) para acompanhar a evolução.

## CI

O workflow `CI` executa o check **quality** em PRs para `main` e pushes na `main`, usando Elixir 1.20.3, OTP 29 e o Compose existente. Para reproduzir localmente, execute `mix ci` com Docker ativo e `.env` configurado. O comando verifica formatação sem corrigir arquivos; a cobertura deve atingir pelo menos 70%, conforme o limiar já configurado em `mix.exs`.

O responsável confirmou a configuração da proteção da `main` e do check obrigatório **quality**.
