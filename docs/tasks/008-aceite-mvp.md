---
id: "TASK-008"
status: "planned"
execution_level: "standard"
execution_rationale: "Consolida evidências e executa fluxo integrado definido, sem implementar correções ou decidir produto."
specs: ["SPEC-001", "SPEC-002", "SPEC-003", "SPEC-004", "SPEC-005", "SPEC-006"]
depends_on: ["TASK-034"]
provides: ["verified-remote-mvp"]
consumes: ["remote-runtime-delivery", "accessible-planner-ui", "github-quality-gate"]
write_scope: ["docs/tasks/008-aceite-mvp.md", "docs/specs/"]
blockers: []
---

# 008 — Executar o aceite final do fluxo integrado

## Entrada e limite

PRD CA01–CA16; consumir a entrega remota e evidências das entregas anteriores, incluindo persistência após reinício da TASK-034. Abrir somente o cenário necessário de cada spec.

## Verificação

Executar um fluxo remoto completo em duas contas e referenciar as evidências já produzidas para concorrência/limites. Registrar matriz CA → evidência nesta tarefa. Não implementar correções aqui: devolvê-las à produtora. Não rever o aceite da TASK-003; rodar o CI vigente para a entrega atual.

## Aceite

1. Cadastro com labels → seleção → retirada ao backlog → nova seleção → conclusão → histórico passa, sem compartilhamento entre contas.
2. Matriz CA01–CA16 tem evidências; revisão independente e integração permitem marcar specs como implemented.

Registrar os resultados dos cenários executados. Finalizar alterações locais com `mix precommit`; testes de aplicação não substituem a evidência operacional desta tarefa.

## Observação de usabilidade

Como evidência complementar do objetivo do PRD, quando houver participante disponível, observar um percurso sem instruções de uso e registrar dúvidas sobre hoje, retry e escolhas disponíveis. Se não realizado, registrar a limitação; não criar uma dependência adicional para o aceite.

## Evidência e revisão

Pendentes. Registrar versão/ambiente verificados, resultados e limitações, precommit para alterações locais, revisor independente, achados e integração.
