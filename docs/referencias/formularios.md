# Formulários Phoenix

Origem: regras do gerador Phoenix anteriormente em `AGENTS.md`, traduzidas em 22/09/2026. Aplicação: criação, edição e validação de formulários.

- Usar `Phoenix.Component.form/1` e `inputs_for/1`, nunca `Phoenix.HTML.form_for` ou `inputs_for` antigos.
- Atribuir `@form` com `to_form/2` no LiveView; para entidades, derivá-lo de changeset. Não passar `@changeset` diretamente à interface nem acessar campos do changeset no template.
- Usar `<.form for={@form} id="...">` e `@form[:field]`; não usar `<.form let={f}>`.
- Usar o componente importado `<.input>`. Se fornecer `class`, as classes padrão não são herdadas: definir o estilo completo.
- Mapas passados a `to_form/1` têm chaves string. `as:` define o nome que agrupa os parâmetros; em changesets ele é inferido a partir do schema.

```elixir
assign(socket, :form, to_form(params, as: :preferences))
```

```heex
<.form for={@form} id="preferences-form" phx-change="validate" phx-submit="save">
  <.input field={@form[:name]} type="text" label={gettext("Name")} />
</.form>
```

Consultar [testes](testes.md) para exercitar `render_change/2` e `render_submit/2`.
