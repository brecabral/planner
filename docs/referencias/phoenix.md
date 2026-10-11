# Phoenix: rotas, contexto web e HTTP

Origem: regras do gerador Phoenix anteriormente em `AGENTS.md`, traduzidas em 22/09/2026. Aplicação: rotas, controllers, helpers e clientes HTTP.

- O projeto usa Phoenix 1.8; conferir versões efetivas em `mix.lock` antes de depender de uma API.
- O alias de um bloco `scope` prefixa os módulos das rotas. Não repetir `PlannerWeb` nem criar aliases extras para essas definições.
- Não usar `Phoenix.View`, desnecessário nesta versão.
- Helpers compartilhados ficam em `html_helpers` de `lib/planner_web.ex`; imports e aliases ali ficam disponíveis às camadas que usam esses helpers.
- Usar a dependência existente `Req` para HTTP. Evitar `HTTPoison`, `Tesla` e `:httpc`.

```elixir
scope "/admin", PlannerWeb.Admin do
  pipe_through :browser
  live "/overview", OverviewLive
end
```

Arquitetura escolhida pelo projeto: [design](../design.md). Esta referência descreve convenções técnicas, não define o domínio.

## Scaffolds e scopes

Na versão instalada, a ajuda de `phx.gen.auth`, `phx.gen.context`, `phx.gen.schema`, `phx.gen.live` e `phx.gen.release` foi conferida localmente em 23/09/2026. Os comandos concretos de cada entrega ficam na tarefa; consultar a ajuda novamente antes de executá-los.

- Auth cria identidade, tokens, helpers e um scope; context/live usam o scope configurado, que acrescenta o proprietário. Não duplicar o campo de proprietário nos atributos do comando.
- `phx.gen.live --no-context` também implica `--no-schema`; serve para gerar interface sobre um contexto já produzido. Os testes gerados precisam ser adaptados às APIs existentes e ao fluxo autorizado.
- Schema aceita enum e referências; migration e changeset gerados exigem revisão de defaults, campos opcionais, unicidade e constraints do domínio.
- A geração de CRUD não aprova edição/exclusão ou entrada livre de campos controlados pelo servidor. Remover essas superfícies quando não pertencem à spec.
- Release gera scripts de servidor/migration; a opção Docker também cria arquivos de container. Nenhuma dessas gerações publica a aplicação.
