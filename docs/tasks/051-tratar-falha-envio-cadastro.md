---
id: "TASK-051"
status: planned
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
