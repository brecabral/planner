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

## Checkpoint de pausa solicitada — 13/10/2026

Implementador `/root/implement_051`, base de execução `3f7f67a` após integração da TASK-051 e encerramento operacional do BLOCK-005. O responsável pediu organizar a parada antes de concluir a tarefa; estado permanece `in_progress`, sem novo impedimento técnico diagnosticado e sem aprovação de conclusão.

### Trabalho preservado

- Scaffold Phoenix criado em `lib/planner/release.ex`, `rel/overlays/bin/{server,migrate,server.bat,migrate.bat}`, `Dockerfile` e `.dockerignore`. Ajuda de `phx.gen.release`, `release` e `assets.deploy` consultada. Primeira geração encontrou DNS indisponível no sandbox após criar os scripts; repetição autorizada fora do sandbox concluiu os arquivos Docker.
- Dockerfile gerado usa Elixir 1.20.3/OTP 29.0.5 e Debian trixie-20260824-slim; builder recebeu `nodejs npm` para o `npm ci` já presente em `assets.deploy`. Runtime permanece estágio separado, usuário `nobody`, sem copiar fontes/dependências de build.
- `.dockerignore` exclui `.env`, `.env.*`, metadados locais, chaves, documentação e artefatos de desenvolvimento, além das exclusões geradas. Revisão final do artefato ainda pendente.
- README ainda não alterado: build/start/migration não foram comprovados, portanto não há procedimento novo documentado como testado.

### Evidências obtidas e limites

- `mix precommit`: **241 testes, 0 falhas**. `mix ci`: **241 testes, 0 falhas**, Credo estrito sem achados, assets compilados e auditoria npm sem vulnerabilidades. Sessão de execução `3521` encerrada com código 0.
- Cobertura total **93,37%**, acima de 70%; base anterior **94,09%**. Redução corresponde à adição do módulo gerado `Planner.Release`, ainda com **0%** na suíte; seu caminho de migration seria exercitado pelo smoke do artefato, que não foi executado. Não houve exclusão de cobertura nem redução do limiar.
- Build Docker local com tag pretendida `planner:task-011` foi iniciado após escalonamento por bloqueio do socket no sandbox. Baixou imagens, instalou pacotes e compilou dependências; parada solicitada durante `mix assets.setup`, no download do Tailwind. Sessão `1995` interrompida com Ctrl-C, código **130**. Build final e existência de imagem final não comprovados; cache de build preservado. Houve warnings de dependências existentes e aviso de advisories durante resolução, sem investigação concluída nesta pausa.
- Pedido para criar rede `planner-release-smoke` e container PostgreSQL `planner-release-db` foi abortado pelo usuário antes de retorno. Não existe evidência de execução desses comandos; conferir recursos Docker na retomada antes de criar novamente. Nenhum container de aplicação foi iniciado pelo implementador e nenhuma migration de release foi executada.
- Preparados somente em `/tmp`: `planner-release-smoke.exs` (rascunho não executado de verificações de assets/migrations/HTTP/isolamento/persistência) e `planner-release-task011.env` (configuração temporária restrita, modo 0600, sem uso confirmado). Não copiar o arquivo de ambiente ao repositório nem registrar seu conteúdo. Esses arquivos são temporários e podem não sobreviver à sessão.

### Retomada necessária

Conferir árvore, recursos Docker com os nomes acima e disponibilidade dos temporários; retomar build usando cache. Após imagem final pronta, executar migration em banco isolado, verificar runtime sem Mix, assets, rotas de produção, ausência de segredos e preservação de dados após nova migration/reinício. Revisar o rascunho de smoke antes de usá-lo. Só então documentar no README os procedimentos realmente testados, concluir autoavaliação por aceite e encaminhar para integração. Gates já passaram para o código parcial; repetir validação afetada por novas mudanças. TASK-050 não iniciada. Nenhum staging, commit, publicação ou reset realizado pelo implementador.

### Retomada efetiva — 13/10/2026

TASK-051 integrada em `118ba28` e concluída em `2ed68a2`. Implementador `/root/implement_051` respondeu com achados de leitura de mix.exs/configs na base limpa `2ed68a2`, sem build em andamento na consulta de processos. BLOCK-005 resolvido pela coordenação conforme evidências no relatório; implementação liberada. Aceites de release permanecem pendentes.
