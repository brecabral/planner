---
id: "TASK-055"
status: "done"
execution_level: "advanced"
execution_rationale: "Integra ciclo de vida de containers, isolamento, códigos de saída e diagnóstico de falhas."
specs: []
depends_on: ["TASK-011", "TASK-053"]
provides: ["e2e-runner"]
consumes: ["release-scaffold", "visible-login-registration-action"]
write_scope: ["mix.exs", "justfile", "scripts/", "compose.test.yaml", "compose.e2e.yaml", ".dockerignore", "assets/package.json", "assets/package-lock.json", "assets/.gitignore", "assets/Dockerfile.e2e", "assets/Dockerfile.e2e.dockerignore", "assets/playwright.config.ts", "assets/e2e/", "README.md", "docs/tasks/055-comando-e2e.md"]
blockers: []
---

# 055 — Consolidar ambiente E2E e operação local Just

## Objetivo e contexto

Consolidar o esboço local Playwright em uma entrada `just e2e` reproduzível. Ler D20, README, mix.exs, arquivos locais E2E e referências Mix/testes. Manutenção de infraestrutura, sem nova regra de produto; `specs: []`. O esboço em containers incluído no commit deste planejamento é entrada a preservar e reconciliar na implementação, não contrato do runner Just já entregue. Sem gerador Phoenix pertinente.

O contrato inclui retirar `start_database` e aliases Docker de Mix, oferecer operações locais de desenvolvimento/teste e comandos comuns de inspeção para todos os perfis. `just run` depende de `db-up` e inicia Phoenix. Banco de teste local deve ser separado do banco de desenvolvimento.

## Aceite

1. Em checkout com pré-requisitos documentados, a entrada Just constrói imagens atualizadas, prepara banco/migrations, aguarda app com timeout e executa os dois cenários públicos existentes; sucesso retorna zero. Não exige navegador instalado no host.
2. Com falha de build, readiness ou asserção, retorna erro não zero; demonstrações controladas não permanecem quebradas na entrega. `mix ci` e `mix precommit` permanecem separados, sem invocar E2E implicitamente.
3. Banco, rede e containers são exclusivos por execução, sem usar `.env`, banco ou volumes de desenvolvimento. Repetição começa limpa; duas execuções simultâneas não colidem nem removem recursos alheios.
4. Sucesso, falha e interrupção permitem limpeza dos recursos próprios. Relatório, traces/screenshots disponíveis e logs são copiados antes da remoção; falha de coleta não mascara falha original. Artefatos ficam fora do Git em caminho documentado e utilizável pelo CI.
5. Versões de Playwright/imagem são compatíveis com lockfile; manter isolamento do esboço. Documentar pré-requisitos, ajuda, execução, evidências e recuperação somente no README, distinguindo evidências antigas das novas.

6. Just oferece ajuda, setup, run, banco local/teste (subir, parar, limpar), testes, qualidade, precommit, E2E e inspeção de estado/diff/tarefas. Limpeza destrutiva é explícita e não é dependência dos comandos normais. Mix não inicia infraestrutura.

## Limites

Produz runner, configuração e smoke público. Não integra workflow, não amplia cenários autenticados nem altera regras do produto. Testar propagação de falha e limpeza além do caminho feliz.

## Validação e entrega

Consultar ajuda Mix e operação no README. Aplicar TDD enxuto aos comportamentos novos, executar gates existentes com cobertura mínima de 70% preservada e E2E completo. Registrar comandos, alvo, resultados, evidências por critério e limitações; autoavaliação pelo fluxo de review, sem aprovação independente implícita. Conferência operacional e commit integrado são necessários antes de `done`. Estado inicial: planejada, sem implementação ou validação executada neste planejamento.

## Entrega e autoavaliação — 16/10/2026

Implementador `/root`, base `a55f556`, alterações locais desta tarefa. Just agora centraliza banco de desenvolvimento, banco de teste descartável separado, setup, servidor, testes, qualidade, inspeção e commit do staging explícito. Mix não inicia Docker; auditoria npm passou para Just. Nenhum comportamento de produto foi alterado.

- Aceites 1/5/6: `just --list`, dry-run de run/test, parse/formato Just e shell aprovados. `just precommit`: 245 testes, saída 0. `just check`: qualidade aprovada com cobertura acima do limiar de 70%, Credo, assets, testes JavaScript e auditoria npm; dois cenários Chromium aprovados, saída 0.
- Aceites 2/3/4: quatro testes do runner aprovados, incluindo seis fases de falha (build, readiness, testes, cópia, logs e cleanup), SIGTERM e duas execuções concorrentes simuladas. Falhas mantêm saída não zero; evidências precedem remoção. Simulação não equivale a concorrência Docker real nem prova SIGKILL recuperável automaticamente.
- E2E real: `tmp/e2e/run-jgHJ31L9/`, relatório HTML, logs, código 0 e cleanup de containers/rede comprovado. Banco em tmpfs, sem acesso ao banco local. Build atualizou imagens; cache preservado. Execução Docker exigiu acesso fora do sandbox.
- Grafo: 57 cabeçalhos conferidos, sem ciclos, consumidores sem produtor ancestral ou dependências incompletas em tarefas concluídas. `git diff --check` aprovado.

Autoavaliação pelo fluxo de review, sem aprovação independente nem alteração do marco de `docs/review.md`. Cenários autenticados continuam na TASK-056. Aguardando conferência operacional e commit integrado.

## Conferência operacional

Coordenador `/root`: registro, gates relatados e integração local conferidos no commit `8525d1f`. Sem impedimentos. TASK-055 concluída; TASK-057 liberada. Esta conferência não é revisão independente.

## Revisão independente — 16/10/2026

Revisor `/root`, alvo `e1909ea52d038baf9336158d6f9a377df5bf1537`, base `a55f55679f15f398a7c9541e66e5d5e11a604501`. Relatório em [docs/review.md](../review.md#segurança-do-just-ci-e-execução-por-agentes--16102026): `changes_requested` no escopo conjunto por R7, colisão de projeto Compose de teste quando `COMPOSE_PROJECT_NAME` é herdado (TASK-055). `just check` aprovado: 245 testes ExUnit, gate de cobertura de 70%, qualidade/JS/audit e dois E2E. CI remoto não verificado; `gh` ausente. Estado de integração preservado, sem aprovação independente implícita ou correção de código.

## Encaminhamento de R7 — 16/10/2026

Correção delimitada na [TASK-058](058-isolar-projeto-compose-teste.md), com diagnóstico e retomada no [BLOCK-006](../blocks/006-isolamento-compose-teste.md). Estado de entrega integrada preservado; R7 e o parecer independente permanecem abertos. As liberações de fila registradas acima são históricas: consultar os cabeçalhos atuais das consumidoras.
