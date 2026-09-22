# Guia de trabalho

## Perfis de atuação

São condutas de trabalho, não permissões de filesystem, credenciais ou troca automática de modelo. Respeitar sempre o escopo autorizado. Usar o perfil pedido pelo usuário; na ausência dele, classificar pela intenção: definir solução → planejador; verificar código → revisor; executar tarefa pronta → implementador. Em pedidos mistos, separar as etapas e declarar a mudança de perfil.

| Perfil | Capacidade esperada | Contexto inicial obrigatório | Fluxo |
| --- | --- | --- | --- |
| Planejador | Agente de ponta | Pedido, seções pertinentes do PRD, specs/design/DDD relacionados e cabeçalhos das tarefas afetadas | [Planejamento](docs/fluxos/planejamento.md) |
| Revisor | Agente de ponta | Alvo e base da revisão, diff/commits, tarefa, critérios/specs e evidências de testes | [Review](docs/fluxos/review.md) |
| Implementador | Nível mínimo declarado na tarefa: `basic`, `standard` ou `advanced` | Tarefa completa, regras de spec indicadas, contratos das dependências, arquivos de entrada e referências técnicas aplicáveis | [Implementação](docs/fluxos/implementacao.md) |

Carregar apenas o fluxo ativo. Qualquer validação de código segue o fluxo de review, inclusive autoavaliação do implementador; isso não transforma autoavaliação em aprovação independente. O planejador define o nível mínimo e justifica a escolha; todos os implementadores seguem o mesmo fluxo e critérios de qualidade. Se a capacidade ou o contrato forem insuficientes, registrar o impedimento e devolver para decomposição ou agente mais capaz, sem presumir uma troca de modelo.

## Execução exclusiva por humano

`execution_level: human` não é um quarto nível de capacidade de LLM: é execução exclusiva por pessoa. Vale para todos os perfis. Ao encontrar essa tarefa ou uma dependência humana ainda não concluída, recusar sua execução, informar ID, título e ação humana necessária e explicar qual trabalho fica impedido de prosseguir. Não executar parcialmente, delegar a outro agente, reclassificar para contornar o bloqueio ou marcar como concluída por inferência.

Agentes podem explicar a tarefa e inspecionar evidências em modo de leitura; só registrar conclusão após confirmação explícita de execução pelo humano e evidência de aceite. Continuar apenas trabalho independente. Exemplo: “A TASK-003 deve ser executada por uma pessoa para liberar a TASK-002.”

## Contexto mínimo

Comece pela tarefa solicitada. Leia apenas os documentos e trechos necessários; use `rg -n` para localizar conceitos. Não carregue toda a documentação nem todas as skills. As referências técnicas aplicáveis preservam as regras do gerador Phoenix e devem ser consultadas antes de modificar a área correspondente.

| Necessidade | Fonte |
| --- | --- |
| Executar, configurar e verificar | [README](README.md) |
| Entender objetivos, escopo e dúvidas | [PRD](docs/prd.md) |
| Definir comportamento e regras de negócio | [Specs](docs/specs/README.md) |
| Nomear e modelar conceitos | [DDD](docs/ddd.md) |
| Consultar decisões de arquitetura | [Design](docs/design.md) |
| Selecionar trabalho e dependências | [Tarefas](docs/tasks/README.md) |
| Criar specs ou decompor trabalho | [Skills](docs/skills/README.md) |
| Elixir, rotas ou persistência | [Elixir](docs/referencias/elixir.md), [Phoenix](docs/referencias/phoenix.md), [Ecto](docs/referencias/ecto.md) |
| Templates ou formulários | [HEEx](docs/referencias/heex.md), [formulários](docs/referencias/formularios.md) |
| LiveView ou hooks | [LiveView](docs/referencias/liveview.md), [interop JS](docs/referencias/liveview-javascript.md) |
| Estilos, traduções ou testes | [Interface](docs/referencias/interface.md), [Gettext](docs/referencias/gettext.md), [testes](docs/referencias/testes.md) |
| Tarefas Mix ou nova descoberta técnica | [Mix](docs/referencias/mix.md), [índice de referências](docs/referencias/README.md) |

## Regras essenciais

- Código, identificadores, comentários, docstrings e mensagens técnicas em inglês; documentação `.md` em português.
- Interface via `PlannerWeb.Gettext`, com mensagens-base em inglês e catálogos `pt_BR`/`en`. Não traduzir conteúdo do usuário automaticamente.
- Primeiro especificar regras e resolver dúvidas bloqueantes; depois implementar. O CRUD experimental não é o modelo do produto.
- Tarefas usam Markdown com metadados YAML. Antes de iniciar, conferir `depends_on`, bloqueios e escopo. Um recurso compartilhado deve ter uma tarefa produtora única; consumidoras dependem dela.
- Não considerar specs ou tarefas concluídas por estarem documentadas. Atualizar estados e registrar evidências reais; conclusão exige integração das dependências na base de trabalho.
- Aplicar TDD enxuto para comportamento. Ler `mix help` antes de usar tarefas; finalizar alterações com `mix precommit` e corrigir problemas relevantes.
- Usar dependências existentes: HTTP com `Req`. Não adicionar ferramentas ou camadas sem necessidade concreta.
- Registrar descobertas reutilizáveis nas referências do conceito, decisões em `design.md` e progresso no arquivo da tarefa. Não duplicar uma memória de conversa.
- Manter instruções operacionais somente no README. Ao mover documentos, corrigir os links e índices afetados.
