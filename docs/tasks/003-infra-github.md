---
id: "TASK-003"
status: "done"
execution_level: "human"
execution_rationale: "Configuração e aceite do gate reservados ao responsável pelo repositório."
specs: []
depends_on: []
provides: ["github-quality-gate"]
consumes: []
write_scope: [".github/workflows/", "mix.exs", "mix.lock", ".credo.exs", "README.md"]
blockers: []
---

# 003 — Proteger a main e configurar o CI no GitHub

## Entrega

Workflow com check `quality` e alias `mix ci`, verificando compilação, formatação, testes e Credo. Proteção da `main` exige PR com CI aprovado e impede force push e exclusão indevidos. Cobertura mínima obrigatória de 70%, já configurada no CI e confirmada pelo responsável.

## Aceite humano

Concluída em 23/09/2026. O responsável confirmou a conclusão e informou ter revisado o check do CI. Essa validação encerra a tarefa e libera suas consumidoras, sem nova verificação ou evidência adicional exigida do agente.
