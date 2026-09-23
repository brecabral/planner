# Impedimentos de execução

Um arquivo `NNN-descricao.md` por impedimento, com ID estável `BLOCK-NNN`. Reutilizar o registro existente quando a causa for a mesma. Estes documentos guardam diagnóstico e condição de retomada; o grafo permanece nos cabeçalhos das tarefas.

## Ao encontrar um impedimento

O implementador para a tarefa e preserva o diff, sem apagar trabalho, ampliar escopo ou realizar commit de conclusão. Registra:

- Estado: aberto ou resolvido; tarefa de origem e data.
- Base/commit, causa e evidência objetiva, distinguindo fatos de hipóteses.
- Trabalho preservado, impacto e condição verificável de retomada.
- Decisão necessária ou tarefa de correção definida pelo planejador.
- Quando resolvido: evidência de validação e referência da entrega integrada.

Comunicar o registro ao coordenador e referenciá-lo na tarefa. Preservar a fase atual (`in_progress` ou `in_review`); usar `blockers` para impedimentos sem solução planejada. Quando existir uma tarefa corretiva, registrar a dependência em `depends_on`, sem repetir essa aresta em `blockers`. A existência do relatório não libera nem conclui tarefas.

O coordenador só encerra o relatório quando a condição de retomada estiver comprovada: correção de código validada e integrada, decisão explícita registrada nos contratos ou confirmação humana com evidência de aceite, conforme a causa. Retomar as tarefas na fase interrompida, sem considerar resolvidas outras pendências de revisão. Falhas esperadas no TDD e correções rotineiras dentro do escopo não exigem relatório. A tarefa corretiva pode trabalhar sobre a falha explicitamente prevista em seu contrato, mas precisa entregar o gate aprovado.

## Registros

- [BLOCK-001 — Cobertura após a remoção do CRUD experimental](001-cobertura-apos-remocao-crud.md).
