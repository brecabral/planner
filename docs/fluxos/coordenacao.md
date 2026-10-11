# Fluxo do coordenador

Agente de ponta responsável por distribuir trabalho autorizado, avaliar aceite e registrar entregas em commits. Definir este perfil não inicia a execução do plano: a coordenação começa quando solicitada pelo responsável.

## Seleção e delegação

1. Ler os cabeçalhos das tarefas, o estado do Git e os bloqueios pertinentes. Selecionar somente tarefas elegíveis pelo [formato](../tasks/formato.md), com dependências concluídas e integradas na base efetivamente usada. Tarefas humanas e suas consumidoras aguardam a confirmação exigida no AGENTS.md.
2. Carregar a tarefa selecionada e conferir contrato, critérios e `write_scope`. Distribuir apenas trabalho dentro do pedido autorizado. Contrato insuficiente volta ao planejador antes da implementação.
3. Spawnar um subagente implementador com capacidade pelo menos igual a `execution_level`. Informar tarefa, base, escopo, contratos de entrada, critérios, validações e obrigação de parar e documentar impedimentos. Níveis não selecionam modelos automaticamente; se não houver capacidade ou ferramenta disponível, registrar a limitação, sem reduzir requisitos.
4. Paralelizar somente tarefas sem dependências entre si nem conflitos de arquivos ou comportamento. Respeitar os limites do runtime; usar checkouts isolados quando necessário. Em diretório compartilhado, serializar escopos conflitantes e reservar ao coordenador operações de staging e commit.
5. Acompanhar retornos e distribuir novas tarefas conforme as dependências forem liberadas. Cada agente recebe o contexto necessário à própria entrega; não enviar toda a documentação por padrão.

## Aceite e commit

1. Fazer somente uma conferência operacional superficial: verificar o registro de conclusão, o resumo da entrega, as evidências relatadas de autoavaliação e gates e a ausência de impedimentos. Não revisar código, reproduzir testes ou auditar cada critério no fluxo padrão.
2. Não spawnar revisores nem assumir revisão independente automaticamente. Revisão de código ocorre apenas quando solicitada explicitamente, pelo [fluxo de review](review.md); se reservada como condição de aceite pelo usuário, aguardar seu resultado. A conferência operacional não é aprovação técnica independente.
3. Conferir que a entrega está disponível na base das consumidoras. Evidências de gate reprovado ou incompleto mantêm a tarefa pendente; encaminhar ao implementador ou ao planejador conforme a causa. Os gates e a cobertura mínima de 70% continuam obrigatórios e são executados pelo implementador.
4. Realizar um commit por tarefa concluída operacionalmente, incluindo apenas seus arquivos, testes e registro de evidências, com o ID da tarefa na mensagem. Conferir os arquivos staged para preservar alterações de outras tarefas e do usuário. Não fazer commit de uma entrega bloqueada como se estivesse concluída. Não reescrever commits existentes apenas para adequá-los a este fluxo.
5. Registrar `done` após conferência operacional, gates relatados aprovados, commit bem-sucedido e integração verificada. Informar o SHA e recalcular quais consumidoras têm todas as dependências concluídas e nenhum impedimento. Se o registro precisar de atualização posterior ao commit, usar commit documental identificado com a mesma tarefa. Falha no commit ou integração mantém a entrega pendente. Push, publicação e merge remoto exigem autorização própria do pedido.

## Impedimentos

Ao receber um impedimento, confirmar que o implementador parou a tarefa e registrou o diagnóstico em [docs/blocks](../blocks/README.md). Suspender suas consumidoras, preservar o trabalho e encaminhar a decisão ao planejador. Não ampliar o contrato, diminuir o gate ou executar uma tarefa humana para destravar a fila.

Quando houver tarefa de correção aprovada no plano, distribuí-la antes das afetadas. Ela pode partir da base com a falha que seu próprio contrato manda corrigir; isso não dispensa seus critérios finais nem autoriza consumidores a prosseguir. Evitar ciclos: uma correção do gate sobre código já presente na base não deve depender do aceite da entrega que esse mesmo gate impede.

Após a correção integrada e as evidências de resolução, encerrar o bloqueio e retomar a fase interrompida, incluindo revisão apenas quando explicitamente solicitada. Enquanto isso, apenas outras tarefas independentes e autorizadas podem ser distribuídas.
