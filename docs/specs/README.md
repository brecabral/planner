# Especificações do Planner

Specs agregam arquitetura, invariantes e casos de uso; tarefas entregam passos pequenos. O MVP local foi entregue; o plano de produção amplia planejamento/interface e substitui o acesso compartilhado por contas. Os cabeçalhos indicam prontidão do contrato, não conclusão da implementação.

| Spec | Capacidade |
| --- | --- |
| [001 — Idiomas da interface com Gettext](001-idiomas.md) | Contrato do MVP; implementação em várias tarefas. |
| [002 — Backlog, retry e três escolhas diárias](002-planejamento-diario.md) | Contrato do MVP; implementação em várias tarefas. |
| [003 — Data corrente, retry e histórico](003-dia-e-historico.md) | Contrato do MVP; implementação em várias tarefas. |
| [004 — Experiência do painel](004-experiencia-e-acesso.md) | Contrato do MVP; implementação em várias tarefas. |
| [005 — Contas, magic link e isolamento](005-contas-e-acesso.md) | Contrato do MVP; implementação em várias tarefas. |
| [006 — Labels reutilizáveis por usuário](006-labels.md) | Contrato do MVP; implementação em várias tarefas. |

As versões do MVP local dessas seis specs foram implementadas no código integrado e tiveram aceite verificado pela revalidação independente do MVP (histórico em `4ed2a47:docs/review.md`, seção `revalidação-de-prontidão-do-mvp--05102026`), alvo `2b8ba19`, em 05/10/2026. Não há avaliação humana obrigatória da interface, conforme o [PRD](../prd.md#feedback-de-interface).

## Como escrever

Usar [o modelo](modelo.md). Registrar origem (RF/CA ou decisão), atores, entradas, regras numeradas, estados/transições quando existirem e exemplos Dado/Quando/Então. Incluir falhas e concorrência somente quando relevantes. Explicitar escopo excluído, efeitos sobre dados e perguntas bloqueantes. Separar regra confirmada de proposta.

Status permitido no cabeçalho: `draft` (rascunho), `ready` (sem dúvidas bloqueantes e decisões confirmadas), `implemented` (aceite verificado no código integrado), `superseded` (substituída, com link para sucessora). Um rascunho não autoriza implementar escolhas pendentes.

Uma spec está pronta quando outro agente consegue decidir o resultado dos cenários sem inventar comportamento. Uma decisão técnica pode ficar aberta se não mudar o contrato e estiver dentro do escopo de implementação. Não prescrever cada linha de código.

## Evolução

Propostas pequenas começam como specs `draft`; não criar RFC, proposta e spec duplicadas. Atualizar a spec quando o comportamento mudar; manter justificativas relevantes em design. Ao decompor, atribuir cada entrega a uma tarefa e apontar as regras que ela cobre. Correções pequenas podem usar diretamente uma tarefa se o comportamento já estiver especificado.

Consulta assistida: [skill de especificação](../skills/specify-feature/SKILL.md).

Arraste integrado na [TASK-040](../tasks/040-arrastar-tarefas.md), com aceite local confirmado em 11/10/2026. Os incrementos de produção nas SPEC-002/004/005/007 ainda exigem suas próprias entregas e evidências.

## Contratos do MVP de produção

| Spec | Escopo e prontidão |
| --- | --- |
| [002 — Planejamento](002-planejamento-diario.md) | Ready: retry → backlog e exclusão de pendências; TASK-042/043. |
| [004 — Painel](004-experiencia-e-acesso.md) | Ready: menu à esquerda e novas ações; TASK-041/042/044. |
| [005 — Contas](005-contas-e-acesso.md) | Ready: cadastro aberto, magic link, isolamento e dev; TASK-015/045/046/051. Página `/join` integrada na TASK-052. |
| [007 — Temas](007-temas-e-creditos.md) | Ready: dois temas gratuitos, concessão e preferência por usuário; TASK-047/048. |
| [008 — Código Phoenix e release local](008-producao.md) | Ready: empacotamento e aceite local; incremento Resend na TASK-060, sem envio externo no aceite. Infraestrutura e operação dos serviços sob responsabilidade do usuário. |
| [009 — Créditos e compras](009-creditos-e-compras.md) | Draft: evolução futura; não bloqueia o MVP de produção. |

As versões históricas citadas nos aceites de 05/10 não atestam login, temas ou operações novas. SPEC-003 preserva data UTC/histórico; SPEC-006 preserva classificação, com novo proprietário autenticado integrado pela TASK-045.

Correções solicitadas em 14/10/2026: SPEC-005 RN20/CA-005-18 define destaque do cadastro no login ([TASK-053](../tasks/053-destacar-criar-conta-login.md)); SPEC-007 RN07–RN08/CA-007-05–07 define seletor na navbar e regressão visual ([TASK-054](../tasks/054-corrigir-temas-na-navbar.md)). Implementações integradas; evidências nas tarefas. A reprodução visual original da TASK-054 permanece não verificada; cobertura autenticada de paletas está planejada na TASK-056.


Identidade de 17/10/2026: SPEC-004 RN21–RN24/CA-004-17–18 e SPEC-007 RN09–RN10/CA-007-08 definem Just Three e controles por ícone. Contratos ready, entrega planejada na [TASK-059](../tasks/059-identidade-just-three.md). SPEC-004 RN25/CA-004-19 incorpora a tradução aprovada “A fazer” ao aceite da TASK-059.


SPEC-001: pt-BR fixo permanece entrega histórica; evolução de 17/10/2026 ready para tradução completa e engrenagem de idioma. Português/inglês, seleção pública no navegador e preferência por conta confirmados, com troca disponível durante o uso. TASK-013/014 aguardam somente integração das dependências. “A fazer” já está aprovado na TASK-059.
