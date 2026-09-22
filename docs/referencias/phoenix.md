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
