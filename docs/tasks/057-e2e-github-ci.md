---
id: "TASK-057"
status: "in_review"
execution_level: "standard"
execution_rationale: "Integra infraestrutura própria ao check protegido existente, preservando diagnóstico e gates."
specs: []
depends_on: ["TASK-055", "TASK-003"]
provides: ["github-e2e-gate"]
consumes: ["e2e-runner", "github-quality-gate"]
write_scope: [".github/workflows/ci.yml", "README.md", "docs/tasks/057-e2e-github-ci.md"]
blockers: []
---

# 057 — Tornar E2E obrigatório no GitHub CI

## Objetivo e contexto

Ler D20, workflow atual, contrato do runner, README e aceite humano já registrado da TASK-003. Manutenção técnica sem nova regra de produto; `specs: []`. Adicionar infraestrutura independente do Just e do runner local para E2E como etapa obrigatória do job `quality` já exigido pela proteção da main. TASK-003 está concluída; não reexecutar nem alterar configuração remota reservada ao humano.

## Aceite

1. Pull requests e pushes para main mantêm gates atuais e executam a suíte E2E completa com PostgreSQL próprio e etapas explícitas do workflow, sem chamar Just ou depender do alias agregado `mix ci`, sem filtros por caminhos que dispensem o gate e sem `continue-on-error`.
2. Job `quality` só passa quando qualidade e E2E passam. Falha de teste/setup reprova; validar com falha controlada e sucesso, preservando evidências. Não incorporar E2E ao alias `mix ci` nem substituir cobertura de 70%.
3. Upload de relatório, traces/screenshots e logs disponíveis ocorre mesmo em falha; declarar retenção e caminho próprios do workflow. Limpeza não apaga evidências antes do upload. Timeout limita a execução; não deixar containers persistentes em runners reutilizados.
4. Documentar pré-requisitos, reprodução local, localização/retencão dos artefatos e relação com o check protegido no README. Registrar execução real do GitHub no commit/PR quando disponível; configuração escrita ou execução local não equivalem a CI remoto aprovado. Sem autorização para publicar, registrar essa limitação para a conferência operacional, sem inventar evidência remota.

A ampliação autenticada da TASK-056 não bloqueia a infraestrutura: o workflow executa todos os cenários presentes, sem alegar cobertura autenticada antes da entrega correspondente.

## Limites

Não publicar branch nem mudar proteção da main nesta implementação sem autorização correspondente. Não criar job paralelo cujo resultado deixe o check `quality` verde com E2E reprovado. Sem instalação de ferramentas novas além das necessárias ao contrato já definido.

## Validação e entrega

Consultar ajuda Mix e operação no README. Aplicar TDD enxuto aos comportamentos novos, executar gates existentes com cobertura mínima de 70% preservada e E2E completo. Registrar comandos, alvo, resultados, evidências por critério e limitações; autoavaliação pelo fluxo de review, sem aprovação independente implícita. Conferência operacional e commit integrado são necessários antes de `done`. Estado inicial: planejada, sem implementação ou validação executada neste planejamento.

## Entrega e autoavaliação — 16/10/2026

Implementador `/root`, base `3414439`, workflow/README locais. O job protegido `quality` mantém seus eventos e agora declara serviço PostgreSQL próprio, bases separadas, etapas de qualidade explícitas e suíte Playwright completa. Não chama Just, Compose local ou `mix ci`. Bash explícito preserva falhas em pipelines com tee. Coleta/remoção e upload são executados com `always()`, retenção de 14 dias e timeout de job/teste.

- Aceites 1/2: YAML e sintaxe shell conferidos; ausência de `continue-on-error`, filtros de caminhos e chamadas ao runner local. Gates equivalentes já passaram nesta rodada na TASK-055 (245 testes, cobertura acima de 70%, Credo, assets, JavaScript e audit); não foram repetidos sobre o mesmo código Elixir. Regressões do runner passaram novamente (quatro testes).
- Aceites 2/3: reprodução local extraiu do YAML os comandos de build, migrations, readiness e coleta/remoção. PostgreSQL próprio em tmpfs e porta exclusiva; suite completa passou com dois testes. Asserção propositalmente falsa em container descartável retornou 1. Código quebrado não foi adicionado ao repositório. Propagação de erro em pipeline Bash também conferida.
- Evidências locais em `tmp/ci-e2e/`, incluindo `local-validation.txt`, relatório HTML, logs de build/migration/app e remoção. Todos os containers temporários dessa reprodução foram removidos.
- Limites: navegador da reprodução usou a imagem Playwright compatível já construída, em vez de instalar Chromium no host. Não foram executados GitHub Actions, instalação nativa no Ubuntu ou upload remoto; publicação não autorizada. Configuração e evidência local não equivalem a check remoto aprovado.
- Aceite 4: operação, artefatos, retenção, responsabilidades e limites documentados no README. TASK-056 continua responsável por cenários autenticados e fixtures compatíveis com ambos os ambientes.

Autoavaliação pelo fluxo de review, sem aprovação independente nem avanço do marco histórico. `git diff --check` aprovado. Pronta para conferência operacional e integração local, com execução remota explicitamente não verificada.
