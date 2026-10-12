---
id: "TASK-011"
status: "planned"
execution_level: "standard"
execution_rationale: "Empacota aplicação pronta com assets e migrations, sem escolher infraestrutura remota."
specs: ["SPEC-005", "SPEC-007"]
depends_on: ["TASK-048"]
provides: ["release-scaffold"]
consumes: ["user-theme-switching"]
write_scope: ["lib/planner/release.ex", "rel/", "Dockerfile", ".dockerignore", "README.md", "docs/tasks/011-entrega-remota.md"]
blockers: []
---

# 011 — Preparar release local do MVP de produção

## Objetivo e entradas

Empacotar o incremento autenticado com temas, sem publicar. Ler SPEC-005/007 e somente contrato local confirmado RN01/CA-008-01 da SPEC-008 (a parte remota permanece draft), mix.exs/assets/README e referências Mix/Phoenix. A spec remota draft não é contrato executável desta tarefa local.

## Scaffold e aceite

Ajuda `mix help phx.gen.release` consultada em 11/10/2026. Gerar uma vez com `mix phx.gen.release --docker`; revisar scripts de server/migration e Dockerfile. Adaptar instalação/build npm ao lockfile e aos aliases existentes; não supor que o Dockerfile gerado já instala frontend.

1. Artefato local contém assets e migrations e inicializa com configuração externa de teste, sem Mix no runtime nem Compose automático. Verificar build e smoke test local sem serviço remoto.
2. Migration usa banco de teste isolado e preserva dados; não executar reset nem preparar usuário compartilhado acessível. Excluir segredos/.env e artefatos de dev da imagem.
3. README descreve build/start/migration local efetivamente testados. Nenhuma hospedagem, domínio, envio real ou publicação é escolhido nesta tarefa.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.
