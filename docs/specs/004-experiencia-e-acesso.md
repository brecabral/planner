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
