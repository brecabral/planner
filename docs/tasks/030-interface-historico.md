---
id: "TASK-030"
status: "planned"
execution_level: "standard"
execution_rationale: "Integra conclusão e consulta histórica existentes sem alterar a regra de consumo."
specs: ["SPEC-003", "SPEC-004", "SPEC-006"]
depends_on: ["TASK-029"]
provides: ["history-ui"]
consumes: ["planning-order-ui", "complete-task", "history-query"]
write_scope: ["lib/planner_web/live/task_live/index.ex", "priv/gettext/", "test/planner_web/live/task_live_test.exs"]
blockers: []
---

# 030 — Ligar conclusão e consulta de histórico

## Entrada e limite

[SPEC-003](../specs/003-dia-e-historico.md) CA-003-03/05/06 e [SPEC-004](../specs/004-experiencia-e-acesso.md) CA-004-05/06; consumir complete-task, history-query e planning-order-ui.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Adicionar concluir e histórico acessível no painel existente, com labels e data original. Atualizar snapshot após conclusão sem restituir cota. Não gerar um novo CRUD para conclusões.

## Aceite e teste de intenção

1. Conclusão repetida aparece uma vez no histórico e mantém escolha usada.
2. Três conclusões deixam hoje vazio com cota esgotada; histórico próprio e labels persistem na recarga.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit e CI com cobertura mínima de 70%, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
