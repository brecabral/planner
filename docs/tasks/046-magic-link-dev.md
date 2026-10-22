---
id: "TASK-046"
status: "done"
execution_level: "standard"
execution_rationale: "Integra o notifier autenticado à mailbox Swoosh já instalada e documenta o fluxo verificável."
specs: ["SPEC-005"]
depends_on: ["TASK-045"]
provides: ["local-magic-link-testing"]
consumes: ["private-user-planning"]
write_scope: ["config/dev.exs", "config/test.exs", "config/config.exs", "lib/planner/mailer.ex", "lib/planner/accounts/user_notifier.ex", "lib/planner_web/router.ex", "test/", "README.md", "docs/tasks/046-magic-link-dev.md"]
blockers: []
---

# 046 — Preparar teste local de magic link

## Objetivo e entradas

Entregar SPEC-005 RN14/CA-005-12. Ler Mailer/configuração Swoosh, notifier, router e README. A rota `/dev/mailbox` e Swoosh já existem; reutilizá-los sem serviço externo ou novo gerador.

## Aceite e testes

1. Em dev, cadastrar/solicitar magic link captura mensagem local com host/porta configurados; seguir URL permite entrar e chegar ao dashboard. Não requer credenciais de envio real.
2. Fluxo permite sair e testar segunda conta isolada. Em test, usar adapter apropriado e assertions de destinatário/link sem enviar e-mail real. Cobrir falha de envio sem sessão indevida.
3. Mailbox/LiveDashboard dev ausentes na configuração de produção. Documentar somente no README os passos executáveis de cadastro, mailbox, link expirado/reenvio e troca de conta, incluindo limites de teste local versus entrega externa.
4. Não escolher provedor de produção nem expor mailbox fora de dev. Não alterar TTL/revogação para facilitar teste.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.

### Entrega retomada em 13/10/2026

Dependência TASK-045 integrada em `800b2d3` e concluída em `8217228`, base desta entrega; SPEC-005 pronta e sem impedimentos abertos aplicáveis. Os arquivos de teste parciais encontrados foram preservados e completados. O notifier, adapters e rotas existentes já atendem ao contrato; não foi necessário alterar código funcional nem configurações. A execução inicial dos três testes herdados passou antes das mudanças documentais, sem fase vermelha artificial para comportamento já implementado. Acrescentada verificação explícita do adapter de teste e limpeza/restauração do estado global dos testes síncronos.

| Aceite | Evidência e resultado |
| --- | --- |
| 1 — Captura local, host/porta e entrada | `LocalMagicLinkTest` registra duas contas pela LiveView com adapter local, verifica destinatário, assuntos pt-BR e URL `127.0.0.1:4107`, abre confirmação e consome token pelo controller até `/tasks`. Solicitação posterior pelo login gera novo link da primeira conta. Preview Swoosh retorna as mensagens das duas contas. |
| 2 — Troca de conta, adapter test e falha | O teste sai das duas sessões, verifica ausência da tarefa de A em B e sua presença ao retornar a A. Teste específico usa `Swoosh.TestAssertions.assert_email_sent`, destinatário e token válido, sem mensagem na memória local. Adapter de falha retorna erro no notifier; solicitação via login mantém feedback genérico, sem confirmação de conta ou token de sessão e com `/tasks` protegido. |
| 3 — Rotas e procedimento | Leitura das três configurações e testes do router em `test` confirmam adapters e ausência de rotas dev. Conferência adicional dos routers efetivamente compilados: `mix phx.routes` lista mailbox/dashboard em dev; `MIX_ENV=prod mix phx.routes` não contém `/dev`. README reúne cadastro, mailbox, confirmação, expiração/reenvio, uso único, troca de conta, host/porta e limites. |
| 4 — Limites preservados | Diff limitado a README, esta tarefa e dois arquivos de testes; nenhuma alteração de TTL, revogação, provedor ou exposição de mailbox. Testes existentes de tokens expirados/consumidos continuam verdes. |

Validações executadas via RTK após consulta das ajudas Mix: teste direcionado **4/4**, `mix precommit` **227 testes aprovados**, `mix ci` **227 testes aprovados**, Credo estrito sem achados, assets compilados e npm audit sem vulnerabilidades. Cobertura total **93,76%** (base TASK-045 **93,75%**, mínimo **70%** preservado); Mailer, UserNotifier, UserToken e Login **100%**. As duas primeiras tentativas de CI detectaram alias ausente e sua ordenação no teste parcial; ambos corrigidos antes dos gates finais. `git diff --check` aprovado. A primeira compilação adicional em prod emitiu warnings das dependências já instaladas; terminou com sucesso e não alterou dependências.

Autoavaliação pelo implementador `implement_046`, conforme fluxo de review: alvo é o diff local dos quatro arquivos sobre `8217228`; critérios acima atendidos, sem achados bloqueantes dentro do escopo. Não constitui revisão independente nem avança seu marco. LiveViewTest e Plug verificam servidor e submissões, sem navegação real ou JavaScript de navegador; o procedimento manual não foi executado em navegador nesta entrega. Entrega externa permanece não verificada e fora do escopo. Nenhum hook alterado.

Entrega em `in_review`, aguardando conferência operacional e commit de integração do coordenador. Nenhum staging, commit ou publicação efetuado pelo implementador; consumidoras não iniciadas.

### Conferência operacional — 13/10/2026

Coordenador `/root`: entrega integrada em `b13245f` na branch `feat/ux`. Conferidos escopo, autoavaliação, gates relatados aprovados (227 testes e cobertura 93,76%) e ausência de impedimentos. Sem reprodução de testes ou revisão independente. A conclusão operacional libera TASK-047; limites de navegador e entrega externa preservados.

### Revisão independente — 13/10/2026

Revisor `/root`, alvo `b0810ba49cf6049c7d5aac49960950a5236be22b`, base reconstruída `367bf3555bc2b06e5ce90aedc2118e46e00986de`. Fluxo local e falha no login verificados; falta cobertura da falha de envio no cadastro, que reproduziu R3 na implementação da TASK-015. `mix ci`: 240 testes aprovados, cobertura 94,08%; testes JavaScript de arraste/tema: 9 aprovados. Escopo, reprodução adicional com falha, achados documentais e limites em docs/review.md (histórico em `4ed2a47:docs/review.md`, seção `revisão-das-últimas-entregas-e-documentação--13102026`). Sem correção de produto ou mudança do estado operacional nesta revisão.
