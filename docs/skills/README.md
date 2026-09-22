# Habilidades do projeto

| Skill | Quando carregar |
| --- | --- |
| [specify-feature](specify-feature/SKILL.md) | Converter requisitos em regras e cenários, sem implementar. |
| [plan-task-graph](plan-task-graph/SKILL.md) | Decompor uma spec em entregas sem duplicação e dependências explícitas. |

Os arquivos em `docs/skills` são a fonte única. Um agente pode ler o `SKILL.md` pelo caminho e seguir o procedimento mesmo sem suporte nativo a skills. O índice do `AGENTS.md` encaminha a leitura apenas quando pertinente.

Para descoberta automática do Codex, os diretórios de skills são vinculados em `.agents/skills/`, apontando para esta pasta. Outros agentes podem exigir configuração própria; não presumir descoberta automática de `docs/skills` ou de links simbólicos. Caso um host não descubra a skill, indicar diretamente o caminho canônico deste índice.

Uma skill orienta o trabalho; não confirma decisões de produto nem autoriza iniciar tarefas bloqueadas. Não duplicar o guia de specs ou o formato das tarefas dentro dela.

Referência oficial consultada em 22/09/2026: [descoberta local e links simbólicos no Codex](https://learn.chatgpt.com/docs/build-skills#where-codex-loads-local-skills).
