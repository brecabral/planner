---
id: "SPEC-004"
status: ready
requirements: ["RF01", "CA09", "CA10"]
---

# 004 — Experiência do painel

## Escopo

Apresentação do planejamento do usuário autenticado, conforme a experiência definida no PRD. Autenticação e isolamento têm contrato próprio na [SPEC-005](005-contas-e-acesso.md).

## Arquitetura e casos de uso

O painel é uma composição LiveView sobre o contexto de tarefas e o catálogo de labels. Reaproveita Index/Form gerados por Phoenix, reduzindo o CRUD ao fluxo especificado, dentro da sessão autenticada e com locale aplicado. Streams representam backlog, hoje, retry e histórico; contadores e estados vazios vêm do snapshot do domínio.

Cadastro, seleção, devolução, ordenação, conclusão e consulta histórica são casos de uso da mesma experiência. Formulários não transportam autoridade de proprietário ou data. Sucesso/conflito recompõe o estado autorizado; indisponibilidade não vira confirmação otimista de gravação. Montagem/reconexão revalida identidade e data.

## Regras

- RN01: destacar hoje com prioridades numeradas e escolhas usadas no dia; oferecer backlog e retry separados, cadastro e acesso ao histórico e à conta. Estados vazios explicam a ação disponível sem criar tarefas fictícias.
- RN02: cadastro tem título, seleção de várias labels próprias e criação de novas labels. Conteúdo do usuário não é traduzido.
- RN03: selecionar, devolver ao backlog, reordenar e concluir têm controles nomeados, foco visível e operação por teclado. Reordenação oferece subir/descer, sem depender de arrastar. Em 360px e desktop, nenhuma ação fica inacessível por transbordamento horizontal.
- RN04: erros de campo aparecem associados ao campo; limite, conflito e falha de gravação são visíveis e acessíveis. Indicar processamento, impedir submissão duplicada enquanto pendente e nunca mostrar sucesso antes de persistir.
- RN05: depois de sucesso ou rejeição por estado antigo, mostrar o estado autoritativo e preservar foco útil. Recarga/reconexão restaura dados persistidos. Atualização instantânea de abas ociosas por mudanças de outra aba não é exigida.
- RN06: textos, erros e nomes acessíveis usam Gettext em pt-BR e inglês. Cota esgotada continua visível mesmo que a lista de hoje esteja vazia após conclusões.

## Cenários de aceite

- CA-004-01: em conta vazia, cadastrar tarefa com labels e selecionar a coloca em hoje; recarga mantém identidade e classificação.
- CA-004-02: por teclado, em 360px e desktop, cadastrar, selecionar de backlog/retry, subir/descer, devolver e concluir funciona com foco identificável.
- CA-004-03: falha de gravação mostra erro sem apresentar movimentação ou cota como confirmadas; leitura seguinte recupera estado persistido.
- CA-004-04: ação com estado antigo é rejeitada e atualiza coleções e cota sem duplicação; reconexão mantém locale.
- CA-004-05: nos dois idiomas, histórico e escolhas usadas são compreensíveis; título e labels digitados permanecem iguais.
- CA-004-06: após concluir as três escolhas, hoje pode estar vazio, mas o painel informa que a cota diária acabou e o servidor rejeita outra seleção.

## Implementação

Distribuída em tarefas pequenas; consultar o [mapa de entregas](../tasks/README.md). Esta spec permanece o contrato comum dos casos de uso acima.
