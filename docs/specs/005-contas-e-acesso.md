---
id: "SPEC-005"
status: ready
requirements: ["CA13"]
---

# 005 — Usuário padrão do MVP

## Escopo e arquitetura

O MVP de teste usa um usuário padrão persistente definido no servidor, sem tela de login, cadastro de conta, senha, tokens ou autenticação. Todas as visitas usam esse mesmo planejamento. Decisão do responsável em 23/09/2026; não é um serviço de contas privadas por visitante.

`Planner.Accounts` fornece somente criação idempotente/localização desse usuário. Tasks e labels mantêm `user_id` para identificar seu proprietário. As APIs recebem o usuário resolvido pelo servidor; não é necessário criar `Accounts.Scope`, pipeline de autenticação ou um mecanismo de sessão.

## Regras

- RN01: preparar os dados cria o usuário padrão uma única vez, com identificador estável. Repetir seeds não duplica o usuário nem altera seus dados de planejamento.
- RN02: abrir o painel usa automaticamente esse usuário, sem redirecionar para login ou pedir escolha de conta.
- RN03: proprietário de tarefa/label vem do usuário padrão no servidor, nunca de um campo editável ou parâmetro do navegador. Vínculos entre tarefa e label continuam exigindo proprietário compatível.
- RN04: testes criam sua fixture de usuário sem depender de seed global; validações de proprietário podem usar outra fixture para rejeitar IDs incompatíveis. Isso não cria um fluxo de múltiplas contas na interface.

## Cenários de aceite

- CA-005-01: repetir preparação mantém um único usuário padrão.
- CA-005-02: abrir painel permite usar o planejamento sem login; recarregar preserva proprietário e dados.
- CA-005-03: enviar user_id forjado no cadastro não troca o proprietário; label incompatível é rejeitada sem gravação parcial.

## Implementação

Gerar somente contexto/schema de usuário e ajustar seed/resolução no servidor. `phx.gen.auth` não é executado no MVP. A solução final de contas será especificada antes de retomar suas tarefas futuras.
