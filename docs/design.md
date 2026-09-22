# Decisões de design e arquitetura

Referências: [PRD](prd.md), [convenções](ddd.md) e [AGENTS.md](../AGENTS.md).

“Confirmada” indica uma restrição do briefing ou convenção já existente. “Proposta” indica uma escolha ainda sujeita a revisão; não significa implementação concluída.

## D01 — Phoenix e PostgreSQL

Status: confirmada pelo briefing e repositório.

Manter a stack existente e `Planner.Repo`. Evitar dependências adicionais sem necessidade demonstrada. A [documentação oficial](https://phoenix.hexdocs.pm/overview.html) foi consultada como referência do framework, sem implicar atualização da versão instalada.

## D02 — Documentação em docs/

Status: adotada nesta documentação para resolver ambiguidade de caminho.

O briefing menciona `doc/` e `docs/`, mas determina a entrega do PRD e das tarefas em `docs/`. O `.gitignore` reserva `/doc/` para documentação gerada. Centralizar especificações em `docs/` e tarefas em `docs/tasks/`. Operação e execução ficam somente no [README](../README.md); o índice de consulta seletiva fica no [AGENTS.md](../AGENTS.md).

## D03 — Remover o experimento antes de modelar

Status: confirmada pelo usuário; execução pendente na [tarefa 002](tasks/002-remover-crud-experimental.md).

O CRUD de `phx.gen` não atende à modelagem pretendida e deve ser removido. A proposta anterior de evoluir diretamente `Planner.Tasks` foi substituída. Primeiro definir especificações de domínio, invariantes e critérios; só depois criar contexto, entidade e interface. Preservar a infraestrutura Phoenix, Repo, Gettext e banco local.

## D04 — Painel com foco em Hoje

Status: proposta.

Usar LiveView para o painel, com prioridades numeradas em destaque, backlog secundário e histórico acessível. Seguir os componentes e regras do `AGENTS.md`, com Tailwind e CSS próprio, sem introduzir componentes daisyUI. O projeto atual usa controllers no CRUD; a migração do fluxo para LiveView ainda é trabalho futuro.

## D05 — Três prioridades e virada do dia

Status: proposta pendente de confirmação.

Limitar a três pendências simultâneas e devolver pendências anteriores ao backlog na apresentação do novo dia. As duas escolhas concretizam a simplicidade desejada, mas o briefing não define completamente essas regras. Ver H01–H04 e perguntas do PRD antes de implementar.

## D06 — Persistência a especificar

Status: em aberto; proposta anterior de reutilizar os campos do gerador substituída.

O histórico de conclusões continua sendo requisito, mas tabelas, campos, estados e operações serão definidos a partir das regras confirmadas do PRD. Não reutilizar o schema experimental por conveniência. A tarefa 002 deve avaliar migrations já aplicadas e dados existentes antes de qualquer descarte; registrar a estratégia de limpeza sem recriar o domínio antecipadamente.

## D07 — Qualidade por Mix e GitHub

Status: exigência confirmada; configuração parcialmente existente.

Aplicar TDD enxuto e finalizar com `mix precommit`. O alias atual existe, mas formata arquivos e não contém linter dedicado. Definir verificações de CI que falhem quando houver divergência, configurar workflow e exigir PR com CI verde na `main`. Proteção remota ainda não verificada.

## D08 — Configuração externa e acesso

Status: configuração externa exigida; mecanismo de acesso em aberto.

Usar `.env` local ignorado e variáveis injetadas nos ambientes de execução, sem segredos em código ou comentários. Desenvolvimento e teste já leem as variáveis de conexão de `.env` ou do ambiente via `config/database.exs`; uso e limites estão no [README](../README.md). Uso pessoal não resolve autenticação: definir a exposição e o acesso antes de disponibilizar remotamente.

## D09 — Idiomas com Gettext

Status: suporte a pt-BR e inglês e política de idiomas confirmados; seletor ainda pendente.

Manter `PlannerWeb.Gettext`, já integrado aos helpers web. Código e comentários em inglês; documentação `.md` em português; mensagens-base da interface em inglês e traduções em catálogos `pt_BR` e `en`. A proposta operacional é pt-BR como padrão e preferência persistida na sessão, sem adicionar contas de usuário.

O Gettext mantém o locale por processo: a integração deve cobrir a requisição HTTP e a montagem de LiveViews. Comportamento e dúvidas estão na [SPEC-001](specs/001-idiomas.md); integração técnica em [Gettext](referencias/gettext.md); execução na [tarefa 001](tasks/001-troca-de-idiomas.md). Não é necessário adicionar uma biblioteca de internacionalização.

## D10 — Documentação por responsabilidade e tarefas em grafo

Status: adotada para a organização do repositório.

Referências técnicas por conceito ficam em `docs/referencias`; comportamento em `docs/specs`; procedimentos reutilizáveis em `docs/skills`; execução em `docs/tasks`. O `AGENTS.md` contém regras essenciais e roteamento. Prosa em português, exemplos de código em inglês.

Tarefas usam Markdown com frontmatter YAML como fonte única de dependências e entregas. `depends_on` forma um grafo acíclico; `provides` e `consumes` explicitam recursos compartilhados. Essa escolha mantém leitura humana e permite processamento sem duplicação de JSON. Formato e limites da coordenação: [grafo de tarefas](tasks/formato.md).

## D11 — Perfis e capacidade de execução

Status: definida pelo usuário e formalizada no fluxo do repositório.

Planejadores de ponta definem specs, arquitetura e tarefas; revisores de ponta avaliam diffs, aderência e gates; implementadores seguem um fluxo único com nível mínimo `basic`, `standard` ou `advanced` atribuído por tarefa. Os perfis descrevem conduta e não alteram permissões técnicas ou modelos automaticamente.

Toda validação de código segue review; autoavaliação não equivale a aprovação independente. Tarefas passam por `in_review` e só chegam a `done` após aprovação e integração. Critérios de nível e metadados têm fonte única no [formato das tarefas](tasks/formato.md); contexto inicial de cada perfil fica no [AGENTS.md](../AGENTS.md#perfis-de-atuação).

## D12 — Reserva humana e infraestrutura GitHub

Status: reserva `human` definida pelo usuário; execução da infraestrutura pendente.

Tarefas `human` não podem ser executadas por agentes de nenhum perfil. Conclusão depende de confirmação humana e evidências; trabalho dependente deve aguardar. A TASK-003 fornece o gate GitHub para TASK-002 e, transitivamente, TASK-001. A recomendação inicial é compilação, formato, testes e Credo; cobertura inicialmente informativa. Ferramentas e proteção ainda não foram configuradas.
