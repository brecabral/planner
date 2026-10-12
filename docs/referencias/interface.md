# Interface, CSS e assets

Origem: regras do gerador Phoenix anteriormente em `AGENTS.md`, traduzidas em 22/09/2026. Aplicação: estilos, assets e experiência de uso.

- Usar daisyUI integrado ao Phoenix/Tailwind para a interface, conforme D15 de [design](../design.md). A diretriz anterior que proibia novas interfaces daisyUI foi substituída pela renovação autorizada em 09/10/2026.
- Definir cores somente nos tokens semânticos daisyUI em `assets/css/app.css`. Componentes usam `base-100/200/300`, `base-content`, `primary`, `error` etc.; não fixar cores de paleta. O claro `planner` está implementado; o plano de produção adiciona `planner_dark` e seleção por conta conforme SPEC-007/design D19. Não aplicar preferências antigas ou tema do sistema.
- Transições dos controles e painel entre 150–200 ms, com tratamento de `prefers-reduced-motion`; não animar entrada dos itens de streams.
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
- Usar feedback de processamento, estados vazios e transições discretas. Indicação de estado não depende somente de hover.
- Textos visíveis seguem [Gettext](gettext.md); não introduzir detalhes de implementação na experiência do usuário.
