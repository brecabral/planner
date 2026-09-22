# Especificações da solução

Specs transformam requisitos do PRD em comportamento verificável. São contratos duráveis do produto; tarefas descrevem as mudanças necessárias para entregá-los. Referências ensinam a usar tecnologias e não substituem regras de negócio.

| Spec | Assunto |
| --- | --- |
| [001 — Idiomas](001-idiomas.md) | Comportamento de seleção e persistência; ainda há decisões propostas. |

O planejamento diário ainda depende das respostas do PRD §12. Não criar sua modelagem definitiva antes dessas respostas.

## Como escrever

Usar [o modelo](modelo.md). Registrar origem (RF/CA ou decisão), atores, entradas, regras numeradas, estados/transições quando existirem e exemplos Dado/Quando/Então. Incluir falhas e concorrência somente quando relevantes. Explicitar escopo excluído, efeitos sobre dados e perguntas bloqueantes. Separar regra confirmada de proposta.

Status permitido no cabeçalho: `draft` (rascunho), `ready` (sem dúvidas bloqueantes e decisões confirmadas), `implemented` (aceite verificado no código integrado), `superseded` (substituída, com link para sucessora). Um rascunho não autoriza implementar escolhas pendentes.

Uma spec está pronta quando outro agente consegue decidir o resultado dos cenários sem inventar comportamento. Uma decisão técnica pode ficar aberta se não mudar o contrato e estiver dentro do escopo de implementação. Não prescrever cada linha de código.

## Evolução

Propostas pequenas começam como specs `draft`; não criar RFC, proposta e spec duplicadas. Atualizar a spec quando o comportamento mudar; manter justificativas relevantes em design. Ao decompor, atribuir cada entrega a uma tarefa e apontar as regras que ela cobre. Correções pequenas podem usar diretamente uma tarefa se o comportamento já estiver especificado.

Consulta assistida: [skill de especificação](../skills/specify-feature/SKILL.md).
