---
id: "TASK-050"
status: "done"
execution_level: "advanced"
execution_rationale: "Consolida contratos transversais de autenticação, isolamento, tarefas e persistência no artefato local final."
specs: ["SPEC-002", "SPEC-004", "SPEC-005", "SPEC-007", "SPEC-008"]
depends_on: ["TASK-058"]
provides: ["verified-local-release"]
consumes: ["release-scaffold"]
write_scope: ["test/", "docs/specs/", "README.md", "docs/tasks/050-aceite-mvp-producao.md"]
blockers: []
---

# 050 — Validar o código Phoenix e o release local

## Objetivo e entradas

Verificar CA17–CA19/CA16 do PRD e SPEC-008 RN02–RN05/CA-008-02 e CA-008-04 no release local. Carregar contratos/registro das entregas 041–048, 015, 051 e 011, Mailer/configurações existentes e referências testes/Mix. Não presumir prontidão a partir da documentação ou do antigo aceite local.

## Aceite e evidências

1. Conferir a regressão de falha de envio e recuperação do cadastro (CA-005-13/TASK-051). Reproduzir fluxo de duas contas: cadastro e captura do link com adapter local/de teste, entrada/home/logout, isolamento de todos os comandos e preservação do legado. Login e tokens seguem as regras de validade e revogação da SPEC-005.
2. Comprovar retry → backlog, exclusão de pendências com cota/histórico corretos e seleção persistida de ambos os temas. Cobrir regressões e evidências de falha/concorrência das tarefas produtoras.
3. Validar o artefato local integrado pela TASK-011 e executar gates; relacionar testes aos IDs de aceite e registrar configuração isolada e limitações de navegador. Distinguir testes de e-mail da aplicação do smoke test do release, sem expor mailbox em produção. Não exigir domínio, provedor real, backup/restauração remota ou avaliação humana de UI. Documentar no README os pontos existentes para configuração posterior de e-mail pelo usuário, sem implementar adapter ou camada adicional.
4. Falha exige correção com evidência antes de encerrar. Revisão independente apenas se solicitada. Não implementar novas features nesta consolidação; encaminhar falta de contrato ao planejador.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.

## Reconciliação de R7 — 16/10/2026

Aguardar a TASK-058 para usar os gates locais com isolamento corrigido, conforme [BLOCK-006](../blocks/006-isolamento-compose-teste.md). Dependências anteriores continuam alcançáveis pela cadeia; nenhuma implementação ou validação adicional nesta rodada.

## Retomada e impedimento — 17/10/2026

Base inspecionada: `fb9432377522049d66ff84dc810264a4e0871b1c`, árvore inicialmente limpa. TASK-058 integrada e BLOCK-006 resolvido; TASK-056 integrada com evidências de navegador. Inspeção inicial pelo implementador `/root/task050` identificou ausência de teste automatizado versionado e integrado para reinício do release sobre o mesmo banco, exigido por CA-008-03 e pelos critérios 1/3 desta tarefa.

O smoke histórico da TASK-011 usou verificador temporário; a suíte atual de navegador cobre recargas, mas seu runner não reinicia o release. O ExUnit usa aplicação de teste com Sandbox. Criar teste de reinício da aplicação de teste não comprovaria reinício do artefato de produção. Integração de controle do ciclo de vida do release precisa de planejamento dos recursos fora de `write_scope`, conforme [BLOCK-007](../blocks/007-aceite-automatizado-reinicio-release.md).

Execução interrompida na análise inicial, sem mudança de código ou novos testes/gates executados. Evidências históricas não foram reapresentadas como validação desta rodada. Critérios de aceite e autoavaliação técnica permanecem pendentes; não há aprovação nem entrega `in_review`. Preservados apenas estes registros documentais para o coordenador integrar e encaminhar ao planejador.

## Reconciliação do BLOCK-007 — 17/10/2026

Decisão explícita do responsável remove o aceite de persistência após reinício do release. CA-008-03 foi retirado e os critérios 1/3 foram ajustados; não há integração de controle de reinício a produzir. A estrutura é responsabilidade das migrations do Ecto, conforme SPEC-008 RN03. O diagnóstico acima permanece histórico. BLOCK-007 resolvido pela retirada do requisito; tarefa permanece `in_progress`, na análise inicial, com os demais aceites e gates pendentes. Nenhuma execução ou aprovação técnica nesta reconciliação.

