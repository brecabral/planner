---
id: "TASK-055"
status: "planned"
execution_level: "advanced"
execution_rationale: "Integra ciclo de vida de containers, isolamento, códigos de saída e diagnóstico de falhas."
specs: []
depends_on: ["TASK-011", "TASK-053"]
provides: ["e2e-runner"]
consumes: ["release-scaffold", "visible-login-registration-action"]
write_scope: ["mix.exs", "lib/mix/tasks/", "test/mix/", "compose.e2e.yaml", ".dockerignore", "assets/package.json", "assets/package-lock.json", "assets/.gitignore", "assets/Dockerfile.e2e", "assets/Dockerfile.e2e.dockerignore", "assets/playwright.config.ts", "assets/e2e/", "README.md", "docs/tasks/055-comando-e2e.md"]
blockers: []
---

# 055 — Consolidar ambiente E2E e comando Mix

## Objetivo e contexto

Consolidar o esboço local Playwright em uma entrada `mix e2e` reproduzível. Ler D20, README, mix.exs, arquivos locais E2E e referências Mix/testes. Manutenção de infraestrutura, sem nova regra de produto; `specs: []`. O esboço em containers incluído no commit deste planejamento é entrada a preservar e reconciliar na implementação, não contrato do runner Mix já entregue. Sem gerador Phoenix pertinente.

## Aceite

1. Em checkout com pré-requisitos documentados, a entrada Mix constrói imagens atualizadas, prepara banco/migrations, aguarda app com timeout e executa os dois cenários públicos existentes; sucesso retorna zero. Não exige navegador instalado no host.
2. Com falha de build, readiness ou asserção, retorna erro não zero; demonstrações controladas não permanecem quebradas na entrega. `mix ci` e `mix precommit` permanecem separados, sem invocar E2E implicitamente.
3. Banco, rede e containers são exclusivos por execução, sem usar `.env`, banco ou volumes de desenvolvimento. Repetição começa limpa; duas execuções simultâneas não colidem nem removem recursos alheios.
4. Sucesso, falha e interrupção permitem limpeza dos recursos próprios. Relatório, traces/screenshots disponíveis e logs são copiados antes da remoção; falha de coleta não mascara falha original. Artefatos ficam fora do Git em caminho documentado e utilizável pelo CI.
5. Versões de Playwright/imagem são compatíveis com lockfile; manter isolamento do esboço. Documentar pré-requisitos, ajuda, execução, evidências e recuperação somente no README, distinguindo evidências antigas das novas.

## Limites

Produz runner, configuração e smoke público. Não integra workflow, não amplia cenários autenticados nem altera regras do produto. Testar propagação de falha e limpeza além do caminho feliz.

## Validação e entrega

Consultar ajuda Mix e operação no README. Aplicar TDD enxuto aos comportamentos novos, executar gates existentes com cobertura mínima de 70% preservada e E2E completo. Registrar comandos, alvo, resultados, evidências por critério e limitações; autoavaliação pelo fluxo de review, sem aprovação independente implícita. Conferência operacional e commit integrado são necessários antes de `done`. Estado inicial: planejada, sem implementação ou validação executada neste planejamento.
