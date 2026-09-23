---
id: "TASK-017"
status: "planned"
execution_level: "standard"
execution_rationale: "Integra formulário e persistência de fuso usando a trava e política temporal já definidas."
specs: ["SPEC-003"]
depends_on: ["TASK-020"]
provides: ["timezone-settings"]
consumes: ["user-timezone-storage", "daily-quota-transaction", "authenticated-user-scope"]
write_scope: ["lib/planner/accounts.ex", "lib/planner_web/live/user_live/settings.ex", "priv/gettext/", "test/planner/accounts_test.exs", "test/planner_web/live/user_live/settings_test.exs"]
blockers: []
---

# 017 — Editar o fuso na conta com segurança transacional

## Entrada e limite

[SPEC-003](../specs/003-dia-e-historico.md) RN01 e política de vigência aprovada; consumir user-timezone-storage e daily-quota-transaction. Referências formulários, LiveView e Gettext.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Estender a tela Settings produzida por phx.gen.auth, sem novo CRUD. Implementar alteração de fuso sob o mesmo bloqueio de usuário do planejamento; aplicar vigência aprovada. Não alterar datas históricas. Proteger a própria conta e traduzir campo/erros.

## Aceite e teste de intenção

1. CA-003-07: válido persiste conforme vigência; inválido/alheio não altera conta.
2. Troca concorrente com a fronteira transacional respeita a mesma trava; o cálculo mantém datas históricas. A [TASK-022](022-selecionar-tarefa.md) verifica a integração dos dois comandos reais em CA-003-08.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
