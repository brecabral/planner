# Interface, CSS e assets

Origem: regras do gerador Phoenix anteriormente em `AGENTS.md`, traduzidas em 22/09/2026. Aplicação: estilos, assets e experiência de uso.

- Usar Tailwind e CSS próprio para componentes; não usar daisyUI para novas interfaces.
- Tailwind v4 não precisa de `tailwind.config.js`; manter em `assets/css/app.css` a sintaxe de importação e fontes do projeto:

```css
@import "tailwindcss" source(none);
@source "../css";
@source "../js";
@source "../../lib/planner_web";
```

- Não usar `@apply` em CSS puro.
- Os bundles suportados são `app.js` e `app.css`. Importar dependências nesses arquivos, sem incluir scripts ou folhas de estilo externos diretamente nos layouts.
- Não escrever scripts inline comuns em templates; para integração LiveView, consultar [hooks](liveview-javascript.md).
- Priorizar usabilidade, tipografia legível, espaçamento consistente, equilíbrio visual e responsividade.
- Usar feedback de processamento, estados vazios e transições discretas. Hover não substitui foco de teclado nem indicação de estado.
- Textos visíveis seguem [Gettext](gettext.md); não introduzir detalhes de implementação na experiência do usuário.
