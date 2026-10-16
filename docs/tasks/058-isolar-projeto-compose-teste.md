---
id: "TASK-058"
status: "done"
execution_level: "advanced"
execution_rationale: "Corrige isolamento no ciclo de vida de containers com risco de interromper o banco de desenvolvimento; exige regressão segura de subida e remoção."
specs: []
depends_on: ["TASK-057"]
provides: ["test-compose-project-isolation"]
consumes: []
write_scope: ["justfile", "compose.test.yaml", "scripts/", "README.md", "docs/tasks/058-isolar-projeto-compose-teste.md"]
blockers: []
---

# 058 — Fixar isolamento do projeto Compose de teste

## Objetivo e entradas

Corrigir R7 do [review](../review.md) e satisfazer a condição de retomada do [BLOCK-006](../blocks/006-isolamento-compose-teste.md). Manutenção do contrato de infraestrutura da TASK-055, sem nova regra de produto; `specs: []`. Ler justfile, compose.test.yaml, scripts/test-env.sh, testes existentes em scripts/, operação no README e D20 em design.md.

Base de entrada: código integrado das TASK-055/057, revisado em `e1909ea52d038baf9336158d6f9a377df5bf1537`, presente na base de planejamento `b1fe1093a389213af93fa2ce6c37a55059b97934`. A dependência da TASK-057 serializa a manutenção do tooling e README já integrados; não exige aprovação independente prévia de R7. A falha R7 é permitida como estado inicial desta correção, nunca como resultado final.

## Decisão e limites

Todas as operações Compose do banco de teste devem selecionar explicitamente o projeto fixo `planner-test` por opção de linha de comando, prevalecendo sobre o ambiente herdado. Subida e remoção usam a mesma identidade. Preservar arquivo Compose e env-file explícitos, banco descartável e separação do desenvolvimento.

Não criar isolamento ExUnit por sessão/worktree: os gates locais continuam serializados. Não alterar o runner E2E, regras da aplicação, workflow remoto ou proteção da main; não implementar cenários autenticados. README recebe apenas esclarecimentos operacionais necessários. Outras falhas fora desse contrato seguem o protocolo de impedimentos.

## Critérios de aceite

1. Com `COMPOSE_PROJECT_NAME` ausente, igual a `planner` ou igual a outro nome, as operações de subir, parar e limpar o banco de teste selecionam exclusivamente `planner-test`. A resolução de configuração confirma esse nome sem subir ou remover recursos de desenvolvimento.
2. Regressão automatizada exercita as receitas reais de subida/remoção e a limpeza delegada, interceptando Docker ou usando simulação equivalente sem efeitos destrutivos. Falha na base vulnerável e passa com a correção; verifica identidade igual em up/down, arquivo/env-file explícitos e ausência de operação no projeto herdado. Não basta buscar uma string no justfile.
3. Testes, ci e precommit continuam usando a subida corrigida; `tooling-test` e o gate completo incluem a regressão. Falhas desse teste propagam saída não zero. Operações normais não passam a limpar dados de desenvolvimento nem a exigir sua remoção.
4. Gates vigentes e suíte E2E completa passam; cobertura mínima de 70% preservada. Registrar alvo, comandos, resultados, artefatos e limitações. Teste com ambiente adverso não pode executar up/down real contra o projeto de desenvolvimento.

## Validação e entrega

Seguir TDD enxuto, referências locais de testes/Mix e ajuda das tarefas aplicáveis. Operação canônica no README; autoavaliação conforme fluxo de review, incluindo gate completo e precommit. Conferência operacional e commit integrado são necessários para `done`. Entregar evidências dos quatro critérios para encerramento do BLOCK-006 pelo coordenador. Aprovação independente de R7 exige revalidação pelo revisor; a implementação não avança sozinha o marco de docs/review.md.

## Planejamento — 16/10/2026

Contrato definido e dependência integrada. Nenhum código corrigido ou teste executado nesta rodada documental. Próxima ação: implementação desta tarefa; TASK-056 e TASK-050 aguardam sua conclusão.

## Entrega e autoavaliação — 16/10/2026

Implementador `/root/task058`, base `3f5b961`; alvo avaliado: alterações locais em `justfile`, `scripts/test_compose_test.py` e `README.md`, acompanhadas deste registro. TASK-057 concluída e integrada em `41df5c8`. Autoavaliação conforme fluxo de review, sem aprovação independente ou alteração de `docs/review.md`.

- Aceite 1: subida e remoção fixam `-p planner-test`; limpeza delega à mesma remoção. Resolução real com `docker compose --env-file /dev/null -f compose.test.yaml -p planner-test config --format json` retornou `name: planner-test` nos três ambientes: `COMPOSE_PROJECT_NAME` ausente, `planner` e `unrelated-project`. Somente `config` real foi executado sob ambiente adverso; não houve up/down real contra desenvolvimento.
- Aceite 2: `python3 scripts/test_compose_test.py` executa receitas Just reais copiadas em diretório temporário, com Docker e ferramentas dos gates interceptados. Confere uma única operação Compose, identidade explícita, arquivo, env-file, ação e descarte na remoção; cobre up/down/clean nos três ambientes. Fase vermelha comprovada antes da correção: 12 subcasos falharam pela ausência de identidade explícita e três pela ausência da regressão no gate. Após a correção, três testes com 15 subcasos passaram.
- Aceite 3: regressão verifica também `test`, `ci` e `precommit` usando a subida isolada. Falha simulada do novo teste retorna saída não zero em `tooling-test`, `ci` e `check`, antes de Mix/E2E. `just tooling-test` passou com três testes novos e quatro testes existentes do runner; `just check` inclui ambos. Operação e configuração descritas no README; receitas de desenvolvimento preservadas.
- Aceite 4: após consulta a `mix help ci` e `mix help precommit`, `just check` passou com 245 testes ExUnit, cobertura acima do gate de 70% inalterado, Credo, formato/compilação, assets, testes JavaScript, auditoria npm e toda a suíte E2E atual (dois cenários públicos). `just precommit` passou com 245 testes. `git diff --check` passou. O gate emitiu avisos de redefinição de módulos de migrations, mas concluiu com saída zero; nenhuma migration foi alterada.

Artefatos E2E: `tmp/e2e/run-sdGEO2t9/`, com logs, relatório HTML, resultados, `exit-code.txt` igual a zero e confirmação de remoção dos containers/rede próprios em `cleanup.log`. Cenários: login conectado pela home e proteção do planejamento para visitantes. Limites: testes simulados verificam seleção/operação das receitas, não o daemon; resolução real do Compose complementa essa evidência. Cobertura ExUnit não mede os scripts Python; estes possuem regressão comportamental própria. Os dois cenários públicos não comprovam fluxos autenticados da TASK-056, nem execução do CI remoto.

Conclusão da autoavaliação: critérios atendidos, sem achado bloqueante no diff. Entrega pronta para conferência operacional e commit pelo coordenador no diretório compartilhado; `done` e encerramento do BLOCK-006 dependem dessa integração. R7 permanece sujeito à revalidação independente.

## Conferência operacional — 16/10/2026

Coordenador `/root`: registro, escopo dos arquivos, autoavaliação e gates relatados conferidos, sem impedimento pendente. Entrega integrada na base local em `633b400`. TASK-058 concluída e condição operacional do BLOCK-006 atendida; TASK-056 e TASK-050 liberadas para execução serializada. Não houve revisão independente nem execução do CI remoto nesta coordenação; R7 permanece no parecer até revalidação pelo revisor.
