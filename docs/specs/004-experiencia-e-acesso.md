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
- RN03: selecionar, devolver ao backlog, reordenar e concluir têm controles nomeados. Reordenação oferece subir/descer. Operação por teclado, foco e layout em 360px/desktop pertencem à validação humana descrita no PRD, fora dos aceites das tarefas.
- RN04: erros de campo aparecem associados ao campo; limite, conflito e falha de gravação são visíveis e acessíveis. Indicar processamento, impedir submissão duplicada enquanto pendente e nunca mostrar sucesso antes de persistir.
- RN05: depois de sucesso ou rejeição por estado antigo, mostrar o estado autoritativo. A avaliação do foco após ações pertence à validação humana. Recarga/reconexão restaura dados persistidos. Atualização instantânea de abas ociosas por mudanças de outra aba não é exigida.
- RN06: textos, erros e nomes acessíveis usam Gettext em pt-BR. Cota esgotada continua visível mesmo que a lista de hoje esteja vazia após conclusões.

## Cenários de aceite

- CA-004-01: sem tarefas cadastradas, cadastrar tarefa com labels e selecionar a coloca em hoje; recarga mantém identidade e classificação.
- CA-004-02: nos testes LiveView, cadastrar, selecionar de backlog/retry, subir/descer, devolver e concluir pelos controles do painel produz o estado esperado, preservado após remontagem. Esse aceite verifica eventos e estrutura, sem comprovar teclado, foco ou layout reais.
- CA-004-03: falha de gravação mostra erro sem apresentar movimentação ou cota como confirmadas; leitura seguinte recupera estado persistido.
- CA-004-04: ação com estado antigo é rejeitada e atualiza coleções e cota sem duplicação; reconexão mantém pt-BR.
- CA-004-05: em pt-BR, histórico e escolhas usadas são compreensíveis; título e labels digitados permanecem iguais.
- CA-004-06: após concluir as três escolhas, hoje pode estar vazio, mas o painel informa que a cota diária acabou e o servidor rejeita outra seleção.

A associação estrutural de erros aos campos, os nomes dos controles e a marcação de alertas são verificáveis nos testes existentes. Anúncios efetivos por tecnologias assistivas são parte da [validação humana do PRD](../prd.md#validação-humana-da-interface--fora-das-tarefas), sem bloqueio das tarefas.

## Implementação

Distribuída em tarefas pequenas; consultar o [mapa de entregas](../tasks/README.md). Esta spec permanece o contrato comum dos casos de uso acima.
