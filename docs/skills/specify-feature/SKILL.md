---
name: specify-feature
description: Converter requisitos do Planner em regras de negócio e cenários de aceite em docs/specs; usar para propor ou revisar comportamento, não para implementar tarefas.
---

# Especificar comportamento

1. Identificar o requisito ou mudança solicitada. Consultar somente as seções pertinentes do PRD e as decisões relacionadas; não ler todos os documentos.
2. Ler o [guia de specs](../../specs/README.md) e usar o [modelo](../../specs/modelo.md) quando criar um arquivo. Se já houver spec do comportamento, atualizá-la em vez de duplicar.
3. Converter intenção em regras numeradas e exemplos de sucesso, rejeição e limites relevantes. Distinguir decisões confirmadas, propostas e perguntas bloqueantes. Não inferir regras a partir do CRUD experimental.
4. Manter specs amplas por capacidade e invariantes arquiteturais, agregando casos de uso relacionados. Não criar uma spec por botão, comando ou tarefa. Separar escopo atual de evolução futura conforme o PRD; usar [scope-mvp](../scope-mvp/SKILL.md) quando essa fronteira precisar ser definida.
5. Definir o resultado observável e os efeitos sobre dados; deixar escolhas de implementação livres quando não alterarem o contrato.
6. Manter `draft` enquanto houver dúvidas bloqueantes. Registrar a evidência das decisões antes de marcar `ready`; não presumir aprovação pela passagem do tempo.
7. Atualizar o índice de specs e os links pertinentes. Entregar o caminho da spec, dúvidas restantes e critérios que permitirão implementar. Não criar código ou iniciar outra tarefa por consequência automática.

Teste de qualidade: outro agente deve conseguir prever o resultado de cada cenário sem consultar a conversa original ou inventar uma regra.

Seguir o [perfil planejador](../../fluxos/planejamento.md). Fornecer condições e resultados explícitos para implementadores de capacidades variadas; deixar referências de código e cenários pertinentes acessíveis sem histórico da conversa.
