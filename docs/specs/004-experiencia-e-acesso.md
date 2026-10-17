---
id: "SPEC-004"
status: ready
requirements: ["RF01", "CA09", "CA10"]
---

# 004 — Experiência do painel

## Escopo

Apresentação do planejamento do usuário padrão, conforme o PRD e a [SPEC-005](005-contas-e-acesso.md).

## Arquitetura e casos de uso

O painel é uma composição LiveView sobre o contexto de tarefas e o catálogo de labels. Reaproveita Index/Form gerados por Phoenix, reduzindo o CRUD ao fluxo especificado, com o usuário padrão no servidor e pt-BR fixo via Gettext. Streams representam backlog, hoje, retry e histórico; contadores e estados vazios vêm do snapshot do domínio.

Cadastro, seleção, devolução, ordenação, conclusão e consulta histórica são casos de uso da mesma experiência. Formulários não transportam autoridade de proprietário ou data. Sucesso/conflito recompõe o estado autorizado; indisponibilidade não vira confirmação otimista de gravação. Montagem/reconexão relê os dados e a data corrente; não há timer de atualização.

## Regras

- RN01: destacar hoje com prioridades numeradas e escolhas usadas no dia; oferecer backlog e retry separados, cadastro e acesso ao histórico. Estados vazios explicam a ação disponível sem criar tarefas fictícias.
- RN02: cadastro tem título, seleção de várias labels próprias e criação de novas labels. Conteúdo do usuário não é traduzido.
- RN03: selecionar, devolver ao backlog, reordenar e concluir têm controles nomeados. Reordenação oferece subir/descer.
- RN04: erros de campo aparecem associados ao campo; limite, conflito e falha de gravação são visíveis e acessíveis. Indicar processamento, impedir submissão duplicada enquanto pendente e nunca mostrar sucesso antes de persistir.
- RN05: depois de sucesso ou rejeição por estado antigo, mostrar o estado autoritativo. Recarga/reconexão restaura dados persistidos. Atualização instantânea de abas ociosas por mudanças de outra aba não é exigida.
- RN06: textos, erros e nomes acessíveis usam Gettext em pt-BR. Cota esgotada continua visível mesmo que a lista de hoje esteja vazia após conclusões.

## Cenários de aceite

- CA-004-01: sem tarefas cadastradas, cadastrar tarefa com labels e selecionar a coloca em hoje; recarga mantém identidade e classificação.
- CA-004-02: nos testes LiveView, cadastrar, selecionar de backlog/retry, subir/descer, devolver e concluir pelos controles do painel produz o estado esperado, preservado após remontagem. Esse aceite verifica eventos e estrutura.
- CA-004-03: falha de gravação mostra erro sem apresentar movimentação ou cota como confirmadas; leitura seguinte recupera estado persistido.
- CA-004-04: ação com estado antigo é rejeitada e atualiza coleções e cota sem duplicação; reconexão mantém pt-BR.
- CA-004-05: em pt-BR, histórico e escolhas usadas são compreensíveis; título e labels digitados permanecem iguais.
- CA-004-06: após concluir as três escolhas, hoje pode estar vazio, mas o painel informa que a cota diária acabou e o servidor rejeita outra seleção.

