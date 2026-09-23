---
name: coordinate-delivery
description: Conduzir o aceite de uma entrega do Planner, revisão independente, integração e commit por tarefa; usar no retorno do implementador, sem confundir autoavaliação com aprovação ou autorizar publicação remota.
---

# Conduzir aceite e registrar entrega

Aplicar o [fluxo de coordenação](../../fluxos/coordenacao.md) à tarefa entregue. Ao validar código, carregar o [fluxo de review](../../fluxos/review.md) e identificar se a atuação é conferência de coordenação ou revisão independente. A avaliação precisa referir-se ao diff efetivo e à base correspondente.

## Conferir o pacote recebido

Relacionar cada critério à alteração e à evidência observável. Conferir arquivos, limites do contrato, resultados de validação, cobertura e base testada. Não inferir aprovação pelo resumo do agente ou apenas pelo número de testes. Um `precommit` verde não comprova que o CI passou; percentual sem o gate correspondente também não comprova aceite.

Exigir o gate vigente na documentação e configuração do projeto, com o conjunto de módulos medidos preservado. Se houver evidência histórica divergente, identificar a regra atual sem apagar o registro anterior. Não acrescentar testes fora do contrato, diminuir limiar ou excluir módulos para desbloquear uma entrega; encaminhar o impedimento pelo [protocolo](../../blocks/README.md).

## Obter revisão independente

- Encaminhar tarefa, critérios/specs, alvo/base, diff e evidências a revisor de ponta. Não apresentar a conclusão desejada como premissa da revisão.
- O coordenador pode revisar quando não participou da implementação; se escreveu correções da entrega, usar outro revisor. Registrar identidade e independência. Autoavaliação do implementador não satisfaz essa etapa.
- Devolver achados corrigíveis dentro do escopo ao implementador e exigir reavaliação das alterações. Achados que exigem decisão ou expansão do contrato seguem [coordinate-blockers](../coordinate-blockers/SKILL.md).
- Se o usuário reservou a revisão a outro revisor ou ao fim da rodada, respeitar esse encaminhamento: manter `in_review` e consumidoras suspensas até receber aprovação. Não assumir nem fabricar a revisão reservada.

## Integrar e fazer commit

Após aprovação, conferir a integração na base usada pelas consumidoras e validar o resultado integrado. Evidências do mesmo estado continuam úteis; mudanças relevantes na integração exigem nova avaliação e verificações afetadas. Não repetir testes sem mudança ou dúvida concreta.

Reservar ao coordenador staging e commit, sobretudo em diretório compartilhado. Conferir o conteúdo staged e incluir somente a tarefa aceita, testes e evidências; não capturar alterações preexistentes ou de outro agente. Um commit de entrega por tarefa, com ID na mensagem. Preservar commits anteriores; correções posteriores devem ser identificadas com a mesma tarefa, sem reescrever histórico para simular entrega única.

Só liberar consumidoras quando houver aprovação independente, gate verde, commit bem-sucedido e integração verificada. Finalizar o estado e registro da tarefa após essas confirmações. Se o SHA ou a conclusão precisar de atualização posterior, usar commit documental identificado com o ID, conforme o fluxo. Falha de commit ou integração mantém a entrega pendente.

Commit de diagnóstico, quando solicitado, não é commit de entrega aceita. Não declarar uma tarefa bloqueada como concluída. Push, merge remoto e publicação não decorrem da autorização para commits locais.

Entregar ID, SHA, critérios/evidências, revisão, estado da integração e próximas tarefas realmente liberadas. Apontar limites de validação sem alegar aprovação onde houver pendência.
