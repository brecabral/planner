---
id: "TASK-011"
status: "in_progress"
execution_level: "standard"
execution_rationale: "Empacota aplicação pronta com assets e migrations, sem escolher infraestrutura remota."
specs: ["SPEC-005", "SPEC-007", "SPEC-008"]
depends_on: ["TASK-048", "TASK-051"]
provides: ["release-scaffold"]
consumes: ["user-theme-switching", "registration-delivery-recovery"]
write_scope: ["lib/planner/release.ex", "rel/", "Dockerfile", ".dockerignore", "README.md", "docs/tasks/011-entrega-remota.md"]
blockers: []
---

# 011 — Preparar release local do MVP de produção

## Retomada da coordenação — 13/10/2026

TASK-048 integrada em `1f388fe` e concluída em `79ac675`. Duas tentativas de delegação não retornaram progresso ou evidências e foram interrompidas; nenhuma alteração da TASK-011 foi observada após as interrupções. A tarefa permanece `planned`, pois o início efetivo da implementação não foi confirmado. Diagnóstico e condição de retomada em [BLOCK-005](../blocks/005-delegacao-release-sem-retorno.md). Nenhum build ou smoke test foi comprovado; não há conclusão operacional.

## Pré-requisito da revisão — 13/10/2026

Integrar TASK-051 antes de empacotar: R3 impede considerar o cadastro pronto quando o envio falha. BLOCK-005 continua independente e exige a evidência operacional de retomada já definida; esta reconciliação não o encerra.

## Objetivo e entradas

Empacotar o incremento autenticado com temas, sem publicar. Ler SPEC-005/007 e RN01/RN03/CA-008-01 da SPEC-008, mix.exs/assets/README e referências Mix/Phoenix. O contrato vigente termina na entrega local e não depende de decisões de infraestrutura do usuário.

## Scaffold e aceite

Ajuda `mix help phx.gen.release` consultada em 11/10/2026. Gerar uma vez com `mix phx.gen.release --docker`; revisar scripts de server/migration e Dockerfile. Adaptar instalação/build npm ao lockfile e aos aliases existentes; não supor que o Dockerfile gerado já instala frontend.

1. Artefato local contém assets e migrations e inicializa com configuração externa de teste, sem Mix no runtime nem Compose automático. Verificar build e smoke test local sem serviço remoto.
2. Migration usa banco de teste isolado e preserva dados; não executar reset nem preparar usuário compartilhado acessível. Excluir segredos/.env e artefatos de dev da imagem.
3. README descreve build/start/migration local efetivamente testados. Nenhuma hospedagem, domínio, envio real ou publicação é escolhido nesta tarefa.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.

### Retomada efetiva — 13/10/2026

TASK-051 integrada em `118ba28` e concluída em `2ed68a2`. Implementador `/root/implement_051` respondeu com achados de leitura de mix.exs/configs na base limpa `2ed68a2`, sem build em andamento na consulta de processos. BLOCK-005 resolvido pela coordenação conforme evidências no relatório; implementação liberada. Aceites de release permanecem pendentes.
