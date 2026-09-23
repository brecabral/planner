---
name: review-plan-alignment
description: Revisar se specs e tarefas do Planner atendem às decisões atuais de produto, com aceites executáveis, dependências válidas e separação entre MVP e evolução; sem replanejar ou implementar durante a revisão.
---

# Revisar alinhamento entre specs e tarefas

Usar para avaliar propostas ou conferir uma atualização do plano. Para produzir correções documentais autorizadas, encaminhar a [reconcile-plan](../reconcile-plan/SKILL.md); revisão sozinha não autoriza editar os contratos.

## Base e autoridade

Começar pelo pedido, estado do Git e documentos afetados. Identificar se o alvo é commit, diff ou proposta local, incluindo arquivos não rastreados pertinentes. Ler o PRD e as regras das specs relacionadas; abrir os cabeçalhos das tarefas e aprofundar os corpos envolvidos. Aplicar o [fluxo de review](../../fluxos/review.md) ao relato, distinguindo análise documental de validação de código.

Usar as decisões explícitas mais recentes do responsável. Confirmar como foram registradas, sem restaurar requisitos antigos por preferência técnica. Separar decisão, proposta, dúvida e evidência. O review anterior é uma hipótese a reavaliar: classificar achados como persistentes, resolvidos ou superados por mudança de escopo. Não congelar nesta skill escolhas de autenticação, idiomas, data, publicação ou limites do produto; suas fontes são PRD e specs vigentes.

## Conferência semântica

- Relacionar objetivo/requisito → regra/cenário → tarefa produtora → evidência prevista. Conferir resultados observáveis e rejeições, sem exigir repetição integral da spec em cada tarefa.
- Simular sequências que combinam regras: selecionar, devolver, selecionar novamente, concluir e mudar a data. Procurar contradições entre requisitos, invariantes e aceite; usar os exemplos atuais do produto, não inventar política para resolver uma dúvida.
- Conferir a disponibilidade de cada operação na etapa que promete testá-la. Um cenário que chama uma operação produzida por descendente não é integralmente executável. Estado preparado em fixture pode testar uma parte, mas não substitui o fluxo integrado. Recomendar redistribuir o aceite, sem criar uma dependência circular.
- Rastrear promessas como “a integração será testada na tarefa seguinte” até o aceite da responsável. Distinguir teste de uma infraestrutura comum do teste das operações reais que a compõem.
- Avaliar se evolução futura entrou como pré-requisito do MVP sem decisão de produto. Melhorias úteis, como recuperação de backup, não se tornam requisitos de persistência após reinício por equivalência presumida.
- Testes de proprietário incompatível podem usar fixtures sem implicar contas interativas ou login. Nomes antigos de arquivos e uso de termos como conta não bastam para provar expansão de comportamento; conferir o contrato completo.

## Grafo e viabilidade

Usar o [formato das tarefas](../../tasks/formato.md) como fonte do esquema. Conferir IDs e produtores únicos, referências existentes, ciclos, consumos alcançáveis, specs prontas e consistência de estados. Verificar também dependências humanas e integração, sem presumir conclusão pelo texto da proposta.

Nos pares paralelizáveis, comparar arquivos e responsabilidade semântica. Serialização pode ser uma escolha válida para recursos compartilhados; não exigir paralelismo por estética. Tarefas futuras explicitamente bloqueadas são reservas de escopo, não entregas executáveis cujo aceite precise estar definido agora.

Distinguir estrutura válida de execução viável: uma base com gate falhando pode impedir a sequência mesmo sem ciclos. Identificar a condição de retomada e apontar o [registro de impedimento](../../blocks/README.md) existente. Não planejar uma correção detalhada, executar uma tarefa humana ou reduzir gates para aprovar o plano.

## Parecer e mudanças autorizadas

Para cada defeito, registrar arquivo/linha, cenário concreto, resultado conflitante ou ausente, impacto e correção esperada. Separar bloqueios documentais, decisões pendentes, impedimentos de implementação e sugestões opcionais. Informar cobertura documental e seus limites; não apresentar testes previstos como executados.

Respeitar o destino solicitado para o relatório. Se o pedido for somente revisão, manter tarefas/specs intactas. Se houver autorização condicional para esvaziar um relatório e criar commit, primeiro verificar a condição no escopo pedido; aprovação do alinhamento não aprova código, não encerra impedimentos de execução e não marca tarefas como concluídas. Preservar essas evidências em suas fontes. Antes do commit autorizado, conferir se os arquivos revisados mudaram e inspecionar o staged; não incluir trabalho alheio.

Para validar alterações desta skill, usar os [casos de avaliação](references/cenarios.md), sem executar ações reais dos exemplos.
