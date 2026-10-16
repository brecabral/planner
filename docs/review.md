---
review_base_commit: "a55f55679f15f398a7c9541e66e5d5e11a604501"
reviewed_commit: "e1909ea52d038baf9336158d6f9a377df5bf1537"
last_approved_commit: "2b8ba19ce2657126423256d3fd2596875c7ca661"
reviewed_at: "2026-10-16"
reviewer: "/root — revisão independente de código e alinhamento documental"
status: changes_requested
reviewed_tasks: ["TASK-055", "TASK-057"]
---

# Revisão atual e pendências

## Segurança do Just, CI e execução por agentes — 16/10/2026

Resultado: **changes_requested**, por R7. Revisor independente `/root`, sem implementação nesta rodada. Alvo `e1909ea52d038baf9336158d6f9a377df5bf1537`; base do incremento de tooling `a55f55679f15f398a7c9541e66e5d5e11a604501`. Escopo: TASK-055/057, Just, scripts, Compose, aliases, workflow e respectivos contratos. O último aprovado histórico continua fora da ancestralidade (saída 1), preservado sem avanço; a base foi reconstruída pelo início das entregas de tooling. Não é aprovação integral do produto nem revisão da implementação futura da TASK-056.

O código executável estava idêntico ao alvo. Esta revisão cobre somente o escopo declarado; aprovações antigas não certificam o MVP de produção. Histórico completo preservado no commit `4ed2a47fe8cd1aa783a952b81a5e2754c619956a`. A limpeza documental posterior não altera o alvo avaliado nem avança o marco de aprovação.

### R7 — P2: ambiente herdado pode direcionar testes ao projeto Compose de desenvolvimento

Local: `justfile:30` e `justfile:33`, introduzidos pela TASK-055; `compose.test.yaml:1`. As receitas usam arquivo e env-file explícitos, mas não `-p`. Se o terminal/agente exportar `COMPOSE_PROJECT_NAME=planner`, esse valor prevalece sobre `name: planner-test`. Como desenvolvimento e teste declaram o serviço `postgres`, `just test`/`ci`/`precommit` podem recriar o container de desenvolvimento com configuração de teste; `db-test-down` pode remover o container correspondente sem a confirmação de `db-clean`. O volume persistente de desenvolvimento não está declarado no arquivo de teste: não se afirma apagamento desse volume, mas há interrupção indevida do ambiente e quebra da separação prometida.

Reprodução segura, somente resolução de configuração: `rtk env COMPOSE_PROJECT_NAME=planner docker compose --env-file /dev/null -f compose.test.yaml config --format json` retornou `name: planner`, rede `planner_default` e serviço `postgres`. Nenhuma subida/remoção foi executada com essa variável. Correção esperada: fixar explicitamente a identidade exclusiva do projeto de teste em todas as operações, sem aceitar silenciosamente o nome herdado do desenvolvimento; acrescentar regressão com ambiente adverso e conferir que up/down selecionam o mesmo projeto de teste.

### Encaminhamento de planejamento — 16/10/2026

R7 aceito como falha do contrato de isolamento. Correção definida na [TASK-058](tasks/058-isolar-projeto-compose-teste.md), com condição de retomada no [BLOCK-006](blocks/006-isolamento-compose-teste.md). TASK-056 e TASK-050 aguardam essa entrega. Este encaminhamento é documental: R7 permanece aberto, `changes_requested` e os SHAs da revisão são preservados. Correção validada e integrada permite a retomada operacional; aprovação independente depende de revalidação do revisor.

### CI local e remoto

O gate local é satisfatório para o escopo já entregue, exceto pelo isolamento de R7: `just check` executa qualidade, cobertura, assets, JS, auditoria npm, testes do runner e E2E. `just ci` e `just precommit` isoladamente não substituem esse gate completo. A suíte de navegador atual contém apenas dois cenários públicos; autenticação, arraste e temas continuam pendentes na TASK-056, conforme contrato, sem atribuir essa ausência como regressão da TASK-057.

