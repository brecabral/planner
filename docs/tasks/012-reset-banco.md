---
id: "TASK-012"
status: "planned"
execution_level: "human"
execution_rationale: "O responsável declarou que fará o reset; operação exclusivamente humana."
specs: []
depends_on: ["TASK-002"]
provides: ["clean-database"]
consumes: ["experimental-crud-removed"]
write_scope: []
blockers: []
---

# 012 — Reinicializar o banco após remover o experimento

## Ação humana

Após integrar a remoção do experimento, reinicializar o banco de desenvolvimento para começar com base limpa. O responsável assumiu essa ação ao autorizar a remoção da migration. Procedimento operacional: seção de banco no [README](../../README.md).

## Aceite

Confirmar execução do reset e preparação da base com as migrations remanescentes, sem a tabela experimental. Registrar confirmação e resultado antes de marcar `done`.

As consumidoras aguardam essa confirmação. Esta tarefa não inclui reset de produção.
