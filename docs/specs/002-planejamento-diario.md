---
id: "SPEC-002"
status: ready
requirements: ["RF02", "RF03", "RF06", "RF07", "CA01", "CA02", "CA03", "CA04", "CA05", "CA09"]
---

# 002 — Backlog, retry e três escolhas diárias

## Escopo e origem

Regras confirmadas pelo responsável em 23/09/2026: três escolhas por dia; devolução manual ao backlog restitui escolha, conclusão não restitui e virada leva pendências a retry. Esta spec define cadastro, seleção e ordem de tarefas do usuário padrão. Labels têm contrato na [SPEC-006](006-labels.md); data e conclusão na [SPEC-003](003-dia-e-historico.md).

## Arquitetura e casos de uso

`Planner.Tasks` é a fronteira de cadastro, seleção, devolução e ordem. Recebe o usuário padrão resolvido pelo servidor e consulta o contrato de data corrente. A interface não grava estado/cota diretamente e recebe um snapshot coerente de coleções, data e escolhas disponíveis.

A persistência compreende tarefas próprias e uma cota por usuário/data, com unicidade dessa chave e consumo entre zero e três. `kind` diferencia backlog/today/retry nas pendências; conclusão é distinguida pela data original persistida, de modo que concluídas nunca apareçam em listas pendentes. Título é entrada do usuário; proprietário, estado, datas e posição são controlados pelo servidor.

Uma fronteira transacional comum serializa alterações do mesmo usuário, inclusive quando ainda não existe cota para a data. Revalida a data corrente, normaliza pendências vencidas e aplica comando/cota/posições com rollback integral. Selecionar, devolver, ordenar e concluir usam essa mesma fronteira; usuários distintos não compartilham a cota. O gerador fornece contexto/schema com proprietário explícito, mas seu CRUD não substitui essas operações de domínio.

## Regras

- RN01: cadastrar título textual não vazio após remover espaços das extremidades cria tarefa no final do backlog do usuário. Títulos iguais não significam a mesma tarefa. O proprietário vem do usuário padrão no servidor, nunca de um campo do formulário.
- RN02: backlog contém tarefas cadastradas ou retiradas manualmente de hoje. Retry recebe somente tarefas que permaneceram em hoje sem conclusão na virada do dia. Ambas permitem seleção para hoje; cada tarefa aparece em apenas uma coleção corrente. Listar cada uma pela posição persistida crescente.
- RN03: cada transição aceita de backlog/retry para hoje consome uma das três escolhas da data do usuário. Concluir mantém esse consumo; devolver manualmente ao backlog restitui uma escolha. Reordenar não altera a cota. Nova seleção após devolução consome uma escolha novamente; repetir comando para tarefa já em hoje não consome nem duplica. A seleção pelo menu ocupa a última posição; arraste insere na posição escolhida.
- RN04: reordenar exige exatamente os IDs das pendências atuais da lista (hoje, backlog ou retry) daquele usuário, uma vez cada. Aplicar posições consecutivas de 1 a N. Lista incompleta, duplicada, alheia, desconhecida ou com tarefa concluída é rejeitada integralmente. Comandos concorrentes válidos são serializados.
- RN05: devolver manualmente uma pendência de hoje a coloca no backlog, preserva título, labels e identidade, compacta posições e restitui uma escolha da data corrente. Repetir retorno de tarefa já no backlog não altera nada nem restitui outra escolha. Concluída ou inexistente é rejeitada. Retry pode ser enviado ao backlog conforme RN11, sem restituição. Se o dia já virou, revalidar a transição para retry antes do comando; não restituir escolha de hoje por uma seleção vencida.
- RN06: a escolha e sua contabilização são atômicas. A cota vale por usuário/data e persiste independentemente do estado atual da tarefa. Consultas e mutações sempre exigem usuário resolvido pelo servidor; ID de outro usuário tem o mesmo resultado de ID inexistente, sem revelar seus dados.
- RN07: todas as mutações revalidam dia e estado dentro da transação; falha não deixa tarefa movida, posição duplicada ou escolha consumida parcialmente.

## Cenários de aceite

- CA-002-01: cadastrar título válido cria backlog; título vazio, só espaços ou não textual não grava tarefa.
- CA-002-02: selecionar três tarefas e concluir uma mantém três escolhas usadas; tentar a quarta é rejeitado mesmo com apenas duas pendências.
- CA-002-03: com duas escolhas usadas, duas seleções concorrentes disputam a última: apenas uma sucede. Repeti-la enquanto já está em hoje não consome outra escolha.
- CA-002-04: reordenar três IDs próprios persiste a ordem; lista duplicada, incompleta ou alheia não altera tarefa nem cota.
- CA-002-05: com três escolhas usadas, devolver uma pendência ao backlog reduz o consumo para duas; repetir o retorno mantém duas. Selecionar novamente essa tarefa ou outra usa a terceira escolha, preservando identidade e labels.
- CA-002-06: outra sessão altera as pendências; reordenação com conjunto antigo é rejeitada e permite recuperar o estado atual.
- CA-002-07: falha entre seleção/devolução e alteração da cota reverte ambas. Devoluções repetidas ou concorrentes da mesma tarefa restituem uma única escolha.
- CA-002-08: A tem três escolhas usadas e B nenhuma; B pode escolher. Consultas e comandos de A usando IDs de B não retornam nem alteram dados de B.

