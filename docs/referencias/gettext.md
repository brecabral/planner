# Gettext e idiomas

Origem: integração inspecionada no projeto e documentação oficial consultada em 22/09/2026. Aplicação: textos da interface e seleção de idioma.

- `PlannerWeb.Gettext` já define o backend; os helpers web usam `use Gettext, backend: PlannerWeb.Gettext`.
- Mensagens-base no código são literais em inglês. Traduções ficam nos catálogos em `priv/gettext/<locale>/LC_MESSAGES/`.
- Usar `gettext` para mensagens, `ngettext` para plurais e `dgettext`/`dngettext` com domínio `errors` para erros. Preservar os helpers existentes para mensagens Ecto.
- Passar variáveis por bindings; não concatenar fragmentos traduzíveis nem interpolar diretamente no `msgid`.
- Locale é mantido por processo. Defini-lo na requisição HTTP não configura automaticamente o processo de uma LiveView; reaplicar na montagem e reconexão, por exemplo via `on_mount`.
- Usar strings permitidas para locale; não converter entrada arbitrária em atoms.
- A extração cria/atualiza `.pot`; a mesclagem atualiza `.po`. Revisar traduções vazias e fuzzy. Consultar a ajuda Mix antes de executar esses comandos.
- O locale `pt_BR` corresponde ao catálogo; o atributo HTML usa `pt-BR`.

Comportamento do produto e dúvidas pendentes: [spec de idiomas](../specs/001-idiomas.md). A sessão e o seletor são decisões da aplicação; Gettext não os cria automaticamente.

Fontes: [API e locale](https://gettext.hexdocs.pm/Gettext.html#module-locale), [extração e catálogos](https://gettext.hexdocs.pm/Gettext.html#module-basic-overview), [montagem LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#on_mount/1).
