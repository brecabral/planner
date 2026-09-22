# Fluxo do implementador

Executa uma tarefa pronta. Agentes `basic`, `standard` e `advanced` seguem o mesmo fluxo, testes e gate; o nível altera o tipo de complexidade atribuída, não o padrão de qualidade.

## Contexto inicial

Ler a tarefa inteira e seus metadados; as regras/critério da spec indicados; contratos/evidências das dependências e os arquivos de entrada listados. Consultar no README apenas execução pertinente. Antes de editar, carregar as referências técnicas dos conceitos atingidos: linguagem, persistência, templates, LiveView, Gettext ou testes. Não carregar todas por precaução nem reconstruir decisões de produto a partir do código antigo.

## Procedimento

1. Confirmar `execution_level`, ausência de bloqueios, specs prontas e dependências concluídas e integradas na base local. Se não souber se atende ao nível, explicitar a incerteza em vez de fingir capacidade.
2. Conferir estado do repositório e preservar alterações alheias. Localizar contratos existentes, dependências necessárias e pontos de entrada. Propor um plano curto limitado à tarefa.
3. Transformar critérios em testes de intenção antes de implementar comportamento. Executar o teste inicial e verificar que a falha representa o comportamento ausente, não erro de setup. Para mudanças somente documentais ou mecânicas, usar validação adequada sem criar testes artificiais.
4. Implementar a menor mudança completa dentro do contrato. Reutilizar recursos fornecidos por dependências e convenções técnicas. Não alterar uma regra para fazer o teste passar; não adicionar dependência, abstração ou funcionalidade fora do escopo.
5. Executar testes específicos e `mix precommit`, corrigindo problemas da entrega. Revisar o próprio diff e avaliar cada critério usando o [fluxo de review](review.md), inclusive cobertura/evals quando aplicáveis. Não atribuir aprovação independente a essa autoavaliação.
6. Preencher evidências por critério: teste/comando/inspeção, resultado e limitações. Marcar `in_review` e encaminhar o diff/base para revisor de ponta. Registrar o que falta para retomada por outro agente.
7. Corrigir achados autorizados, repetir validação afetada e reenviar a revisão. `done` exige gate aprovado e integração; só então consumidoras podem iniciar.

## Quando devolver ao planejamento

Regra ambígua, dependência não entregue, conflito de escopo, contrato compartilhado insuficiente ou risco acima do nível atribuído exigem registrar impedimento e pedir decomposição/decisão ou encaminhamento a capacidade superior. Continuar apenas partes independentes autorizadas. Não diminuir requisitos nem trocar de modelo por conta própria. Descobertas técnicas reutilizáveis vão para a referência pertinente; decisões de produto voltam à spec/design.

## Tarefas humanas

Verificar `execution_level` antes de executar. Se for `human`, ou existir pré-requisito humano incompleto, aplicar a [reserva do AGENTS.md](../../AGENTS.md#execução-exclusiva-por-humano): informar a intervenção necessária e recusar execução dessa tarefa. Explicação e inspeção de evidências em leitura são permitidas; execução parcial, delegação e reclassificação para contornar o bloqueio não são.