## Dados

Persistir proprietário, título, estado, ordem corrente, data da seleção e contagem ou registros duráveis de consumo e restituição por usuário/data. A cota corrente inclui escolhas pendentes e concluídas e desconta devoluções manuais, uma vez cada. Não deduzir escolhas usadas contando apenas pendências. O scaffold e os ajustes físicos são entregues incrementalmente pelas tarefas produtoras.

## Implementação

Distribuída em tarefas pequenas; consultar o [mapa de entregas](../tasks/README.md). Esta spec permanece o contrato comum dos casos de uso acima.

## Movimentação autorizada — 09/10/2026

- RN08: arraste aceita reordenação nas três listas e somente backlog → hoje, retry → hoje, hoje → backlog e retry → backlog (incremento RN11). Recebe tarefa, origem, destino e ordens finais completas das listas afetadas. Validar transição, proprietário, IDs sem duplicatas e conjuntos atuais sob o lock por usuário; nenhuma outra tarefa muda de lista. Transferência, compactação da origem, ordem do destino e cota são atômicas.
- RN09: posições são positivas, consecutivas e únicas por usuário/lista de pendências. Cadastro também usa o lock do usuário e acrescenta ao final do backlog. Migração inicializa backlog/retry pela criação/ID e preserva hoje e concluídas. `reorder_today/3` continua compatível.
- RN10: conjuntos desatualizados são rejeitados; reordenações concorrentes do mesmo conjunto são serializadas e prevalece a última aceita. Erros de escrita revertem integralmente posições, transferência, normalização e cota.
- CA-002-09: reordenar cada uma das três listas e recarregar preserva a permutação e a cota. Cadastro subsequente ocupa o final do backlog.
- CA-002-10: transferir para início, meio, fim e destino vazio conserva identidade/labels, compacta origem e aplica consumo/restituição. Menu insere ao final.
- CA-002-11: cota esgotada, destino proibido, IDs inválidos/alheios/duplicados, origem incorreta ou conjunto desatualizado rejeitam integralmente. Concorrência e falha de persistência não deixam estado parcial.

## MVP de produção — 11/10/2026

Incremento autorizado pelo responsável. Os aceites anteriores permanecem históricos. RN11–RN13 foram implementadas e integradas pelas TASK-042/043, com interface na TASK-044; as evidências constam nessas tarefas e na revisão de 13/10/2026 em [review](../review.md). O aceite integrado do release local permanece na TASK-050. Na produção, “usuário padrão” nas regras anteriores é substituído pelo proprietário autenticado da SPEC-005.

- RN11: enviar retry ao backlog preserva identidade, título e labels, compacta retry e insere no fim pelo menu ou na posição escolhida pelo arraste. Não consome nem restitui escolhas, inclusive com cota esgotada. Usa a mesma transação, normalização de data e validação de conjuntos de RN08–RN10. Backlog → retry e hoje → retry continuam proibidos. Após a virada, um comando de arraste com origem antiga é rejeitado e recompõe o estado; não é reinterpretado silenciosamente.
- RN12: excluir definitivamente uma pendência própria em backlog/retry/hoje remove tarefa e seus vínculos, preserva o catálogo de labels e compacta a lista. Excluir de hoje restitui exatamente uma escolha corrente; backlog/retry não alteram consumo. Concluídas não podem ser excluídas. O responsável confirmou esse contrato em 11/10/2026.
- RN13: exclusão recebe ID e proprietário do servidor, normaliza a data e usa o lock do usuário. Se a pendência venceu, é tratada como retry e não restitui consumo do novo dia. ID ausente/alheio/repetido retorna indisponível sem mutação ou revelação de dados. Falha reverte exclusão, vínculos, posições, normalização e cota; disputa com concluir/devolver/excluir é serializada e revalida o estado.
- CA-002-12: com retry e cota esgotada, mover ao backlog pelo menu/arraste preserva dados, ordem consecutiva e consumo; recarga confirma. Destino vazio/início/meio/fim, payload antigo/alheio e falha transacional são cobertos.
- CA-002-13: excluir de cada lista remove somente tarefa/vínculos, preserva labels e compacta posições; hoje restitui uma escolha uma única vez, backlog/retry não restituem. Repetição e ID alheio não alteram dados.
- CA-002-14: concluída é rejeitada; exclusão após virada não restitui cota nova. Exclusões concorrentes restituem no máximo uma vez; se conclusão vencer, exclusão falha e histórico permanece. Falha de persistência preserva tudo.

Entregas: TASK-042 (RN11) e TASK-043 (RN12–RN13); interface na TASK-044.
