# LiveView: hooks e eventos JavaScript

Origem: regras do gerador Phoenix anteriormente em `AGENTS.md`, traduzidas em 22/09/2026. Aplicação: comportamento no navegador integrado à LiveView.

- Elementos com `phx-hook` precisam de ID único. Quando o hook gerencia seu próprio DOM, acrescentar `phx-update="ignore"`.
- Hooks externos ficam em `assets/js/` e são registrados em `hooks` no construtor de `LiveSocket`.
- Hooks colocados junto ao template usam `<script :type={Phoenix.LiveView.ColocatedHook} name=".HookName">`; seus nomes começam com ponto e a integração acontece pelo bundle.
- Não inserir scripts inline comuns nos templates. A exceção técnica acima é o hook processado pelo compilador LiveView, não um script arbitrário.
- `push_event/3` devolve um socket atualizado: retornar ou reatribuir o resultado.
- Hooks recebem eventos com `this.handleEvent` e enviam eventos com `this.pushEvent`; o servidor pode responder com `{:reply, payload, socket}`.

```elixir
def handle_event("refresh", _params, socket) do
  {:noreply, push_event(socket, "refreshed", %{ok: true})}
end
```

```javascript
const Refresh = {
  mounted() {
    this.handleEvent("refreshed", payload => this.el.dataset.ready = String(payload.ok));
    this.el.addEventListener("click", () => this.pushEvent("refresh", {}));
  }
};
```

Formatação de parâmetros e atualizações do DOM devem ser limitadas à responsabilidade do hook; regras de negócio permanecem no servidor.
