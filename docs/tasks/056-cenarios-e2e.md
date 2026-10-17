---
id: "TASK-056"
status: "done"
execution_level: "advanced"
execution_rationale: "Prepara identidade isolada e valida interações reais entre hooks, LiveView e persistência."
specs: ["SPEC-002", "SPEC-004", "SPEC-005", "SPEC-007"]
depends_on: ["TASK-058", "TASK-054", "TASK-040"]
provides: ["e2e-authenticated-suite"]
consumes: ["e2e-runner", "navbar-theme-selection"]
write_scope: ["assets/e2e/", "assets/playwright.config.ts", "compose.e2e.yaml", "test/support/e2e/", "README.md", "docs/tasks/056-cenarios-e2e.md"]
blockers: []
---

# 056 — Cobrir os fluxos autenticados no navegador

## Objetivo e contexto

Usar o runner integrado e cobrir comportamento existente. Ler D20, specs listadas, cenários públicos e implementação de auth, temas e arraste. Não criar regras de produto. Fixtures privadas criam contas/dados sintéticos e token pelo mecanismo existente via execução no container; navegar pela rota normal de consumo do token. As fixtures devem funcionar tanto no Compose local quanto no release do GitHub, cujo container é identificado por `E2E_CONTAINER`; nenhuma preparação pode depender exclusivamente do Just. Não criar endpoint de bypass nem depender de e-mail externo. Preparação falha explicitamente se o contrato de auth mudar.

## Aceite

1. Cada cenário tem conta/dados independentes. Uma conta não vê tarefas da outra; visitante permanece redirecionado. Execução completa repetida passa sem depender da ordem dos testes.
2. No navegador autenticado, cadastrar tarefa com label, selecionar até três, rejeitar quarta sem alterar estado, devolver e verificar restituição, concluir e consultar histórico. Conferir persistência por recarga e estado final visível.
3. Excluir pendência pelo menu exercita cancelar/confirmar; cancelamento preserva, confirmação remove e restitui cota quando aplicável. Testar ordem por menu e gesto real de arraste com mouse, conferindo ordem persistida após recarga; cobrir interação touch de arraste em contexto móvel, sem tratá-la como prova em hardware físico.
4. Trocar claro/escuro pela navbar altera estilo computado e persiste após recarga. Logout e outra conta não herdam preferência indevida. Testar viewport desktop e estreito, visibilidade e acionamento dos controles afetados.
5. Formular cenário com diálogo de cadastro, validação e recuperação, Escape/foco e patch LiveView mantendo interface utilizável. Asserções por resultado, sem sleeps fixos, skips de aceites ou dependência apenas de classes.
6. Suíte pública e autenticada passa pelo comando canônico; falha de asserção produz evidências no contrato do runner. README descreve fixtures, cobertura e limites (inclusive não validar entrega de e-mail real nem substituir avaliação estética).

## Limites

Não corrigir silenciosamente defeitos de produto: se a suíte revelar falha preexistente fora do escopo, preservar teste/evidência e seguir protocolo de bloqueios. Não alterar aplicação de produção para facilitar autenticação de teste.

## Validação e entrega

Consultar ajuda Mix e operação no README. Aplicar TDD enxuto aos comportamentos novos, executar gates existentes com cobertura mínima de 70% preservada e E2E completo. Registrar comandos, alvo, resultados, evidências por critério e limitações; autoavaliação pelo fluxo de review, sem aprovação independente implícita. Conferência operacional e commit integrado são necessários antes de `done`. Estado inicial: planejada, sem implementação ou validação executada neste planejamento.

## Reconciliação de R7 — 16/10/2026

Aguardar a TASK-058 para usar os gates locais com isolamento corrigido, conforme [BLOCK-006](../blocks/006-isolamento-compose-teste.md). Dependências anteriores continuam alcançáveis pela cadeia; nenhuma implementação ou validação adicional nesta rodada.

## Progresso e encerramento solicitado — 16/10/2026

TASK-058 integrada em `633b400`, com BLOCK-006 encerrado em `7a45081`. Implementador `/root/task056`; execução interrompida pelo coordenador a pedido do usuário para fazer commit e encerrar. Estado mantido em `in_progress`, sem conclusão operacional ou aprovação independente.

Preservados sete cenários autenticados em `assets/e2e/authenticated.spec.ts`, helper de contas, fixture privada em `test/support/e2e/accounts.exs`, integração Compose, configuração Playwright e documentação no README. Cobrem planejamento/cota/histórico/isolamento, exclusão, ordem por menu/mouse/touch, diálogo e temas desktop/estreito. Verificações de interface estão na suíte versionada; teclado no tema corresponde à SPEC-007 CA-007-05 e Escape/foco ao aceite 5. Aplicar a política de validação do AGENTS.md registrada em `e5bfb02`.

Evidências relatadas: `just ci` e `just precommit` aprovados com 245 testes ExUnit e limiar de cobertura de 70% preservado. Rodada anterior E2E em `tmp/e2e/run-2WxStWAQ/` passou 9/9 antes dos últimos ajustes. Houve rodadas intermediárias com falhas nos testes, corrigidas dentro da suíte. Na rodada mais recente, `tmp/e2e/run-nWYOi4iy/tests.log` registra 9/9 e Playwright com saída zero; o encerramento foi solicitado durante a finalização do runner. Isso não comprova repetição completa da versão final nem aceite de todos os contratos. Não houve CI remoto.

