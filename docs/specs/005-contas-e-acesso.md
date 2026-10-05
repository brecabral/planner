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

- RN05: em ambiente de desenvolvimento (`dev` da configuração Elixir), acessar o painel ou diretamente o formulário de cadastro garante a existência do usuário de identificador `default` antes de resolver o proprietário. Se ausente, cria somente esse usuário; acessos repetidos, remontagens LiveView e acessos simultâneos reutilizam a mesma identidade. Não escolher o primeiro registro arbitrário do banco.
- RN06: criação automática no acesso fica desabilitada por padrão e em `test`/`prod`. Nesses ambientes, ausência do usuário continua exigindo preparação explícita; testes usam fixtures. Seeds explícitos mantêm seu contrato idempotente. A configuração vem do servidor, nunca de parâmetros da requisição.
- RN07: banco e migrations são pré-requisitos. A criação automática não cria banco, aplica migrations ou mascara erros de persistência; não insere tarefas/labels demonstrativas nem altera dados existentes.

## Cenários de aceite

- CA-005-01: repetir preparação mantém um único usuário padrão.
- CA-005-02: abrir painel permite usar o planejamento sem login; recarregar preserva proprietário e dados.
- CA-005-03: enviar user_id forjado no cadastro não troca o proprietário; label incompatível é rejeitada sem gravação parcial.

- CA-005-04: dado banco migrado em `dev` sem usuário padrão, abrir `/tasks` ou, em cenário independente, `/tasks/new` cria `default` e permite usar a tela sem executar seeds previamente; repetir acesso e conexão LiveView mantém sua identidade.
- CA-005-05: dado usuário padrão com tarefas e labels, repetir acesso em `dev` preserva identidade, timestamps e dados. Se existir apenas outro usuário, cria `default` sem assumir ou alterar a identidade existente. Criações simultâneas convergem para um único `default` pela unicidade já existente.
- CA-005-06: com criação automática desabilitada, resolver usuário ausente não insere registros e mantém o erro de ausência; usuário previamente preparado continua utilizável. Configurações de `test` e `prod` não habilitam a criação automática.

## Implementação

Gerar somente contexto/schema de usuário e ajustar seed/resolução no servidor. `phx.gen.auth` não é executado no MVP. A solução final de contas será especificada antes de retomar suas tarefas futuras.

Incremento solicitado em 05/10/2026: criação automática em desenvolvimento, planejada na [TASK-037](../tasks/037-usuario-padrao-dev.md), ainda não implementada.
