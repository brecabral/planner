# BLOCK-006 — Isolamento do projeto Compose de teste

- Estado: resolvido operacionalmente em 16/10/2026.
- Origem: TASK-055, achado R7 da revisão independente de 16/10/2026; escopo revisado conjunto TASK-055/057.
- Alvo avaliado: `e1909ea52d038baf9336158d6f9a377df5bf1537`.

## Causa e evidência

O [review](../review.md) registra que a resolução de compose.test.yaml com `COMPOSE_PROJECT_NAME=planner` resulta em projeto `planner` e rede `planner_default`. As receitas de teste não fixam a opção de projeto; o ambiente herdado prevalece sobre `name`. Subida/remoção pode atingir o container postgres de desenvolvimento. Não há evidência de apagamento do volume persistente nem execução destrutiva nessa reprodução.

## Trabalho preservado e impacto

Entregas TASK-055/057 continuam integradas, com resultados históricos preservados; isso não significa aprovação independente. A correção é um incremento separado. TASK-056 e TASK-050 permanecem planejadas e aguardam o isolamento para executar seus gates locais. CI remoto continua não verificado, limite independente de R7 e já previsto no contrato da TASK-057.

## Decisão do planejador — 16/10/2026

[TASK-058](../tasks/058-isolar-projeto-compose-teste.md) fixa a identidade do projeto de teste e acrescenta regressão com ambiente adverso. Dependências constam somente nos cabeçalhos das tarefas; não duplicar a solução em `blockers`. Não reabrir entregas históricas nem criar ciclo entre correção e aprovação do escopo afetado.

## Condição de retomada

Coordenador confere correção validada e integrada, regressão de up/down/limpeza com ambiente adverso e gates completos, incluindo E2E. Só então encerra este registro e libera as consumidoras cujas demais dependências estejam concluídas. O revisor revalida R7 para alterar o parecer independente; planejamento ou encerramento operacional não equivalem a aprovação técnica. Até lá, R7 permanece aberto no review.

## Encerramento operacional — 16/10/2026

TASK-058 integrada em `633b400` e conferida operacionalmente pelo coordenador `/root`. O implementador relatou regressão vermelha na base e verde após a correção, com receitas reais interceptadas sob os três ambientes exigidos; resolução Compose real somente de leitura confirmou `planner-test`. `just check` aprovado com 245 testes ExUnit, cobertura mínima de 70% preservada e dois E2E; `just precommit` aprovado. Evidências completas e limitações no registro da tarefa; artefatos em `tmp/e2e/run-sdGEO2t9/`.

Condição de retomada satisfeita; TASK-056 e TASK-050 podem prosseguir conforme o grafo. Este encerramento não altera R7 ou o parecer independente de `docs/review.md`, nem comprova CI remoto.
