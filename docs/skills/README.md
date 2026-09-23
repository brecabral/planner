# Habilidades do projeto

| Skill | Quando carregar |
| --- | --- |
| [review-plan-alignment](review-plan-alignment/SKILL.md) | Revisar aderência entre decisões, specs e tarefas, sem replanejar ou implementar. |
| [review-code-diff](review-code-diff/SKILL.md) | Revisar commits e diffs, atribuir falhas e conferir evidências e gates. |
| [coordinate-dispatch](coordinate-dispatch/SKILL.md) | Selecionar e delegar tarefas elegíveis, com capacidade e escopos compatíveis. |
| [coordinate-delivery](coordinate-delivery/SKILL.md) | Conduzir aceite, revisão independente, integração e commit da entrega. |
| [coordinate-blockers](coordinate-blockers/SKILL.md) | Interromper, encaminhar impedimentos ao planejador e retomar com evidências. |
| [scope-mvp](scope-mvp/SKILL.md) | Delimitar o produto mínimo e retirar dependências de capacidades futuras. |
| [reconcile-plan](reconcile-plan/SKILL.md) | Incorporar decisões, entregas e reviews sem duplicar contexto entre documentos. |
| [plan-unblocking](plan-unblocking/SKILL.md) | Planejar uma correção e sua condição de retomada a partir de um impedimento. |
| [specify-feature](specify-feature/SKILL.md) | Converter requisitos em regras e cenários, sem implementar. |
| [plan-task-graph](plan-task-graph/SKILL.md) | Decompor uma spec em entregas sem duplicação e dependências explícitas. |

Os arquivos em `docs/skills` são a fonte única. Um agente pode ler o `SKILL.md` pelo caminho e seguir o procedimento mesmo sem suporte nativo a skills. O índice do `AGENTS.md` encaminha a leitura apenas quando pertinente.

Para descoberta automática do Codex, os diretórios de skills são vinculados em `.agents/skills/`, apontando para esta pasta. Outros agentes podem exigir configuração própria; não presumir descoberta automática de `docs/skills` ou de links simbólicos. Caso um host não descubra a skill, indicar diretamente o caminho canônico deste índice.

Uma skill orienta o trabalho; não confirma decisões de produto nem autoriza iniciar tarefas bloqueadas. Não duplicar o guia de specs ou o formato das tarefas dentro dela.

Referência oficial consultada em 22/09/2026: [descoberta local e links simbólicos no Codex](https://learn.chatgpt.com/docs/build-skills#where-codex-loads-local-skills).
