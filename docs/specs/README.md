# Especificações do MVP

Specs agregam arquitetura, invariantes e casos de uso; tarefas entregam passos pequenos. As seis specs abaixo descrevem o MVP definido, sem decisões de login, idioma alternativo, fuso ou atualização automática. Evoluções estão separadas no índice de tarefas e exigem revisão de contrato antes da execução.

| Spec | Capacidade |
| --- | --- |
| [001 — Interface pt-BR com Gettext](001-idiomas.md) | Contrato do MVP; implementação em várias tarefas. |
| [002 — Backlog, retry e três escolhas diárias](002-planejamento-diario.md) | Contrato do MVP; implementação em várias tarefas. |
| [003 — Data corrente, retry e histórico](003-dia-e-historico.md) | Contrato do MVP; implementação em várias tarefas. |
| [004 — Experiência do painel](004-experiencia-e-acesso.md) | Contrato do MVP; implementação em várias tarefas. |
| [005 — Usuário padrão do MVP](005-contas-e-acesso.md) | Contrato do MVP; implementação em várias tarefas. |
| [006 — Labels reutilizáveis por usuário](006-labels.md) | Contrato do MVP; implementação em várias tarefas. |

## Como escrever

Usar [o modelo](modelo.md). Registrar origem (RF/CA ou decisão), atores, entradas, regras numeradas, estados/transições quando existirem e exemplos Dado/Quando/Então. Incluir falhas e concorrência somente quando relevantes. Explicitar escopo excluído, efeitos sobre dados e perguntas bloqueantes. Separar regra confirmada de proposta.

Status permitido no cabeçalho: `draft` (rascunho), `ready` (sem dúvidas bloqueantes e decisões confirmadas), `implemented` (aceite verificado no código integrado), `superseded` (substituída, com link para sucessora). Um rascunho não autoriza implementar escolhas pendentes.

Uma spec está pronta quando outro agente consegue decidir o resultado dos cenários sem inventar comportamento. Uma decisão técnica pode ficar aberta se não mudar o contrato e estiver dentro do escopo de implementação. Não prescrever cada linha de código.

## Evolução

Propostas pequenas começam como specs `draft`; não criar RFC, proposta e spec duplicadas. Atualizar a spec quando o comportamento mudar; manter justificativas relevantes em design. Ao decompor, atribuir cada entrega a uma tarefa e apontar as regras que ela cobre. Correções pequenas podem usar diretamente uma tarefa se o comportamento já estiver especificado.

Consulta assistida: [skill de especificação](../skills/specify-feature/SKILL.md).
