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

## Diálogo e estado nativo durante patches

Na versão instalada, `this.js().ignoreAttributes(element, ["open"])` preserva atributos nativos que o hook controla. No cadastro, aplicar ao diálogo antes de `showModal()` e à seção de labels para não recolher durante validações. Dados de erro enviados pelo servidor continuam atualizados; o hook os usa para expandir labels. A implementação em `assets/js/app.js` remove listeners e restaura overflow/foco em `destroyed`. Esses detalhes descrevem o código existente; não estabelecem requisitos de foco/teclado ou avaliação humana obrigatória.

## Arraste em listas de streams

No Planner, `TaskDrag` usa SortableJS via npm e mantém streams como responsáveis pelo estado confirmado. Captura os nós originais no início do gesto e os devolve às listas antes de `pushEvent`; nunca clona ou ignora as listas. Os callbacks `dom.onPatchStart/onPatchEnd` da versão instalada cancelam gestos e desmontam/remontam Sortable antes/depois de patches, inclusive atualizações originadas pelo cadastro.

No SortableJS 1.15.7, `destroy()` chama `_onDrop()` sem evento: cancela pressão/rolagem/listeners, mas não remove ghost/clone nem todas as classes e estilos; `_nulling()` apaga as referências estáticas. O hook captura os artefatos do próprio gesto antes de destruir e os remove explicitamente. Atributos originais são capturados na fase de captura do pressionamento, antes de `will-change` ser alterado (já ocorre antes de `onChoose`). A restauração cancela timers de animação e preserva valores anteriores de classes/estilos e os mesmos nós. O teste técnico executa esses caminhos da dependência instalada em DOM mínimo; não equivale à execução de gestos ou streams em navegador. Instruções de execução no [README](../../README.md).

Ações de formulário usam `JS.push(..., page_loading: true)`. O hook acompanha o alvo de `phx:page-loading-start/stop` por identidade: depois de uma transferência, esse formulário pode já ter saído do DOM, portanto `contains(target)` não serve para liberar a espera na resposta. Desconexão invalida callbacks antigos e impede movimentos até a remontagem/reconexão. Essa inspeção e a compilação não substituem validação de gestos reais pelo responsável.
