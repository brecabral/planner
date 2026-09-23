# Quality gate

## Política vigente

Cobertura mínima de **70%**, confirmada pelo responsável e já configurada em `mix.exs` (`test_coverage: [summary: [threshold: 70]]`). O alias `ci` verifica compilação com warnings como erros, formato sem correção automática, Credo estrito e testes com cobertura. Abaixo de 70%, o gate reprova; testes falhando também reprovam.

`precommit` compila, verifica dependências, formata e testa, mas não substitui a medição de cobertura do CI. Comandos e configuração operacional ficam no [README](../../README.md#ci).

## Evidência de qualidade

- Usar testes de intenção para regras e rejeições relevantes, incluindo limite diário, restituição, conclusão idempotente, rollback e concorrência.
- Cobertura mede linhas exercitadas; não comprova todos os ramos nem qualidade das asserções.
- Não baixar o mínimo ou excluir módulos apenas para atingir o percentual. Investigar lacunas do comportamento antes de adicionar testes sem valor.
- Formatação e análise estática complementam revisão e testes; não comprovam arquitetura ou ausência de defeitos.

## CI e proteção

O gate GitHub tem aceite humano na [TASK-003](../tasks/003-infra-github.md). Novas entregas executam o gate vigente; não precisam reabrir a configuração já aceita.
