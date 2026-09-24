# Planner

Planner pessoal para escolher prioridades do dia, manter um backlog e consultar tarefas concluídas. O produto está em especificação; a implementação do domínio ainda não começou.

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

Depois de preparar o banco com `mix ecto.setup` (também chamado por `mix setup`), os seeds garantem uma identidade persistente com identificador `default`. Para repetir somente essa preparação em um banco já migrado, execute `mix run priv/repo/seeds.exs`. Isso não duplica o usuário nem substitui seus dados.

O servidor consulta essa identidade por `Planner.Accounts.get_default_user!/0`; `Planner.Accounts.ensure_default_user!/0` a cria de forma idempotente durante a preparação. Não há autenticação ou escolha de conta. Os testes criam usuários isolados por fixture, sem depender dos seeds globais.

## Sobre o projeto

O fluxo planejado é selecionar tarefas do backlog para hoje, ordenar prioridades e registrar conclusões. O escopo mínimo está no [PRD](docs/prd.md): usuário padrão sem login, interface pt-BR com Gettext, data corrente sem configuração de fuso e recarga manual. Essas mudanças ainda serão implementadas.

Consulte as [decisões de arquitetura](docs/design.md), o [vocabulário do domínio](docs/ddd.md) e as [tarefas planejadas](docs/tasks/README.md) para acompanhar a evolução.

## CI

O workflow `CI` executa o check **quality** em PRs para `main` e pushes na `main`, usando Elixir 1.20.3, OTP 29 e o Compose existente. Para reproduzir localmente, execute `mix ci` com Docker ativo e `.env` configurado. O comando verifica formatação sem corrigir arquivos; a cobertura deve atingir pelo menos 70%, conforme o limiar já configurado em `mix.exs`.

O responsável confirmou a configuração da proteção da `main` e do check obrigatório **quality**.