O workflow remoto preserva `quality`, eventos de PR/push para main, permissões `contents: read`, PostgreSQL próprio, bases distintas, etapas explícitas, Bash com propagação de falhas, E2E obrigatório, timeout e coleta/upload com `always()` e retenção de 14 dias. Não usa segredos de produção, `pull_request_target`, filtros de paths ou `continue-on-error`. Estrutura adequada ao contrato inspecionado, mas **execução remota não verificada**: tentativa de consulta falhou porque `gh` não está instalado. Não houve push, disparo remoto ou alteração de proteção. Instalação nativa de Chromium, disponibilidade das actions e upload no runner não são comprovados pelo sucesso local.

### Adequação para agentes e melhorias não bloqueantes

- Ajuda, inspeção, banco, testes, qualidade e commit explícito atendem à operação sequencial. `set positional-arguments`, `"$@"` e `"$1"` evitam interpolar os argumentos de teste/mensagem no código shell. Não foi identificada injeção shell por esses parâmetros.
- Just organiza comandos, mas não cria uma fronteira de permissões: executar receitas ainda concede os efeitos de Docker, Mix, npm e Git. A confirmação de `db-clean` reduz acidente interativo; não representa autorização humana para tarefa reservada. Restrições do agente continuam necessárias.
- ExUnit usa projeto/porta/base compartilhados (`planner-test`, 55432, `planner_test`). Duas sessões/worktrees não ficam isoladas por mudar somente `PLANNER_TEST_PORT`; podem reconfigurar o mesmo container. Serializar esses gates ou definir contrato completo de isolamento por sessão antes de prometer concorrência. E2E já usa projeto e artefatos por execução.
- `just diff` mostra somente o diff sem staging; alterações staged e arquivos novos exigem inspeção adicional. `just commit` comita todo o staging, inclusive o que outro agente tiver colocado ali: a seleção/conferência continua responsabilidade do operador em workspace compartilhado.
- Actions e imagens usam tags, sem pin por SHA/digest; auditoria automática cobre npm, não todas as dependências Hex/imagens. São limites de endurecimento e cobertura, sem vulnerabilidade específica comprovada nesta rodada.

### Evidências reproduzidas

Ajuda de `mix ci`, `mix precommit` e Just consultada; aliases e contratos inspecionados antes da execução.

- `rtk just check`: saída 0; **245 testes ExUnit**, seed 32667, Credo sem achados em 75 arquivos, gate de cobertura de 70% aprovado, assets, testes JavaScript e auditoria npm aprovados. Quatro testes do runner passaram, incluindo falhas simuladas e concorrência. O resumo total de cobertura foi truncado pelo filtro de saída; não se atribui percentual exato nem variação contra a base. Módulos observados: Tasks 97,94%, Accounts 89,74%, TaskLive.Index 98,71%.
- E2E completo: **2 testes Chromium aprovados**, código 0 em `tmp/e2e/run-uN5Bbgob/exit-code.txt`. Relatório em `tmp/e2e/run-uN5Bbgob/playwright-report/index.html`; logs e remoção de containers/rede confirmados em `cleanup.log`. Usa release construído e banco descartável próprios.
- `rtk just precommit`: saída 0, 245 testes aprovados, seed 684323; nenhuma alteração executável ou de lockfile. `git diff --check` aprovado.
- A resolução adversa do Compose reproduziu R7 sem executar ação destrutiva. Não foram executados reset de desenvolvimento nem tarefas humanas.

## Aceites ainda pendentes

- [TASK-050](tasks/050-aceite-mvp-producao.md): consolidar os aceites transversais no release local; o aceite do MVP anterior não substitui essa avaliação.
- [TASK-056](tasks/056-cenarios-e2e.md): cobrir fluxos autenticados, arraste e temas no navegador. A limitação visual original da TASK-054 permanece registrada na própria tarefa.

Limpeza documental em 16/10/2026: retirados achados resolvidos R1–R6, aprovações antigas e orientações de fila superadas, após conferência das tarefas e índices atuais. R7 permanece aberto. Nenhum código corrigido ou gate reexecutado nesta limpeza; as evidências acima pertencem à revisão do alvo informado.
