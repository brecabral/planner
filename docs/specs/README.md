# Especificações da solução

Cada spec agrega uma capacidade da solução: fronteiras arquiteturais, invariantes, diferentes casos de uso e decisões pendentes. Uma spec é implementada por várias tarefas pequenas, sem criar uma spec por passo técnico. Leia somente a spec pertinente; o status no cabeçalho determina sua prontidão.

| Spec | Assunto |
| --- | --- |
| [001 — Idiomas da interface](001-idiomas.md) | Seleção, persistência e fallback do idioma. |
| [002 — Backlog, retry e três escolhas diárias](002-planejamento-diario.md) | Cadastro, estados, seleção, devolução e cota. |
| [003 — Dia do usuário, retry e histórico](003-dia-e-historico.md) | Fuso individual, virada e conclusão. |
| [004 — Experiência do painel](004-experiencia-e-acesso.md) | Listas, formulários, erros e acessibilidade. |
| [005 — Contas e isolamento de dados](005-contas-e-acesso.md) | Identidade, sessão e autorização. |
| [006 — Labels reutilizáveis por usuário](006-labels.md) | Catálogo privado e associação de várias labels. |

## Como escrever

Usar [o modelo](modelo.md). Registrar origem (RF/CA ou decisão), atores, entradas, regras numeradas, estados/transições quando existirem e exemplos Dado/Quando/Então. Incluir falhas e concorrência somente quando relevantes. Explicitar escopo excluído, efeitos sobre dados e perguntas bloqueantes. Separar regra confirmada de proposta.

Status permitido no cabeçalho: `draft` (rascunho), `ready` (sem dúvidas bloqueantes e decisões confirmadas), `implemented` (aceite verificado no código integrado), `superseded` (substituída, com link para sucessora). Um rascunho não autoriza implementar escolhas pendentes.

Uma spec está pronta quando outro agente consegue decidir o resultado dos cenários sem inventar comportamento. Uma decisão técnica pode ficar aberta se não mudar o contrato e estiver dentro do escopo de implementação. Não prescrever cada linha de código.

## Evolução

Propostas pequenas começam como specs `draft`; não criar RFC, proposta e spec duplicadas. Atualizar a spec quando o comportamento mudar; manter justificativas relevantes em design. Ao decompor, atribuir cada entrega a uma tarefa e apontar as regras que ela cobre. Correções pequenas podem usar diretamente uma tarefa se o comportamento já estiver especificado.

Consulta assistida: [skill de especificação](../skills/specify-feature/SKILL.md).
