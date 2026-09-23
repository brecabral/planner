---
id: "SPEC-003"
status: draft
requirements: ["RF04", "RF05", "RF09", "CA06", "CA07", "CA08", "CA14"]
---

# 003 — Dia do usuário, retry e histórico

## Escopo e decisões confirmadas

O usuário define seu fuso no gerenciamento da conta. Na virada do dia, tarefas não executadas passam a retry. Decisões confirmadas pelo responsável em 23/09/2026.

## Arquitetura e casos de uso

Esta capacidade une configuração de fuso, cálculo de data, virada do planejamento, conclusão e consulta histórica. A conta armazena o fuso; um serviço de data converte instante em dia local; o contexto de tarefas aplica transições e preserva a data original de conclusão. A LiveView apenas solicita atualização.

Relógio controlável permite testar dois fusos e meia-noite sem modificar relógio global. A alteração do fuso usa a mesma serialização por usuário que os comandos do planejamento. Ler após parada deve produzir o mesmo resultado de uma sessão continuamente aberta: timers não são requisito para consistência dos dados.

## Regras

- RN01 (confirmada): salvar fuso válido na própria conta persiste a preferência; entrada inválida não altera preferência nem tarefas. A data é calculada no servidor usando o instante atual e o fuso do proprietário, nunca uma data livre enviada pelo cliente.
- RN02: cada consulta/comando usa uma data de referência coerente. Ao mudar o dia, pendências de data anterior passam a retry sem conclusão automática. Isso funciona mesmo se a aplicação estava parada; não depende de uma sessão aberta executar um timer.
- RN03: a cota pertence ao usuário/data. Novo dia inicia com zero escolhas, se não houver escolhas já registradas naquela data. Reinício, reconexão e nova leitura não zeram registros existentes.
- RN04: somente tarefa selecionada para hoje pode ser concluída. Persistir data local da conclusão, retirar pendência e compactar ordem atomicamente. Backlog, retry, tarefa alheia ou inexistente são rejeitados. A conclusão não devolve escolha.
- RN05: repetir conclusão preserva o resultado e a data original, inclusive em outro dia. Concorrer conclusão e devolução manual revalida o segundo comando: conclusão vencedora mantém a escolha consumida; devolução vencedora retorna ao backlog e restitui uma escolha. Não produzir tarefa simultaneamente pendente e concluída.
- RN06: histórico próprio contém somente concluídas, por data decrescente e ID decrescente como desempate. Datas de conclusões já registradas não são recalculadas ao mudar fuso. Reabertura e exclusão não integram esta entrega.
- RN07 (proposta): sessão conectada verifica a mudança de data em até 60 segundos; comandos e reconexões a verificam imediatamente.

## Cenários de aceite

- CA-003-01: atravessar a meia-noite no fuso de A move suas pendências a retry; B, cujo dia não mudou, mantém as suas em hoje.
- CA-003-02: sessão aberta atualiza as listas após a virada; reconexão também recupera o dia corrente. O prazo segue RN07.
- CA-003-03: concluir tarefa corrente cria uma entrada na data local e não repõe escolha; repetir amanhã mantém data e identidade.
- CA-003-04: concluir ou reordenar a partir de tela do dia anterior é rejeitado sem seleção implícita; retornar o estado corrente para atualização da tela.
- CA-003-05: duas conclusões simultâneas geram uma única conclusão; disputa entre retorno e conclusão produz um único estado válido.
- CA-003-06: reinício preserva histórico e cota; instantes próximos da meia-noite UTC respeitam o fuso de cada usuário.
- CA-003-07: salvar fuso inválido ou tentar alterar o de outra conta é rejeitado sem efeito. Salvar fuso válido obedece à política de vigência a decidir abaixo.
- CA-003-08: alterar fuso enquanto outra conexão seleciona tarefa, com instante controlado, nas duas ordens de aquisição da trava. Mudança que cruza a data local ou retorna a uma data já usada aplica a política de vigência aprovada: a seleção usa a data efetiva correta, a cota preserva consumo prévio e as pendências têm o destino definido, sem restituição indevida. Fixar os resultados concretos dessas combinações ao resolver a política abaixo, antes de marcar a spec como ready.

## Decisões pendentes

Definir o fuso antes da primeira escolha (seleção obrigatória no cadastro ou no primeiro acesso) e a vigência de alterações de fuso com planejamento ativo. A política deve especificar o destino das pendências e impedir reposição indevida da cota, inclusive ao voltar a uma data já usada. Confirmar o prazo de RN07. Estes pontos bloqueiam a implementação do contrato de dia; o fuso por usuário e o destino retry já estão confirmados.

## Dados e implementação

Persistir fuso na conta, data de escolha e data original de conclusão. A capacidade é entregue em etapas de persistência, cálculo, configuração, transições e interface; ver [mapa de entregas](../tasks/README.md).
