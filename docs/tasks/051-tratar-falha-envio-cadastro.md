---
id: "TASK-051"
status: in_review
execution_level: standard
execution_rationale: "Tratamento delimitado de retorno de envio na LiveView, com recuperação pela autenticação existente e testes de integração web."
specs: ["SPEC-005", "SPEC-008"]
depends_on: ["TASK-046", "TASK-048"]
provides: ["registration-delivery-recovery"]
consumes: ["user-theme-switching"]
write_scope: ["lib/planner_web/live/user_live/registration.ex", "priv/gettext/", "test/planner_web/", "test/support/", "docs/tasks/051-tratar-falha-envio-cadastro.md"]
blockers: []
---

# 051 — Tratar falha de envio no cadastro

## Objetivo e entradas

Corrigir R3 da [revisão de 13/10/2026](../review.md#r3--p2-falha-de-envio-no-cadastro-encerra-a-liveview), originado na TASK-015. Aplicar [SPEC-005](../specs/005-contas-e-acesso.md) RN08/RN09/RN15 e CA-005-07/13 e SPEC-008 RN02. TASK-046 fornece o adapter de falha e a captura local; TASK-048 integra o cadastro com concessões de temas. Ambas estão integradas na base revisada `b0810ba`.

Ler registration.ex, login.ex, Accounts.register_user/1 e deliver_login_instructions/2, testes de cadastro e local_magic_link_test.exs, Planner.FailingMailAdapter e referências LiveView, Gettext e testes. O teste temporário citado pelo revisor é evidência histórica, não dependência de execução: criar regressão permanente na suíte.

## Escopo e limites

Tratar o retorno de erro do envio após cadastro na LiveView existente e orientar recuperação pelo login. Preservar a conta já persistida e suas concessões. Não regenerar autenticação, alterar schema/migrations, desfazer cadastro, criar envio automático/retry, escolher provedor ou alterar segurança de tokens/sessões. Não corrigir por captura ampla de exceções. Se a correção exigir ampliar esse contrato, registrar impedimento e devolver ao planejador.

## Aceite e testes

1. Com adapter retornando `{:error, :delivery_unavailable}`, cadastrar e-mail novo não encerra a LiveView por exceção. A navegação controlada leva ao login com mensagem traduzida de falha e orientação para solicitar novo link, sem anúncio de envio bem-sucedido.
2. A conta permanece única, não confirmada e sem sessão autenticada; visitante continua sem acesso ao planejamento. Concessões iniciais permanecem preservadas, sem duplicação ou recriação da conta.
3. Restaurado o adapter de teste, solicitar novo link para o mesmo e-mail e consumi-lo autentica a conta original. Preservar sucesso do cadastro, unicidade normalizada e falha controlada na solicitação de login existente.
4. Teste web permanente reproduz primeiro R3 e passa após a correção; verifica feedback, navegação, ausência de autenticação e recuperação. Configuração alterada pelo teste é restaurada e isolada conforme o padrão existente, sem envio real. Mensagens-base em inglês e catálogo pt_BR não vazio.

## Execução, validação e conclusão

Aplicar fluxo de implementação e TDD enxuto. Registrar autoavaliação pelo fluxo de review, testes direcionados, `mix precommit` e `mix ci` conforme README, com cobertura mínima de 70% preservada e limites explícitos. Revisão independente não é gate automático. O coordenador confere conclusão operacional e registra commit integrado antes de marcar `done` e liberar TASK-011. R3 permanece aberto até a correção comprovada; não alterar o relatório histórico para simular aprovação. Release e aceite final pertencem a TASK-011/050.

### Entrega e autoavaliação — 13/10/2026

Implementador `/root/implement_051`, alvo: diff local dos cinco arquivos desta entrega sobre `5e1a8bf`. Dependências TASK-046/048 concluídas e integradas; nenhum impedimento encontrado. O cadastro agora trata os retornos de sucesso e erro do notifier explicitamente, sem capturar exceções ou alterar persistência, concessões e protocolo de tokens.

| Aceite | Evidência | Resultado |
| --- | --- | --- |
| 1 — Falha controlada e feedback | Regressão permanente em `LocalMagicLinkTest` submete cadastro com `FailingMailAdapter`, segue a navegação ao login e verifica flash de erro pt-BR e ausência de flash de sucesso | A primeira execução reproduziu R3 com `MatchError` em registration.ex:60; após correção passa sem exceção |
| 2 — Conta, concessões e isolamento | Mesmo teste verifica conta não confirmada, nenhum token de sessão, visitante redirecionado de `/tasks` e as duas concessões gratuitas | Conta persistida preservada; concessões idênticas antes/depois da recuperação, sem duplicação |
| 3 — Recuperação e regressões | Restaura adapter de teste, solicita link na LiveView de login, captura destinatário/link e consome token pelo controller; verifica sessão da conta original e rejeição de cadastro normalizado duplicado | Autentica a mesma conta; testes existentes de cadastro bem-sucedido e falha controlada do login continuam aprovados |
| 4 — Teste e tradução | Suíte síncrona existente restaura configuração via `on_exit`; nova mensagem inglesa extraída em POT e traduzida no catálogo pt_BR | Sem envio externo; tradução efetivamente renderizada no login |

Validações após consulta de ajuda Mix: teste vermelho **4/5**, testes direcionados de magic link/autenticação **11/11**, `mix precommit` **241 testes, 0 falhas**, `mix ci` **241 testes, 0 falhas**, Credo estrito sem achados, assets compilados e npm audit sem vulnerabilidades. Cobertura total **94,09%** (base documentada **94,08%**), Registration **93,10%**, mínimo de **70%** preservado. Extração/mesclagem atualizada após formatação; `git diff --check` aprovado.

Autoavaliação conforme fluxo de review: conclusão técnica `approved`, sem achados bloqueantes no escopo e sem revisão independente ou alteração do marco histórico. A regressão cobre ambos os resultados de envio, navegação, tradução, segurança da sessão e recuperação; cobertura de linhas não prova todos os ramos. LiveViewTest/Plug não executam navegador real nem comprovam entrega externa. Nenhum hook alterado. Entrega aguarda conferência operacional e commit do coordenador; TASK-011 não iniciada pelo implementador.
