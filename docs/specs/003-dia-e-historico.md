---
id: "SPEC-003"
status: ready
requirements: ["RF04", "RF05", "CA06", "CA07", "CA08"]
---

# 003 — Data corrente, retry e histórico

## Escopo e arquitetura

O MVP usa `Date.utc_today()` do Elixir, sem configuração de fuso ou horário na interface. Persistir datas de negócio como `Date`/coluna `date`; timestamps técnicos gerados pelo Ecto não definem o dia do planejamento. Decisão do responsável em 23/09/2026.

Um contrato pequeno fornece a data corrente no servidor e permite controlá-la nos testes. Consultas/comandos do contexto normalizam a virada; a LiveView não tem timer, polling ou atualização automática. O usuário recarrega a página quando precisar. A resposta de uma ação feita no painel pode atualizar seu resultado normalmente.

## Regras

- RN01: cada consulta/comando usa uma data coerente obtida no servidor. Não aceitar data livre ou fuso do navegador como autoridade.
- RN02: ao consultar ou executar comando num novo dia, pendências de data anterior passam a retry, sem conclusão automática. Isso funciona depois de parada/reinício; não requer processo em segundo plano.
- RN03: a cota pertence ao usuário/data. Uma data nova começa com zero escolhas, salvo se já houver consumo registrado nela. Recarga e reinício não zeram registros existentes.
- RN04: concluir tarefa de hoje persiste a data corrente, retira a pendência e compacta a ordem atomicamente. Não restitui escolha. Backlog, retry e ID inválido são rejeitados.
- RN05: repetir conclusão mantém resultado/data original. Disputa com devolução produz um único vencedor: conclusão mantém consumo; devolução ao backlog restitui uma escolha.
- RN06: histórico contém concluídas, por data decrescente e ID decrescente no desempate. Não oferece reabertura/exclusão nem mostra horário.
- RN07: página ociosa pode permanecer com estado antigo. Recarga lê o novo dia; qualquer comando revalida o estado no servidor antes de gravar.

## Cenários de aceite

- CA-003-01: mudar a data controlada e consultar move pendências anteriores a retry sem alterar conclusões ou identidade.
- CA-003-02: deixar a página aberta durante a virada não exige atualização; recarregar mostra retry e cota corrente.
- CA-003-03: concluir tarefa corrente registra a data e mantém consumo; repetir em outra data não muda a conclusão original.
- CA-003-04: comando enviado por tela do dia anterior revalida a virada; concluir/reordenar pendências vencidas é rejeitado sem seleção implícita.
- CA-003-05: duas conclusões ou conclusão contra devolução concorrentes não duplicam resultado nem restituem cota indevidamente.
- CA-003-06: reinício mantém histórico/cota; instantes não são usados como campos de agendamento ou conclusão.

## Implementação

Contrato de data, normalização, conclusão, consulta e recarga são implementados em etapas no [mapa de tarefas](../tasks/README.md). Não há decisão de fuso bloqueando o MVP.
