---
id: "TASK-035"
status: "planned"
execution_level: "standard"
execution_rationale: "Executa restauração em base isolada e confere integridade sem modificar o banco ativo."
specs: []
depends_on: ["TASK-008"]
provides: ["database-recovery-verified"]
consumes: ["remote-runtime-delivery"]
write_scope: ["README.md", "docs/tasks/035-validar-restauracao.md"]
blockers: ["Confirmar inclusão do ensaio de backup/restauração como extensão após o MVP."]
---

# 035 — Validar backup e restauração em base isolada

## Entrada e limite

Extensão operacional proposta após o MVP, sujeita à confirmação de escopo. Consumir remote-runtime-delivery. Não é condição de CA07/CA16, que verificam persistência após reinício; não bloqueia o aceite da TASK-008.

## Execução

Documentar procedimento do provedor escolhido e provar restauração em base isolada. Conferir tarefas, labels, conclusões e cotas. Não sobrescrever banco ativo nem publicar dados privados.

## Aceite

1. Backup restaurado mantém vínculos, proprietário, ordem histórica e cota com contagens conferidas.
2. Procedimento reproduzível fica no README; evidência sem dados pessoais fica nesta tarefa.

Registrar os resultados dos cenários executados. Finalizar alterações locais com `mix precommit`; testes de aplicação não substituem a evidência operacional desta tarefa.

## Evidência e revisão

Pendentes. Registrar versão/ambiente verificados, resultados e limitações, precommit para alterações locais, revisor independente, achados e integração.
