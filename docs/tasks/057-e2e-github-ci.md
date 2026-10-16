---
id: "TASK-057"
status: "planned"
execution_level: "standard"
execution_rationale: "Integra comando pronto ao check protegido existente, preservando diagnóstico e gates."
specs: []
depends_on: ["TASK-056", "TASK-003"]
provides: ["github-e2e-gate"]
consumes: ["e2e-runner", "e2e-authenticated-suite", "github-quality-gate"]
write_scope: [".github/workflows/ci.yml", "README.md", "docs/tasks/057-e2e-github-ci.md"]
blockers: []
---

# 057 — Tornar E2E obrigatório no GitHub CI

## Objetivo e contexto

Ler D20, workflow atual, contrato do runner, README e aceite humano já registrado da TASK-003. Manutenção técnica sem nova regra de produto; `specs: []`. Adicionar execução do comando Mix E2E como etapa obrigatória do job `quality` já exigido pela proteção da main. TASK-003 está concluída; não reexecutar nem alterar configuração remota reservada ao humano.

## Aceite

1. Pull requests e pushes para main mantêm gates atuais e executam a suíte E2E completa pelo mesmo comando local, sem filtros por caminhos que dispensem o gate e sem `continue-on-error`.
2. Job `quality` só passa quando qualidade e E2E passam. Falha de teste/setup reprova; validar com falha controlada e sucesso, preservando evidências. Não incorporar E2E ao alias `mix ci` nem substituir cobertura de 70%.
3. Upload de relatório, traces/screenshots e logs disponíveis ocorre mesmo em falha; declarar retenção e caminho compatíveis com runner. Limpeza não apaga evidências antes do upload. Timeout limita a execução; não deixar containers persistentes em runners reutilizados.
4. Documentar pré-requisitos, reprodução local, localização/retencão dos artefatos e relação com o check protegido no README. Registrar execução real do GitHub no commit/PR quando disponível; configuração escrita ou execução local não equivalem a CI remoto aprovado. Sem autorização para publicar, registrar essa limitação para a conferência operacional, sem inventar evidência remota.

## Limites

Não publicar branch nem mudar proteção da main nesta implementação sem autorização correspondente. Não criar job paralelo cujo resultado deixe o check `quality` verde com E2E reprovado. Sem instalação de ferramentas novas além das necessárias ao contrato já definido.

## Validação e entrega

Consultar ajuda Mix e operação no README. Aplicar TDD enxuto aos comportamentos novos, executar gates existentes com cobertura mínima de 70% preservada e E2E completo. Registrar comandos, alvo, resultados, evidências por critério e limitações; autoavaliação pelo fluxo de review, sem aprovação independente implícita. Conferência operacional e commit integrado são necessários antes de `done`. Estado inicial: planejada, sem implementação ou validação executada neste planejamento.
