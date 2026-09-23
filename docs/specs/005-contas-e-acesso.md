---
id: "SPEC-005"
status: draft
requirements: ["RF08", "CA13", "CA16"]
---

# 005 — Contas e isolamento de dados

## Escopo e decisões confirmadas

Acesso remoto com contas individuais. Cada usuário acessa somente suas tarefas, labels, histórico, escolhas e configurações, conforme resposta de produto de 23/09/2026. Não há compartilhamento ou administração de dados de terceiros nesta entrega.

## Arquitetura e casos de uso

`Planner.Accounts` concentra identidade, credenciais/tokens, sessão e configurações da própria conta. A base é `phx.gen.auth`, preservando schemas, scope, helpers e proteções gerados; adaptações de produto são incrementais. A implementação proposta usa a geração LiveView para alinhar navegação e gerenciamento da conta ao painel.

`Accounts.Scope` é o contrato de identidade consumido pelos contextos de tarefas e labels. Guardas HTTP/on_mount protegem a entrada; consultas e mutações scoped protegem os dados mesmo fora de uma tela. Login, confirmação/recuperação, logout, expiração e alteração da conta compõem esta spec; escolher o fluxo exato de entrada continua sujeito às decisões abaixo.

## Regras

- RN01 (confirmada): todo acesso ao planejamento e gerenciamento da conta exige identidade autenticada no servidor; visitante deve autenticar-se antes de obter dados privados.
- RN02 (confirmada): consultas e mutações recebem o escopo autenticado. IDs em parâmetros não autorizam acesso e não permitem escolher proprietário. Dados de outra conta têm resposta equivalente a dados inexistentes, sem conteúdo privado.
- RN03: autenticação válida estabelece sessão; logout ou expiração impede novas leituras e mutações privadas, inclusive em LiveView já conectada. Reconexão revalida a identidade. Mudança de conta não reaproveita coleções privadas da anterior.
- RN04: gerenciamento altera somente a própria conta. Preferência de fuso segue a [SPEC-003](003-dia-e-historico.md). Dados e credenciais privadas não aparecem em logs ou mensagens de erro.

## Decisões pendentes

Escolher o mecanismo de entrada e criação/recuperação de conta: senha, link por e-mail ou provedor externo; definir se cadastro é aberto ou por convite. Isso determina os cenários de credencial inválida, confirmação, recuperação e expiração a acrescentar antes de `ready`. Isolamento entre usuários não está em aberto.

## Cenários de aceite

- CA-005-01: visitante tenta abrir painel, histórico ou conta e é direcionado à autenticação, sem receber dados privados por HTTP ou montagem LiveView.
- CA-005-02: A envia ID de tarefa ou label de B em consulta, seleção, conclusão ou associação; resposta não revela B e os dados de ambos permanecem consistentes.
- CA-005-03: A tenta modificar configurações de B; operação é rejeitada. IDs de proprietário enviados no cadastro são ignorados ou rejeitados, nunca usados como autoridade.
- CA-005-04: após logout ou sessão inválida, eventos de uma aba já aberta não acessam dados; reconexão exige autenticação. Entrar como B não exibe dados anteriores de A.
- CA-005-05: duas sessões autenticadas operam seus próprios dados e preferências sem interferência.

## Dados e implementação

Contas e tokens pertencem a Accounts; tarefas e labels referenciam o proprietário autenticado. Scaffold e integração da política de sessão são etapas distintas no [mapa de entregas](../tasks/README.md).
