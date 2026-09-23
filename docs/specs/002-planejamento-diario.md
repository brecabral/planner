---
id: "SPEC-002"
status: ready
requirements: ["RF02", "RF03", "RF06", "RF07", "CA01", "CA02", "CA03", "CA04", "CA05", "CA09"]
---

# 002 — Backlog, retry e três escolhas diárias

## Escopo e origem

Regras confirmadas pelo responsável em 23/09/2026: três escolhas por dia; devolução manual ao backlog restitui escolha, conclusão não restitui e virada leva pendências a retry. Esta spec define cadastro, seleção e ordem de tarefas do usuário autenticado. Labels têm contrato na [SPEC-006](006-labels.md); data e conclusão na [SPEC-003](003-dia-e-historico.md).

## Arquitetura e casos de uso

`Planner.Tasks` é a fronteira de cadastro, seleção, devolução e ordem. Recebe `Accounts.Scope` confiável e consulta o contrato de dia do usuário. A interface não grava estado/cota diretamente e recebe um snapshot coerente de coleções, data e escolhas disponíveis.

A persistência compreende tarefas próprias e uma cota por usuário/data, com unicidade dessa chave e consumo entre zero e três. `kind` diferencia backlog/today/retry nas pendências; conclusão é distinguida pela data original persistida, de modo que concluídas nunca apareçam em listas pendentes. Título é entrada do usuário; proprietário, estado, datas e posição são controlados pelo servidor.

Uma fronteira transacional comum serializa alterações do mesmo usuário, inclusive quando ainda não existe cota para a data. Revalida fuso/dia, normaliza pendências vencidas e aplica comando/cota/posições com rollback integral. Selecionar, devolver, ordenar e concluir usam essa mesma fronteira; usuários distintos não compartilham a cota. O gerador fornece contexto/schema scoped, mas seu CRUD não substitui essas operações de domínio.

## Regras

- RN01: cadastrar título textual não vazio após remover espaços das extremidades cria tarefa no backlog do usuário. Títulos iguais não significam a mesma tarefa. O proprietário vem da autenticação, nunca de um campo do formulário.
- RN02: backlog contém tarefas cadastradas ou retiradas manualmente de hoje. Retry recebe somente tarefas que permaneceram em hoje sem conclusão na virada do dia. Ambas permitem seleção para hoje; cada tarefa aparece em apenas uma coleção corrente. Listar cada uma por criação crescente e ID crescente como desempate.
- RN03: cada transição aceita de backlog/retry para hoje consome uma das três escolhas da data do usuário. Concluir mantém esse consumo; devolver manualmente ao backlog restitui uma escolha. Reordenar não altera a cota. Nova seleção após devolução consome uma escolha novamente; repetir comando para tarefa já em hoje não consome nem duplica. A nova seleção ocupa a última posição.
- RN04: reordenar exige exatamente os IDs das pendências atuais daquele usuário, uma vez cada. Aplicar posições consecutivas de 1 a N. Lista incompleta, duplicada, alheia, desconhecida ou com tarefa concluída é rejeitada integralmente. Comandos concorrentes válidos são serializados.
- RN05: devolver manualmente uma pendência de hoje a coloca no backlog, preserva título, labels e identidade, compacta posições e restitui uma escolha da data corrente. Repetir retorno de tarefa já no backlog não altera nada nem restitui outra escolha. Retry, concluída ou inexistente é rejeitada. Se o dia já virou, revalidar a transição para retry antes do comando; não restituir escolha de hoje por uma seleção vencida.
- RN06: a escolha e sua contabilização são atômicas. A cota vale por usuário/data e persiste independentemente do estado atual da tarefa. Consultas e mutações sempre exigem usuário autenticado; ID de outro usuário tem o mesmo resultado de ID inexistente, sem revelar seus dados.
- RN07: todas as mutações revalidam dia e estado dentro da transação; falha não deixa tarefa movida, posição duplicada ou escolha consumida parcialmente.

## Cenários de aceite

- CA-002-01: cadastrar título válido cria backlog; título vazio, só espaços ou não textual não grava tarefa.
- CA-002-02: selecionar três tarefas e concluir uma mantém três escolhas usadas; tentar a quarta é rejeitado mesmo com apenas duas pendências.
- CA-002-03: com duas escolhas usadas, duas seleções concorrentes disputam a última: apenas uma sucede. Repeti-la enquanto já está em hoje não consome outra escolha.
- CA-002-04: reordenar três IDs próprios persiste a ordem; lista duplicada, incompleta ou alheia não altera tarefa nem cota.
- CA-002-05: com três escolhas usadas, devolver uma pendência ao backlog reduz o consumo para duas; repetir o retorno mantém duas. Selecionar novamente essa tarefa ou outra usa a terceira escolha, preservando identidade e labels.
- CA-002-06: outra sessão altera as pendências; reordenação com conjunto antigo é rejeitada e permite recuperar o estado atual.
- CA-002-07: falha entre seleção/devolução e alteração da cota reverte ambas; reinício preserva a contagem. Devoluções repetidas ou concorrentes da mesma tarefa restituem uma única escolha.
- CA-002-08: A tem três escolhas usadas e B nenhuma; B pode escolher. Consultas e comandos de A usando IDs de B não retornam nem alteram dados de B.

## Dados

Persistir proprietário, título, estado, ordem corrente, data da seleção e contagem ou registros duráveis de consumo e restituição por usuário/data. A cota corrente inclui escolhas pendentes e concluídas e desconta devoluções manuais, uma vez cada. Não deduzir escolhas usadas contando apenas pendências. O scaffold e os ajustes físicos são entregues incrementalmente pelas tarefas produtoras.

## Implementação

Distribuída em tarefas pequenas; consultar o [mapa de entregas](../tasks/README.md). Esta spec permanece o contrato comum dos casos de uso acima.
