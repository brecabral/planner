# Fluxo do coordenador

Agente de ponta responsável por distribuir trabalho autorizado, avaliar aceite e registrar entregas em commits. Definir este perfil não inicia a execução do plano: a coordenação começa quando solicitada pelo responsável.

## Seleção e delegação

1. Ler os cabeçalhos das tarefas, o estado do Git e os bloqueios pertinentes. Selecionar somente tarefas elegíveis pelo [formato](../tasks/formato.md), com dependências concluídas e integradas na base efetivamente usada. Tarefas humanas e suas consumidoras aguardam a confirmação exigida no AGENTS.md.
2. Carregar a tarefa selecionada e conferir contrato, critérios e `write_scope`. Distribuir apenas trabalho dentro do pedido autorizado. Contrato insuficiente volta ao planejador antes da implementação.
3. Spawnar um subagente implementador com capacidade pelo menos igual a `execution_level`. Informar tarefa, base, escopo, contratos de entrada, critérios, validações e obrigação de parar e documentar impedimentos. Níveis não selecionam modelos automaticamente; se não houver capacidade ou ferramenta disponível, registrar a limitação, sem reduzir requisitos.
4. Paralelizar somente tarefas sem dependências entre si nem conflitos de arquivos ou comportamento. Respeitar os limites do runtime; usar checkouts isolados quando necessário. Em diretório compartilhado, serializar escopos conflitantes e reservar ao coordenador operações de staging e commit.
5. Acompanhar retornos e distribuir novas tarefas conforme as dependências forem liberadas. Cada agente recebe o contexto necessário à própria entrega; não enviar toda a documentação por padrão.

## Aceite e commit

1. Conferir o diff real e as evidências de cada critério. A mensagem de conclusão do implementador não comprova aceite. Validar também escopo, regressões e cobertura mínima de 70% no gate definido pelo projeto.
2. Encaminhar a entrega a um revisor independente de ponta, seguindo o [fluxo de review](review.md). O coordenador pode assumir essa revisão se não participou da implementação; caso contrário, deve spawnar outro revisor. Autoavaliação do implementador nunca substitui aprovação independente.
3. Devolver achados corrigíveis ao implementador e revisar novamente as alterações. Integrar somente a entrega aprovada na base das consumidoras; validar o resultado integrado. Mudanças relevantes após a revisão exigem nova avaliação.
4. Realizar um commit por tarefa aceita, incluindo apenas seus arquivos, testes e registro de evidências, com o ID da tarefa na mensagem. Inspecionar o conteúdo staged; preservar alterações de outras tarefas e do usuário. Não fazer commit de uma entrega bloqueada como se estivesse concluída. Não reescrever commits existentes apenas para adequá-los a este fluxo.
5. Só liberar consumidoras após aprovação, gate verde, commit bem-sucedido e integração verificada. Registrar a conclusão na tarefa e informar o SHA da entrega no retorno. Se o registro de conclusão precisar de atualização posterior ao commit, fazê-la em commit documental identificado com a mesma tarefa. Falha no commit ou integração mantém a entrega pendente. Push, publicação e merge remoto exigem autorização própria do pedido.

## Impedimentos

Ao receber um impedimento, confirmar que o implementador parou a tarefa e registrou o diagnóstico em [docs/blocks](../blocks/README.md). Suspender suas consumidoras, preservar o trabalho e encaminhar a decisão ao planejador. Não ampliar o contrato, diminuir o gate ou executar uma tarefa humana para destravar a fila.

Quando houver tarefa de correção aprovada no plano, distribuí-la antes das afetadas. Ela pode partir da base com a falha que seu próprio contrato manda corrigir; isso não dispensa seus critérios finais nem autoriza consumidores a prosseguir. Evitar ciclos: uma correção do gate sobre código já presente na base não deve depender do aceite da entrega que esse mesmo gate impede.

Após a correção integrada e as evidências de resolução, encerrar o bloqueio e retomar a fase interrompida, incluindo revisão pendente. Enquanto isso, apenas outras tarefas independentes e autorizadas podem ser distribuídas.