## Entrega e autoavaliação — 17/10/2026

Implementador `/root/task050`, base/alvo de código `50a50b7f6fddedc68f14227ef14d63cad4ab0470`, árvore inicialmente limpa. BLOCK-007 resolvido por decisão explícita; dependências integradas. A consolidação reutilizou testes automatizados versionados existentes, sem alterar comportamento ou criar testes redundantes. Alterações próprias: pontos concretos de configuração posterior de e-mail no README e este relatório. Não houve script avulso de aceite, reinício de release ou envio externo.

| Critério / aceite | Evidência executada nesta rodada |
| --- | --- |
| 1 — CA17, CA-005-07/09/12/13, CA-008-02 | `local_magic_link_test.exs` captura destinatário/URL com adapters Test e Local, cadastra duas contas, entra/sai e recupera a primeira conta com seus dados. O caso de falha de cadastro conserva uma única conta/concessões, não autentica, apresenta erro e recupera login pelo mesmo e-mail após restaurar o adapter. `authentication_flow_test.exs` verifica home, confirmação, CSRF e logout. Todos aprovados nos gates completos. |
| 1 — CA-005-08/10/11 | `accounts_auth_test.exs`, `accounts_auth_concurrency_test.exs`, `accounts_auth_migration_test.exs` e `private_planning_test.exs` verificam expiração/uso único/revogação, consumo concorrente, migration aditiva do legado, isolamento de consultas e todos os comandos, cota independente e rejeição de sessão revogada na reconexão. Aprovados. |
| 2 — CA19, CA-002-12/13/14, CA-004-14/15/16 | `task_movement_test.exs`, `task_deletion_test.exs`, `tasks_test.exs` e `live/task_live_test.exs` cobrem retry → backlog no início/meio/fim/vazio e pelo menu, cota esgotada, virada, rejeições, rollback injetado, exclusão por lista, labels preservadas, restituição única e histórico não excluível. Corridas reais em conexões distintas cobrem retry/menu e exclusão/devolução/conclusão. E2E verifica menu, mouse/touch, exclusão/cancelamento, cota, histórico e recarga. Aprovados. |
| 2 — CA18, CA-007-01/02/03/04/05/06/07 | `themes_test.exs`, `themes_storage_test.exs` e `theme_test.exs` verificam concessões gratuitas, concorrência/falhas de gravação, propriedade, seleção persistida, patches/reconexão/novo dispositivo e logout. E2E desktop/320 px alterna ambos os temas com teclado, verifica cores computadas, recarga, patches, logout e segunda conta. Aprovados. |
| 3 — CA16, CA-008-02/04 | Runner E2E construiu e iniciou o release sobre PostgreSQL descartável com configuração externa, aplicou as migrations e executou nove cenários no Chromium, incluindo smoke público e planejamento autenticado. `local_magic_link_test.exs` comprova ausência das rotas dev e desativação da mailbox na configuração prod; isso é evidência da aplicação/configuração, não nova requisição HTTP a essas rotas no container. README identifica `runtime.exs`, `prod.exs` e `user_notifier.ex` para configuração posterior de adapter/credenciais/remetente. |
| 4 — falhas, escopo e limites | Gates sem falhas; nenhuma feature, adapter ou camada adicionada. Sem revisão independente, publicação ou infraestrutura remota. CA-008-03 retirado não foi exigido nem declarado executado. |

### Gates e artefato

