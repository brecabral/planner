---
id: "TASK-027"
status: "planned"
execution_level: "standard"
execution_rationale: "Representa snapshot autorizado em streams e contadores coerentes após recarga."
specs: ["SPEC-002", "SPEC-004"]
depends_on: ["TASK-026"]
provides: ["planning-panel-read"]
consumes: ["planning-snapshot", "task-live-scaffold"]
write_scope: ["lib/planner_web/live/task_live/index.ex", "priv/gettext/", "test/planner_web/live/task_live_test.exs"]
blockers: []
---

# 027 — Mostrar hoje, backlog, retry e cota no painel

## Entrada e limite

[SPEC-004](../specs/004-experiencia-e-acesso.md) RN01/RN05/RN06; consumir planning-snapshot e task-live-scaffold. Referência LiveView.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Adaptar Index gerado ao snapshot com três streams e contadores/estados vazios próprios. Numerar prioridades e mostrar escolhas disponíveis. Ao receber atualização scoped, se mantida a assinatura gerada, reconstruir snapshot em vez de inserir task arbitrariamente em uma lista. Não implementar botões de transição ainda.

## Aceite e teste de intenção

1. Cada tarefa aparece na coleção correta; contagem vem do domínio e sobrevive à recarga.
2. Estado sem pendências mas com três conclusões mostra cota esgotada, não vagas livres.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
