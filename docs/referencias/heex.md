# HEEx: templates e componentes

Origem: regras do gerador Phoenix anteriormente em `AGENTS.md`, traduzidas em 22/09/2026. Aplicação: templates e componentes HTML.

- Usar `~H` ou `.html.heex`, nunca `~E`.
- Iniciar templates LiveView com `<Layouts.app flash={@flash} ...>`. `Layouts` já é disponibilizado pelos helpers web.
- Quando o fluxo exigir `current_scope`, usar o `live_session` apropriado e passá-lo ao layout. Corrigir a origem do assign ausente, em vez de mascarar o erro.
- `<.flash_group>` só pode ser chamado em `layouts.ex`.
- Ícones usam `<.icon name="hero-x-mark" class="w-5 h-5" />`, nunca módulos `Heroicons`.
- Adicionar IDs únicos a formulários, botões e elementos relevantes para interação e testes.
- Usar `{...}` para atributos e valores no corpo. Blocos `if`, `cond`, `case` e `for` no corpo usam `<%= ... %>`.
- Elixir não tem `else if` ou `elsif`: usar `cond` ou `case`.
- Gerar coleções com `for`, nunca `<% Enum.each %>`.
- Comentários de template usam `<%!-- ... --%>`; seu conteúdo é escrito em inglês.
- Classes condicionais usam lista `[...]`. Dentro dela, envolver `if(...)` em parênteses.
- Para chaves literais em exemplos de código, usar `phx-no-curly-interpolation` no elemento pai. Nesse trecho, `<%= ... %>` continua disponível para interpolação.

```heex
<div id={@id} class={["px-2", @selected && "font-bold", if(@active, do: "block", else: "hidden")]}>
  {@title}
  <%= if @active do %>
    <span>{gettext("Active")}</span>
  <% end %>
</div>
<code phx-no-curly-interpolation>const entry = {enabled: true};</code>
```

Formulários: [referência específica](formularios.md). Estilos e assets: [interface](interface.md).
