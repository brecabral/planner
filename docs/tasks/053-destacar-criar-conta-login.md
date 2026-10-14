---
id: "TASK-053"
status: planned
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

Planejada em 14/10/2026; dependência concluída na base. Implementação não iniciada.