A associação estrutural de erros aos campos, os nomes dos controles e a marcação de alertas são verificáveis nos testes existentes. Não há etapa obrigatória de avaliação humana da interface, conforme a [decisão vigente do PRD](../prd.md#feedback-de-interface).

## Implementação

Distribuída em tarefas pequenas; consultar o [mapa de entregas](../tasks/README.md). Esta spec permanece o contrato comum dos casos de uso acima.

## Evolução da experiência — 09/10/2026

Foco, teclado, contraste, layout e avaliação estética não compõem o aceite. A apresentação descrita em design registra escolhas da implementação, sujeitas a feedback discricionário do responsável.

Contrato autorizado após o MVP, implementado na [TASK-039](../tasks/039-renovar-experiencia.md). O estado e os aceites históricos acima descrevem a entrega anterior; não atestam automaticamente esta evolução.

- RN07: home em `/` com identidade Planner e botão “Abrir Planner”. Tema claro `planner`, sem seletor nem leitura de preferência antiga/sistema. Cores centralizadas nos tokens semânticos daisyUI, tipografia de sistema e controles confortáveis ao toque.
- RN08: apresentar prioridades numeradas, indicador das três escolhas consumidas e contagem de pendências distintos. Oferecer concluir, devolver e subir/descer, com nomes dos controles e labels associados à tarefa.
- RN09: histórico abaixo, recolhido ao montar, contador sempre visível e botão com estado de expansão. Concluir atualiza o histórico sem expandi-lo, com mensagem após confirmação do servidor.
- RN10: “Nova tarefa” abre painel lateral sobre o planejamento por patch; `/tasks/new` abre diretamente a mesma composição. Form reaproveitado como LiveComponent, com título obrigatório.
- RN11: labels opcionais em seção expansível, checkboxes para existentes e novas labels uma por linha. Erros associados aos campos expandem essa seção automaticamente. Falha de validação ou persistência conserva painel e entradas; sucesso fecha, atualiza backlog e anuncia a criação.
- RN12: fechar/cancelar retorna a `/tasks`; clicar no fundo não descarta o formulário.
- RN13: preservar domínio, cota, ordenação, persistência, usuário padrão, Gettext pt-BR e as três rotas. Sem migrações ou novas APIs. Paletas personalizadas, tema escuro, login, arrastar tarefas e sincronização automática não fazem parte desta entrega.

### Aceites adicionais

- CA-004-07: home oferece acesso ao Planner, sem marca ou links promocionais Phoenix; tema claro está definido no HTML inicial.
- CA-004-08: abrir cadastro pelo botão ou URL mantém o planejamento na composição. Cancelar/fechar retorna por patch, sem criar tarefa. Reabrir inicia formulário vazio. Histórico mantém sua expansão durante abertura/fechamento.
- CA-004-09: cadastrar com labels existentes/novas atualiza backlog e mostra confirmação somente após persistência. Campos inválidos e falhas conservam as entradas; erros de labels apresentam a seção aberta. Atualizações do pai não apagam o rascunho.
- CA-004-10: concluir anuncia resultado confirmado, conserva consumo diário e não expande histórico. Histórico pode ser expandido e recolhido explicitamente. Cota esgotada, devolução, reordenação, conflitos e falhas permanecem cobertos.
- CA-004-11: **cancelado por decisão do responsável em 09/10/2026**. Avaliação humana da interface não é requisito ou pendência; ID preservado para rastreabilidade, sem presumir execução.

## Arraste com mouse e touch — 09/10/2026

Evolução autorizada pelo plano do responsável; amplia a entrega anterior sem sincronização automática entre abas nem reabertura de concluídas.

- RN14: alça em cada pendência permite arrastar com mouse e, no touch, após pressão de 200 ms. Rolagem fora da alça permanece livre; arraste tem animação, indicação de posição e rolagem automática. Listas vazias são destinos utilizáveis. Transferências proibidas são indicadas e impedidas, com revalidação no servidor.
- RN15: Concluir permanece visível; selecionar, devolver e subir/descer ficam em menu secundário. Ordenação pelo menu funciona nas três listas, com limites de início/fim.
- RN16: um drop envia um único evento com tarefa, origem, destino e ordens finais afetadas. Restaurar DOM antes da resposta de streams. Impedir novos movimentos durante operação pendente ou desconexão; sucesso só após persistência. Rejeição recompõe painel e mostra erro pt-BR; reconexão relê estado.
- CA-004-12: eventos de arraste e menu atualizam listas/contadores, persistem após recarga e mostram erro traduzido para estado desatualizado ou comando inválido.
- CA-004-13: cenário de validação pelo responsável: gesto real de mouse/touch, pressão, rolagem externa/automática, destino vazio, bloqueio durante espera/desconexão, reconexão e rejeição pelo servidor. Por decisão posterior do usuário em 09/10/2026, o agente não precisa testar UI/UX ou executar navegador; valida a implementação com testes de domínio/LiveView e compilação. LiveViewTest não executa o hook. Não presumir que o responsável já realizou esses testes nem torná-los pré-requisito humano para implementar.

## MVP de produção — 11/10/2026

Este incremento substitui a home e o tema único de RN07/CA-004-07 após integração da autenticação e dos temas. As exclusões de RN13 eram limites da TASK-039, não do novo MVP. O proprietário passa a ser autenticado pela SPEC-005. O feedback específico de layout abaixo é requisito solicitado; não cria checklist geral de UI/UX nem avaliação humana obrigatória.

- RN17: colocar o acionador e o menu de ações no canto esquerdo de cada cartão de pendência; ancorar a abertura à esquerda. Os controles de mover/subir/descer conservam espaço próprio, sem compressão ou sobreposição, inclusive com títulos/labels longos e viewport estreita. Concluir permanece visível; a alça continua independente do menu.
- RN18: oferecer “Enviar ao backlog” em retry e aceitar esse destino no arraste conforme SPEC-002 RN11. Não oferecer backlog → retry. Ações mantêm processamento, erro pt-BR e estado confirmado pelo servidor.
- RN19: oferecer “Excluir tarefa” no menu de pendências, nunca no histórico. Antes de enviar o comando, pedir confirmação explícita de exclusão definitiva identificando a tarefa; cancelar não grava. Confirmar usa SPEC-002 RN12–RN13. Falha preserva o estado e informa erro; sucesso remove item e atualiza contadores/cota somente após persistência. Não implementar desfazer, edição ou exclusão de labels.
- RN20: entrada, sessão e dashboard seguem SPEC-005; seleção de tema e renderização inicial seguem SPEC-007. Manter `/tasks` como dashboard principal e `/tasks/new` como cadastro autenticado por patch.
- CA-004-14: cada menu está na região esquerda do cartão e abre à esquerda; controles de movimento não encolhem, inclusive em cenário com texto longo. Testes estruturais verificam composição/classes; inspeção no navegador, se feita, é evidência separada e não atribuída a LiveViewTest.
- CA-004-15: enviar retry ao backlog por evento do menu ou arraste recompõe ambas as listas e preserva cota; erro não mostra sucesso. Drop continua único, com restauração dos mesmos nós e cancelamento funcional.
- CA-004-16: cancelar exclusão mantém tarefa; confirmar remove pendência e atualiza cota conforme a lista; concluídas não oferecem ação e evento forjado é rejeitado. Falha e ID antigo mostram erro sem falsa confirmação.

Entregas: TASK-041, TASK-042, TASK-044, TASK-045 e TASK-048. Contratos antigos não comprovam implementação destes aceites.


## Identidade Just Three — 17/10/2026

Origem: pedido explícito do responsável para adotar Just Three, remeter às três tarefas diárias e simplificar o cabeçalho. Contrato pronto; substitui as referências visuais a Planner de RN07/CA-004-07 e das telas de entrada da SPEC-005, preservando seus comportamentos. Entrega planejada na TASK-059, ainda não implementada.

- RN21: nome público do app é “Just Three”, sem tradução. Aplicar à marca da barra, home, login, cadastro `/join` e `/users/register`, confirmação de entrada e títulos de navegador onde houver nome do produto. Não modificar conteúdo escrito pelo usuário. Identificadores técnicos `Planner`, `PlannerWeb`, códigos de temas e rotas permanecem estáveis.
- RN22: substituir o check da marca principal por três linhas horizontais de mesmo comprimento, remetendo às três escolhas diárias. Preservar o link da marca para `/`; o símbolo não abre menu de navegação. Reutilizar ícones vetoriais existentes, paletas claro/escuro e tipografia atual; esta mudança não redefine cores nem exige imagem gerada.
- RN23: remover o título redundante “Planner” acima de Hoje, sem substituí-lo por “Just Three” nessa posição. Preservar “Hoje”, indicador de cota, listas e ação “Nova tarefa”.
- RN24: substituir o texto visível “Sair” por ícone de saída, mantendo nome acessível traduzido “Sair” e a operação de encerramento de sessão existente. Tema e saída ficam lado a lado, com centros alinhados verticalmente na mesma altura e áreas de controle equivalentes. Essa interpretação de alinhamento vale em 320 e 1280 px, sem sobreposição; tema segue SPEC-007 RN09.
- CA-004-17: ao visitar as telas de RN21, a marca pública e os títulos que nomeiam o produto usam Just Three; a marca tem três traços, não check. Acionar a marca conserva a navegação existente. Conteúdo de tarefas e labels com a palavra Planner permanece intacto.
- CA-004-18: autenticado em `/tasks` e `/tasks/new`, não há título de marca acima de Hoje; Hoje, cota e Nova tarefa permanecem funcionais. Os ícones de tema e saída ficam na mesma altura nos dois tamanhos definidos em RN24. Acionar saída encerra a sessão e aplica o destino público e tema claro já contratados.

### Tradução de backlog — proposta editorial, fora do aceite da TASK-059

Recomendação: **A fazer**, por ser curto e natural para a lista de tarefas disponíveis para seleção. “Pendências” também abrangeria Hoje e Retry; “Reserva” pode sugerir algo opcional. A fazer ainda é uma categoria ampla, mas a separação visual de Hoje e Retry fornece contexto. Se aprovado, aplicar consistentemente ao título, estados vazios e ações (por exemplo, “Enviar para A fazer”), mantendo `backlog` no domínio. O pedido solicita avaliar uma tradução; não confirma uma escolha. Conservar a tradução atual nesta entrega; esta proposta não bloqueia a identidade e os controles.