Retomada: conferir finalização/limpeza do último runner e evidências preservadas; concluir a repetição exigida pelo aceite 1, autoavaliação e conferência operacional. TASK-050 não foi iniciada. Este commit preserva progresso, sem liberar a suíte como entrega concluída.

## Conferência operacional — 17/10/2026

Coordenador `/root`: conferidos registro, escopo documental, autoavaliação e gates relatados, sem impedimentos. Suíte integrada em `be7d194` e validação final registrada em `a058a3a`, presentes na base local das próximas entregas. TASK-056 concluída operacionalmente após commit bem-sucedido; TASK-050 pode prosseguir na sequência serializada. Não houve reprodução de testes pelo coordenador, revisão independente, CI remoto ou publicação.

## Retomada e autoavaliação — 17/10/2026

Implementador `/root/task056`, capacidade advanced. Alvo avaliado: `be7d1947d1eea0d8c4a52a47302adab86f01c36f`, comparado à base `e5bfb029d84762e82e8e849c3eb5ef8935d7789a`; nenhuma alteração adicional de código foi necessária. Dependências TASK-058/054/040 integradas, BLOCK-006 resolvido. Aplicado o fluxo de review como autoavaliação, sem revisão independente nem avanço do marco em `docs/review.md`.

A finalização da rodada anterior foi confirmada: `tmp/e2e/run-nWYOi4iy/` contém 9/9 aprovados, `exit-code.txt` zero e remoção de containers, rede e volume em `cleanup.log`; consulta ao Docker não encontrou containers desse projeto. A repetição canônica `just e2e` nesta retomada também passou 9/9, sem retries ou skips, com saída zero e limpeza completa em `tmp/e2e/run-ejTEcLX1/`. O código dos cenários permaneceu idêntico entre as duas execuções completas. Cada execução preparou banco e contas novos.

| Aceite | Evidência e resultado |
| --- | --- |
| 1 — isolamento e repetição | Fixture gera duas contas com UUID por cenário; os cenários não compartilham identidade nem dados. `daily planning` compara dados/cota de duas sessões e confirma ausência da tarefa privada da outra conta após recarga. Os dois cenários públicos mantêm redirecionamento ao login. Duas execuções completas aprovadas; independência de ordem sustentada pelo isolamento das fixtures, sem permutação adicional da ordem nesta rodada. |
| 2 — planejamento | `daily planning` cadastra label, seleciona três, rejeita a quarta conservando listas, devolve/restaura escolha, seleciona novamente, conclui sem restituir e consulta histórico/label. Recarga confirma listas, cota e histórico. Aprovado. |
| 3 — exclusão e ordem | `deletion` cancela e confirma exclusão de hoje, verifica preservação/remoção e restituição após recarga. `ordering` verifica menu e gesto com mouse; `touch ordering` usa eventos touch do Chromium em contexto móvel. Ambos conferem ordem persistida após recarga. Aprovados. |
| 4 — temas | Cenários desktop/320 px acionam seletor por teclado, comparam cores computadas de fundo/navbar/painéis, recarregam, exercitam cadastro e alteração de planejamento, saem e entram com outra conta. Controles visíveis/acionáveis e ausência de rolagem horizontal verificados. Aprovados. |
| 5 — diálogo | `task dialog` exercita título inválido, recuperação, histórico expandido durante patch, Escape com restauração do foco, formulário limpo ao reabrir e operação posterior de seleção. Sem sleeps fixos ou asserções limitadas a classes. Aprovado. |
| 6 — operação e evidências | `just e2e` executou os nove cenários públicos/autenticados. Relatório HTML, logs e resultados coletados antes da limpeza. Falhas de asserção da rodada histórica `run-JcSKiA51` preservam `trace.zip`, screenshot e contexto de erro em `test-results/`, comprovando o contrato de evidências sem introduzir falha artificial na suíte final. README descreve fixtures Compose/release, cobertura e limites. |

Gates desta retomada, após consulta a `mix help ci` e `mix help precommit`: `just ci` aprovado com 245 testes ExUnit, cobertura acima do mínimo inalterado de 70%, Credo sem achados, assets, oito testes JavaScript, auditoria npm e sete testes de tooling; `just precommit` aprovado com 245 testes. O CI emitiu avisos conhecidos de redefinição de módulos de migrations durante os testes e terminou com saída zero; nenhuma migration foi modificada. `git diff --check` aprovado. A cobertura ExUnit não mede os cenários Playwright; estes têm resultado próprio 9/9.

Conclusão: **approved no escopo da autoavaliação**, sem achado bloqueante identificado. Estado `in_review`, pronto para conferência operacional e commit pelo coordenador. Somente este arquivo documental foi alterado na retomada; a suíte já está integrada no commit alvo. Limites: não houve CI remoto; o caminho `E2E_CONTAINER` foi inspecionado contra o workflow, sem execução no GitHub. Touch emulado não comprova hardware físico; fixtures não validam entrega real de e-mail; cores computadas não substituem avaliação estética. Nenhum código de produção foi alterado para facilitar autenticação ou contornar falhas.