- Ajudas `mix help test`, `mix help precommit` e `mix help ci` consultadas. `rtk just precommit`: **245 testes aprovados**, seed 486390.
- `rtk just ci`: **245 testes aprovados**, seed 31846; compilação/formato/Credo estrito aprovados, **7 testes de tooling** aprovados, build de assets, testes JavaScript de arraste/tema e auditoria npm aprovados. Gate de cobertura **mínima de 70% aprovado sem alteração do limiar**. Métricas visíveis: Tasks 97,94%, TaskLive.Index 98,71%, UserAuth 98,18%, Themes e UserToken 100%. O resumo total foi condensado pelo RTK e não é reproduzido como número não observado. HTML de cobertura em `cover/`. `Planner.Release` aparece com 0% na instrumentação ExUnit; execução das migrations no artefato é evidenciada pelo runner E2E, não contabilizada nessa métrica.
- `rtk just e2e`: **9/9 aprovados em 18,8 s**, sem retries; exit code **0**, coleta e limpeza aprovadas. Artefatos em `tmp/e2e/run-sHktvPdg/`, incluindo `build.log`, `startup.log`, `containers.log`, `tests.log`, `cleanup.log`, `exit-code.txt` e `playwright-report/index.html`.
- Release **0.1.0**, imagem local `planner-e2e-run-shktvpdg-app:latest`, manifest `sha256:5c374a0aa134cfaab342e7e88917caa3cde057c93f2c76206c4b9a3e4735d890`. Banco `planner_e2e` em tmpfs, rede interna exclusiva, credenciais sintéticas e configuração do Compose sem `.env` de desenvolvimento; nenhuma porta/volume de desenvolvimento compartilhado. O build reutilizou cache válido. Logs confirmam migrations antes do servidor e dos testes.
- Inspeção do Dockerfile, `.dockerignore`, `Planner.Release` e configurações confirma runtime separado como `nobody`, cópia apenas do release compilado, exclusões de segredos locais e migration sem seed/reset. O smoke E2E atual comprova aplicação/JS/CSS funcionais no artefato; inspeção documental não é alegada como nova varredura do filesystem do container.

### Parecer e limites

Autoavaliação pelo fluxo de review: **approved nos critérios vigentes**, sem achado bloqueante nesta consolidação. Não é revisão independente e não altera o parecer histórico em `docs/review.md`. Diff documental conferido e `git diff --check` aprovado. Nenhuma alteração de produção após os gates.

ExUnit/LiveViewTest e Swoosh comprovam os fluxos de cadastro e e-mail sem entrega externa; E2E autentica contas sintéticas pela confirmação normal, mas seus tokens são preparados pela fixture privada, sem provedor. Retry → backlog, concorrência, rollback e expiração têm evidência na suíte da aplicação, não gesto específico de retry no navegador. Chromium verifica mouse e eventos touch em contexto móvel, sem hardware físico, outros navegadores ou avaliação estética humana. Persistência após reinício e durabilidade do banco não integram o aceite vigente. CI remoto não executado; testes locais não comprovam publicação.

Entrega `in_review`, aguardando conferência operacional e commit do coordenador. Nenhum staging/commit pelo implementador; arquivos próprios limitados a `README.md` e esta tarefa.

## Conferência operacional — 17/10/2026

Coordenador `/root`: conferidos escopo documental, matriz de evidências, autoavaliação e gates relatados (245 testes ExUnit e 9/9 E2E aprovados), sem impedimento pendente. Decisão de resolução do BLOCK-007 integrada em `50a50b7`; entrega desta tarefa integrada em `c60d719` na base local. Commit bem-sucedido e integração confirmada; TASK-050 concluída operacionalmente nos critérios vigentes. Nenhum teste reproduzido pelo coordenador, revisão independente, CI remoto ou publicação. As tarefas de evolução futura mantêm seus bloqueios de escopo e não são liberadas por este aceite.

## Revisão independente — 17/10/2026

Revisor `/root`, alvo `5d9db708ce0bed5d100625971b0aedea1e7540fd`, base incremental `e1909ea52d038baf9336158d6f9a377df5bf1537`. **Approved no escopo local**, conforme [relatório vigente](../review.md). `rtk just check` reproduzido: 245 testes ExUnit, cobertura mínima de 70%, qualidade/JS/auditoria e sete testes de tooling aprovados; E2E completo 9/9 em `tmp/e2e/run-hy5iUAA2/`, saída zero e limpeza confirmada. Sem alteração de código, publicação ou comprovação de operação/CI remoto. O relatório delimita critérios, evidências e limitações; esta revisão não altera a integração já registrada.
