# PRD — Planner de prioridades diárias

Status: proposta para implementação. Data: 22/09/2026.

## 1. Problema e usuários

Pessoas com muitas responsabilidades já mantêm tarefas e projetos em outros lugares, mas precisam decidir o que executar hoje. Uma lista extensa não responde qual ação é mais importante, quais são as tarefas que a omissão trará prejuízo real.

O Planner é um painel pessoal para escolher poucas ações relevantes, executar o mínimo necessário para avançar e consultar o que foi concluído. Não substitui a ferramenta de gestão de projetos do usuário.

## 2. Objetivos e sinais de sucesso

- Tornar explícita a primeira, a segunda e a terceira prioridades do dia.
- Permitir selecionar uma tarefa do backlog para hoje sem recadastrá-la.
- Registrar conclusões e manter um histórico persistente.
- Manter o fluxo simples: selecionar, executar e concluir.

A validação inicial será por cenários de uso: o usuário deve conseguir identificar sua próxima ação, trazer uma tarefa para hoje e encontrá-la no histórico depois de concluí-la, sem instrução externa. Não há metas quantitativas de adoção ou desempenho fornecidas; não se propõe telemetria adicional no MVP.

## 3. Fontes e fatos verificados

- [Regras do repositório](../AGENTS.md): convenções de Phoenix, testes e execução de `mix precommit`.
- [mix.exs](../mix.exs) e [mix.lock](../mix.lock): aplicação `:planner`, Phoenix instalado em 1.8.13, Ecto/Postgrex e LiveView disponíveis.
- [Contexto existente](../lib/planner/tasks.ex): `Planner.Tasks` contém operações CRUD.
- [Schema existente](../lib/planner/tasks/task.ex): `Planner.Tasks.Task` contém `name`, `scheduled_for`, `completed_on`, `kind` e `label`. Atualmente todos são obrigatórios no changeset, o que impede representar uma tarefa de backlog sem agendamento e sem conclusão.
- [Rotas](../lib/planner_web/router.ex): página inicial e CRUD em `/tasks`, sem fluxo de autenticação definido nesse arquivo.
- [Alias de qualidade](../mix.exs): `precommit` compila com warnings como erros, verifica dependências não utilizadas, formata e executa testes. Não há linter dedicado configurado no alias.
- Na inspeção local não foi encontrada a pasta `.github`; existência de proteção remota da `main` não foi verificada.
- [Visão geral oficial do Phoenix](https://phoenix.hexdocs.pm/overview.html), consultada em 22/09/2026: referência de organização do framework. A página consultada apresenta 1.8.14; o projeto permanece na versão registrada no lockfile.

O CRUD existente é um experimento de `phx.gen`, não uma implementação do domínio. Sua remoção está especificada na tarefa 002; primeiro serão definidas as especificações, depois o novo código. As funcionalidades abaixo são requisitos ou propostas, não declarações de funcionalidades implementadas.

## 4. Escopo funcional do MVP

| ID   | Requisito                                                                    | Origem                                                     |
| ---- | ---------------------------------------------------------------------------- | ---------------------------------------------------------- |
| RF01 | Exibir backlog, prioridades de hoje e acesso ao histórico de concluídas.     | Explícita                                                  |
| RF02 | Mover uma tarefa do backlog para hoje, preservando sua identidade.           | Explícita                                                  |
| RF03 | Mostrar a ordem de execução: primeira, segunda e terceira prioridades.       | Derivada das perguntas do briefing                         |
| RF04 | Concluir uma tarefa de hoje, registrando a data e retirando-a das pendentes. | Derivada do histórico solicitado                           |
| RF05 | Consultar conclusões anteriores, mais recentes primeiro.                     | Histórico explícito; ordenação proposta                    |
| RF06 | Cadastrar manualmente uma tarefa com título obrigatório no backlog.          | Proposta mínima para alimentar o painel; há CRUD existente |
| RF07 | Alterar a ordem das prioridades e devolver uma tarefa de hoje ao backlog.    | Proposta para corrigir a seleção do dia                    |

O MVP não exige campos de projeto, categoria ou justificativa. A interface pode orientar a escolha com as perguntas “Qual ação me faz avançar hoje?” e “O que me prejudica se ficar para depois?”. A decisão de prioridade é do usuário; não há pontuação automática.

## 5. Regras propostas e hipóteses

Estas regras tornam o escopo verificável, mas precisam de confirmação de produto antes de implementar os comportamentos correspondentes.

- **H01 — Limite:** no máximo três tarefas pendentes selecionadas para hoje. Concluir ou devolver uma tarefa libera uma posição. Isso permite mais de três conclusões no mesmo dia; o limite é de foco simultâneo.
- **H02 — Ordem:** seleção ocupa a última posição livre; reordenação mantém posições consecutivas e únicas de 1 a 3.
- **H03 — Virada do dia:** pendências de dias anteriores voltam ao backlog na apresentação do novo dia, sem conclusão automática. A data anterior pode permanecer armazenada até nova seleção, mas não caracteriza compromisso futuro.
- **H04 — Data:** “hoje” usa um único fuso configurável da instalação. O fuso definitivo ainda não foi escolhido; não deve ser inferido do ambiente de desenvolvimento.
- **H05 — Histórico:** contém tarefas concluídas, não um log de cada edição ou movimentação. Conclusões são preservadas; exclusão e reabertura não entram no fluxo inicial.
- **H06 — Entrada:** cadastro manual, sem importação ou sincronização com o lugar onde o usuário organiza seus projetos.

Estados lógicos propostos: backlog → hoje → concluída, com retorno de hoje para backlog. Uma tarefa concluída não aparece como pendente. Repetir uma conclusão não cria outro registro nem altera a data original.

## 6. Experiência e fluxos

A seção “Hoje” tem maior destaque, com prioridades numeradas e ação de concluir. O backlog apresenta a ação “Trazer para hoje”. O histórico fica acessível sem competir visualmente com a próxima ação.

1. O usuário abre o painel e vê suas prioridades em ordem.
2. Quando há espaço, seleciona uma tarefa do backlog; ela passa a aparecer em “Hoje”.
3. Ajusta a ordem ou devolve uma seleção indevida ao backlog.
4. Conclui a tarefa; o painel atualiza as pendências e o histórico.
5. Em outro dia, consulta o histórico e escolhe novas prioridades.

Exibir estados vazios claros, erro de validação próximo ao campo, retorno de erro em operações que falhem e indicação de processamento que evite cliques duplicados. A interface deve funcionar em celular e desktop, com foco visível, controles nomeados e uso por teclado. Reordenação não pode depender exclusivamente de arrastar itens.

## 7. Não objetivos e fora de escopo

- Multi-inquilino, equipes, atribuição de responsáveis ou colaboração.
- Gestão completa de projetos, subtarefas, dependências e calendários complexos.
- Recorrência, notificações, integrações, importação e sincronização externa.
- Priorização por IA, pontuação automática, relatórios e gamificação.
- Agenda futura e novas funcionalidades sem relação direta com o fluxo diário.

Autenticação e forma de acesso permanecem em aberto; ausência de multi-inquilino não define, por si só, que o painel possa ser público.

## 8. Arquitetura inicial proposta

Manter Phoenix, PostgreSQL e organização orientada ao domínio. Remover o CRUD experimental antes de implementar o modelo definitivo. Contextos, entidades e invariantes deverão resultar das especificações, sem obrigação de preservar os campos do gerador.

- `PlannerWeb`: apresentação e eventos, preferencialmente um `PlannerWeb.PlannerLive` para o painel. O CRUD MVC atual será removido e não servirá como especificação.
- Contexto de domínio a especificar: seleção, ordenação, conclusão, retorno ao backlog e consultas; validações independentes da interface.
- Entidade e persistência a especificar, usando `Planner.Repo`; o schema experimental não define seu contrato.
- PostgreSQL: persistência e transações para manter consistência, inclusive com duas abas abertas.

Modelo de dados pendente de especificação. Definir atributos, estados e transições a partir das regras confirmadas, sem reutilizar automaticamente `name`, `scheduled_for`, `completed_on`, `kind` ou `label`. A remoção do experimento deve considerar migrations aplicadas e dados existentes.

O estado pode ser derivado das datas, evitando um campo de status redundante. Seleção e ordenação devem ser atômicas e serializar alterações concorrentes para que o limite e a unicidade de posições sejam preservados. O mecanismo exato de bloqueio e constraints será definido na tarefa de persistência, com teste de concorrência.

LiveViews devem seguir `AGENTS.md`: layout da aplicação, formulários com `to_form` e `<.input>`, coleções em streams e IDs estáveis. Não há necessidade demonstrada de serviços separados, filas ou dependências adicionais.

## 9. Qualidade, configuração e entrega

- Interface em português do Brasil e inglês via Gettext. Código, comentários e mensagens-base em inglês; documentação `.md` em português. A [SPEC-001](specs/001-idiomas.md) define o comportamento proposto; a [tarefa 001](tasks/001-troca-de-idiomas.md) registra a implementação planejada.
- Instruções para executar o projeto têm fonte única no [README](../README.md).

- Usar TDD enxuto: antes de cada implementação, escrever um teste que expresse o resultado esperado; evitar testes que apenas repitam a implementação.
- Cobrir regras no contexto e fluxo principal na interface, com seletores por IDs e `Phoenix.LiveViewTest` quando houver LiveView.
- Executar verificações por aliases Mix; `mix precommit` é o comando obrigatório ao finalizar alterações. Definir a cobertura de lint que falta e um alias de CI que detecte formatação divergente sem apenas corrigi-la.
- Configurar CI no GitHub e proteção da `main`, exigindo PR e verificações verdes. São requisitos de entrega ainda não comprovados na infraestrutura remota.
- Remover credenciais e configurações de ambiente fixas do código; usar `.env` local não versionado, com carregamento explícito, e variáveis injetadas no CI/produção. Um eventual `.env.example` deve conter apenas nomes e exemplos não sensíveis.
- Não incluir informações sensíveis em comentários ou logs. Validar comandos no servidor, inclusive parâmetros de datas e posições derivados das ações.
- Armazenar documentação em `docs/` e tarefas de implementação em `docs/tasks/`.

## 10. Critérios de aceite verificáveis

Critérios ligados às hipóteses H01–H06 são condicionais à confirmação dessas regras.

| ID   | Cenário e resultado esperado                                                                                                                                               |
| ---- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CA01 | Sem tarefas cadastradas, o painel mostra estados vazios e permite cadastrar uma tarefa pelo título; título vazio não persiste.                                             |
| CA02 | Uma tarefa de backlog selecionada para hoje sai do backlog e aparece uma única vez em “Hoje”, com o mesmo ID; recarregar preserva a seleção.                               |
| CA03 | Com três pendências em “Hoje”, tentar selecionar uma quarta mantém as três existentes e informa o limite, inclusive em solicitações concorrentes.                          |
| CA04 | Ao reordenar três prioridades, o painel e uma nova leitura do banco apresentam a mesma ordem, sem posições duplicadas.                                                     |
| CA05 | Ao devolver uma tarefa ao backlog, ela mantém seu título e identidade e libera espaço em “Hoje”.                                                                           |
| CA06 | Ao concluir uma tarefa, ela deixa as pendentes e aparece uma vez no histórico com a data correta; repetir o comando não duplica nem muda a conclusão.                      |
| CA07 | Após reiniciar a aplicação, o histórico permanece disponível em ordem decrescente de data, com desempate estável.                                                          |
| CA08 | Na mudança de data no fuso configurado, uma tarefa pendente do dia anterior aparece no backlog, nunca como concluída automaticamente; validar também uma sessão já aberta. |
| CA09 | Falha de gravação informa o erro e não apresenta a operação como concluída; nova leitura mantém o estado persistido anterior.                                              |
| CA10 | Em tela de celular e por teclado, é possível selecionar, reordenar e concluir tarefas sem controles inacessíveis.                                                          |
| CA11 | A entrega de implementação passa pelos aliases de qualidade; o CI detecta teste falhando e formatação divergente, e a regra da `main` exige PR com CI verde.               |
| CA12 | Configurações de ambiente são obtidas externamente, `.env` não é rastreado e o procedimento de carregamento está documentado sem segredos.                                 |

## 11. Riscos e mitigação

| Risco                                                      | Tratamento                                                                               |
| ---------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| Interpretar “três tarefas” de modo diferente do usuário    | Confirmar se o limite vale para pendências simultâneas ou para todas as escolhas do dia. |
| Perder visibilidade de pendências na virada do dia         | Confirmar H03 e testar a transição com relógio controlado, incluindo sessão aberta.      |
| Duas abas ultrapassarem o limite ou sobrescreverem a ordem | Aplicar regras transacionais no contexto e testar concorrência.                          |
| Modelo CRUD atual exigir conclusão no cadastro             | Remover o experimento e especificar o novo modelo, avaliando dados existentes.                        |
| Painel pessoal ficar exposto sem controle de acesso        | Definir acesso e hospedagem antes de disponibilização fora do ambiente local.            |
| Escopo crescer para gerenciador de projetos                | Usar os não objetivos como filtro para novas demandas.                                   |
| CI e proteção de branch serem tratados como já existentes  | Verificar e registrar evidência na tarefa de infraestrutura.                             |

## 12. Perguntas em aberto

1. São no máximo três pendências simultâneas, três escolhas por dia ou apenas três prioridades destacadas sem bloqueio?
2. Tarefas não concluídas devem voltar ao backlog, continuar em “Hoje” ou exigir uma decisão manual no dia seguinte?
3. Qual fuso define o dia e onde ele será configurado?
4. O uso será apenas local ou remoto? Qual controle de acesso é necessário?
5. O cadastro manual por título é suficiente? `kind` e `label` têm algum significado indispensável?
6. É necessário corrigir uma conclusão acidental ou excluir tarefas no MVP?

## 13. Sequência proposta de implementação

1. Remover o CRUD experimental conforme a tarefa 002, sem implementar um substituto. Resolver as perguntas de limite, virada do dia, fuso e acesso; atualizar as decisões.
2. Especificar o modelo e as regras do contexto antes de implementar; então escrever testes de intenção e criar o novo domínio. A tarefa 001 pode integrar idiomas à base preservada, sem depender desse domínio.
3. Entregar backlog e prioridades do dia, incluindo seleção e ordenação.
4. Entregar conclusão e histórico; verificar persistência e concorrência.
5. Validar experiência responsiva, configuração, aliases de qualidade, CI e proteção de branch.

As tarefas futuras devem ser registradas em [docs/tasks](tasks/README.md), vinculadas aos requisitos e critérios acima. Convenções: [linguagem e namespace](ddd.md). Registro de decisões: [design e arquitetura](design.md).

As especificações de comportamento seguem o [guia de specs](specs/README.md). O estado e as dependências das entregas ficam nos metadados das tarefas, conforme o [formato do grafo](tasks/formato.md).
