# LiveView: navegação e coleções

Origem: regras do gerador Phoenix anteriormente em `AGENTS.md`, traduzidas e organizadas em 22/09/2026. Aplicação: LiveViews e streams.

## Organização e navegação

- Preservar a organização de LiveViews geradas, como `TaskLive.Index` e `TaskLive.Form`. Para uma LiveView escrita separadamente, usar nome terminado em `Live`, como `PlannerWeb.PlannerLive`.
- Evitar LiveComponents sem uma necessidade específica.
- Usar `<.link navigate={...}>`, `<.link patch={...}>`, `push_navigate/2` e `push_patch/2`. Não usar `live_redirect` ou `live_patch` antigos.
- Layouts, scope e componentes seguem [HEEx](heex.md).

## Streams

- Usar streams para coleções dinâmicas, evitando manter listas crescentes nos assigns.
- `stream(socket, :entries, entries)` insere; `reset: true` substitui a coleção; `stream_delete/3` remove; `stream_insert/3` atualiza um item.
- `at: 0` insere no início; `at: -1` insere no fim. A regra antiga rotulava `at: -1` como inserção no início; usar a semântica da API, não esse rótulo.
- O contêiner precisa de ID e `phx-update="stream"`; cada filho usa o ID recebido no stream.
- Streams não são enumeráveis. Para filtrar ou recompor, consultar novamente os dados e fazer `stream(..., reset: true)`.
- Contagens e indicadores de vazio devem ser assigns separados. Outra opção de vazio é um elemento com `hidden only:block`, sendo o único filho além dos itens do stream.
- Ao alterar um assign que muda o conteúdo de um item, reinserir também o item com `stream_insert/3`; atualizar só o assign não recompõe o item.
- Não usar `phx-update="append"` ou `"prepend"` antigos.

```heex
<div id="entries" phx-update="stream">
  <div id="entries-empty" class="hidden only:block">{gettext("No entries yet")}</div>
  <div :for={{id, entry} <- @streams.entries} id={id}>{entry.name}</div>
</div>
```

```elixir
socket
|> assign(:editing_entry_id, entry.id)
|> stream_insert(:entries, entry)
```

Para hooks e eventos, consultar [interop JavaScript](liveview-javascript.md). Conferir as opções de `stream/4` na versão instalada antes de alterar ordenação.
