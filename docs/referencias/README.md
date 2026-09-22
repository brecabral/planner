# Referências técnicas

Consultar somente o conceito envolvido na tarefa. Estes arquivos preservam as regras técnicas que antes ocupavam o `AGENTS.md`; as instruções aplicáveis continuam obrigatórias. Prosa em português; exemplos de código e comentários em inglês.

| Conceito | Quando ler |
| --- | --- |
| [Elixir](elixir.md) | Dados, imutabilidade, processos e concorrência. |
| [Phoenix](phoenix.md) | Rotas, módulos web e cliente HTTP. |
| [Ecto](ecto.md) | Schemas, validações, consultas e migrations. |
| [HEEx](heex.md) | Layouts, componentes e sintaxe de templates. |
| [Formulários](formularios.md) | `to_form`, inputs e parâmetros. |
| [LiveView](liveview.md) | Navegação, streams e atualização de coleções. |
| [JavaScript com LiveView](liveview-javascript.md) | Hooks, DOM e eventos. |
| [Interface](interface.md) | Tailwind, assets e experiência de uso. |
| [Mix](mix.md) | Convenções para tarefas e dependências. |
| [Testes](testes.md) | TDD, sincronização e testes web. |
| [Quality gate](quality-gate.md) | CI, cobertura, lint, aninhamento e limites de automação. |
| [Gettext](gettext.md) | Traduções e locale por processo. |

## Registrar novas descobertas

Atualizar o arquivo do conceito existente; criar outro somente se tiver assunto distinto. Registrar a regra útil, quando se aplica, origem verificável (arquivo/API/documentação), versão ou data e limites. Identificar hipóteses como hipóteses. Preferir exemplos mínimos a transcrições de manuais; não guardar logs, segredos ou histórico de conversa.

Escolhas da aplicação pertencem a `docs/design.md`; comportamento esperado a `docs/specs/`; procedimentos repetíveis a `docs/skills/`; progresso a `docs/tasks/`; operação ao README da raiz. Referências devem apontar para essas fontes em vez de duplicá-las.
