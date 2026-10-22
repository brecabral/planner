---
id: "TASK-053"
status: done
execution_level: basic
execution_rationale: "Ajuste localizado de apresentação e navegação, com padrão de botão existente e contrato fechado."
specs: ["SPEC-005"]
depends_on: ["TASK-052"]
provides: ["visible-login-registration-action"]
consumes: ["public-join-page"]
write_scope: ["lib/planner_web/live/user_live/login.ex", "test/planner_web/live/user_live/login_test.exs", "docs/tasks/053-destacar-criar-conta-login.md"]
blockers: []
---

# 053 — Destacar Criar conta como botão no login

## Objetivo e contexto

Implementar [SPEC-005 RN20/CA-005-18](../specs/005-contas-e-acesso.md#correção-de-acesso-ao-cadastro--14102026). TASK-052 integrada em `50c7638`; o login já aponta a `/join`, porém `register-link` não usa aparência de botão. Ler Login, seu teste e o componente de botão existente; consultar referências de HEEx, interface e testes antes da alteração.

## Escopo e aceite

1. Aplicar ao link de cadastro o padrão visual do botão de entrar, com mesma largura/altura/destaque, abaixo dele e separado por espaçamento. Preservar o texto traduzido existente e o ID estável.
2. Com e-mail vazio, clicar ou usar teclado navega para `/join` sem submeter login. O botão de entrar conserva o fluxo atual.
3. Conferir CA-005-18 em navegador nas duas larguras e registrar evidência do foco e da apresentação.

Não alterar layout global, rotas, Registration, autenticação, CSS global ou catálogos. Não gerar scaffold. O recurso é somente a ação de cadastro no login.

## Validação e entrega

Regressão enxuta do destino e da independência da submissão; testes de login existentes. Conferência visual não se deduz de classes HTML. Seguir README para execução e consultar `mix help` antes das tarefas Mix; finalizar com `mix precommit`, cobertura mínima existente de 70%, autoavaliação conforme fluxo de review e conferência operacional/integracão conforme coordenação, sem revisão independente automática. Registrar comandos, resultados, limitações e commit nesta tarefa. Se surgir impedimento real, seguir docs/blocks/README.md.

## Estado

Implementada em 14/10/2026 sobre `1b5b5a8`, com TASK-052 integrada. Retomada em 15/10/2026 e encaminhada para conferência operacional e integração. O usuário instruiu explicitamente: “nao valide no navegador, eu valido”. A validação visual e por teclado fica a cargo do usuário; não foi executada nem presumida nesta entrega.

## Evidências de implementação

- `register-link` reutiliza o componente `.button` com `navigate`, que produz um link nativo; fica após e fora do formulário, com as mesmas classes de tamanho e destaque de entrar. O contêiner existente fornece espaçamento. Texto Gettext e ID preservados.
- Criado `test/planner_web/live/user_live/login_test.exs` (o arquivo previsto no escopo ainda não existia). Regressão verifica ordem após o formulário, navegação independente com e-mail vazio, ausência de feedback de login e nenhum envio de e-mail. Testes existentes de autenticação preservados.
- TDD: teste final executado contra a apresentação anterior falhou na posição esperada do link; implementação restaurada e validada. Ajustes no teste alinharam o texto à tradução existente e trataram a ausência do campo de flash no redirecionamento.
- `rtk mix test test/planner_web/live/user_live/login_test.exs test/planner_web/authentication_flow_test.exs`: 10 testes aprovados.
- Após consulta às ajudas, `rtk mix precommit`: 245 testes aprovados. `rtk mix ci`: 245 testes aprovados, Credo sem achados, cobertura total 93,62% e Login 100%, assets compilados e auditoria npm sem vulnerabilidades. Limiar de 70% preservado.

## Autoavaliação

Implementador original `/root/task053`; retomada por `/root/finish053` em 15/10/2026. Alvo: diff local dos arquivos de Login e seu teste sobre `1b5b5a8`, conforme fluxo de review. Escopo restrito à apresentação/navegação; fluxo de magic link preservado e coberto pela suíte existente. Nenhum achado técnico bloqueante no diff. Não constitui revisão independente nem avança seu marco. Commit será registrado pelo coordenador após a conferência operacional.

| Critério | Evidência e limites |
| --- | --- |
| 1 — Apresentação da ação | Inspeção do diff e do componente `.button`: mesmas classes de entrar, link após o formulário, espaçamento no contêiner, texto Gettext e ID preservados. Não comprova dimensões renderizadas. |
| 2 — Navegação independente | Regressão LiveView registrada acima verifica `/join`, link fora do formulário, ausência de flash de login e nenhum e-mail enviado; suíte existente cobre autenticação. Interação real por clique/teclado não observada. |
| 3 — Navegador em 320/1280 px | Dispensada para o agente por instrução explícita do usuário em 15/10/2026; apresentação, foco e teclado reservados à validação dele. Não alegar aceite visual concluído. |

Na retomada, nenhuma alteração de código ou teste foi necessária; mantidas as evidências anteriores de `precommit` e `ci`, sem repetir os gates sobre o mesmo código. `rtk git diff --check` aprovado. Autoavaliação técnica apta ao encaminhamento, com a limitação de navegador explicitamente aceita pelo usuário.

Ainda em 15/10/2026, o usuário confirmou: “ui esta correto o botao esta destacado”. Essa confirmação registra aceite humano da apresentação e do destaque do botão. Não implica verificação de teclado, foco ou das duas larguras, que não foram especificados na confirmação; permanece a dispensa de validação em navegador pelo agente.

## Conclusão operacional — 15/10/2026

Coordenador `/root`: entrega integrada na base local em `7100cc4`. Conferidos registro, autoavaliação, gates relatados aprovados (245 testes e cobertura 93,62%), ausência de impedimentos e aceite humano do destaque. Sem reprodução dos testes ou revisão independente. Tarefa concluída; limites da validação humana preservados acima.
