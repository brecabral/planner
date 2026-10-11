---
id: "TASK-039"
status: done
execution_level: advanced
execution_rationale: "Renovação autorizada integra rotas, ciclo de vida de LiveComponent, diálogo modal e feedback sem alterar o domínio."
specs: ["SPEC-001", "SPEC-004", "SPEC-006"]
depends_on: ["TASK-038"]
provides: ["planner-renewed-interface"]
consumes: ["task-registration-failure-feedback", "accessible-planner-ui"]
write_scope: ["assets/css/", "assets/js/", "lib/planner_web/", "priv/gettext/", "test/planner_web/", "docs/specs/004-experiencia-e-acesso.md", "docs/design.md", "docs/prd.md", "docs/referencias/", "docs/tasks/"]
blockers: []
---

# 039 — Renovar a experiência do Planner

## Origem e contrato

Execução direta do plano “Renovação da experiência do Planner” aprovado pelo usuário em 09/10/2026. Base local limpa `43ea80314c0a47a2a8357c17064cc01ac9ed5a40`; TASK-038 e entregas do MVP integradas. Sem dependência humana incompleta para esta implementação. Não reabrir o aceite histórico do MVP.

Aceites: [SPEC-004 RN07–RN13 e CA-004-07–CA-004-10](../specs/004-experiencia-e-acesso.md#evolução-da-experiência--09102026), preservando CA-004-01–CA-004-06. Reaproveitar Index/Form e daisyUI existente; sem scaffold, migração, dependência ou alteração do domínio. Paletas configuráveis, tema escuro, login, arrastar e sincronização automática ficam fora.

## Implementação

Tema semântico claro, home Planner, painel responsivo com hoje em destaque, histórico recolhido e ações agrupadas. Cadastro por patch em diálogo nativo sobre Index; Form convertido em LiveComponent, checkboxes de labels e expansão por erro. Preservados os tratamentos de validação, rollback e falha de persistência. Hook controla modalidade, Escape, foco e estado nativo `open` durante patches; streams não têm animação de entrada. Feedback de sucesso decorre de retorno confirmado do servidor.

## Evidências automatizadas e autoavaliação

Primeira execução de intenção: 30/32 testes passaram, com as duas falhas esperadas de identidade Phoenix e ausência de expansão de histórico. Testes de cadastro adaptados de redirect para patch e de select múltiplo para checkboxes, preservando falhas reais de constraint, PostgreSQL e conexão.

### Resultado final — 09/10/2026

Autoavaliação pelo implementador `/root`, conforme [fluxo de review](../fluxos/review.md), sobre o diff local desta tarefa contra `43ea80314c0a47a2a8357c17064cc01ac9ed5a40`. Não constitui revisão independente e não altera o marco histórico.

| Critério | Evidência |
| --- | --- |
| CA-004-07 | Testes de home verificam identidade Planner, botão para `/tasks`, pt-BR, tema `planner`, ausência de links promocionais e controles de tema; avisos de reconexão preservados. |
| CA-004-08 | LiveViewTest abre pelo botão e URL direta, conserva planejamento na composição, fecha/cancela por patch sem cadastrar, reabre vazio e preserva expansão do histórico. |
| CA-004-09 | Testes de múltiplas labels, campos inválidos, IDs alheios e três falhas reais de persistência mantidos. Verificados expansão estrutural por erro, preservação de rascunho em atualização do pai e reenvio sem duplicação após falha. |
| CA-004-10 e aceites anteriores | Testes existentes de cota esgotada, conclusão sem restituição, devolução, reordenação, conflito, falhas e remontagem aprovados. Conclusão verifica anúncio traduzido e histórico ainda oculto; erro não cria anúncio de sucesso. |
| RN07–RN13 | Inspeção de CSS, templates, hook e rotas: tokens semânticos, layout responsivo, diálogo nativo, preservação de `open`, sem animação nos itens de stream e sem alteração de domínio/migrações. Não substitui inspeção humana em navegador. |

Na autoavaliação, um teste adicional reproduziu encerramento do formulário para `label_ids` malformado na adaptação dos checkboxes. Corrigido na fronteira da apresentação: somente a lista perde o sentinela vazio do HTML; formas inválidas chegam intactas ao domínio para rejeição, e somente IDs simples são usados na marcação da seleção. Teste passa para string, mapa e lista com mapa, preservando título/novas labels sem gravação. Credo inicialmente apontou complexidade no feedback; extração das mensagens de sucesso resolveu o achado.

Gates finais:

- `rtk mix precommit`: **142 testes aprovados**, compilação sem warnings e formatação aprovadas.
- `rtk mix ci`: **142 testes aprovados**, Credo estrito sem achados, cobertura total **92,61%**, Form **97,26%**, Index **98,04%**, Tasks **98,31%**; limiar de 70% preservado. Referência histórica do MVP: 92,25% total.
- `rtk mix assets.build`: compilação Tailwind 4.3.0/daisyUI 5.5.20 e esbuild aprovadas.
- Extração/merge Gettext pt_BR: mensagens traduzidas, sem fuzzy ou traduções simples vazias.
- `rtk git diff --check`: aprovado.

Conclusão: **approved como autoavaliação** dos critérios automatizados, sem achados bloqueantes remanescentes. Cobertura é de linhas Elixir; não mede o hook nem experiência assistiva. A entrega permanece em `in_review`, disponível na árvore local para conferência operacional e integração; nenhum commit ou publicação foi efetuado nesta execução.

## Reconciliação do aceite — 09/10/2026

Por decisão explícita do responsável, CA-004-11 foi cancelado, e foco/teclado, contraste, layout e questões estéticas foram retirados dos requisitos. Não existe avaliação humana obrigatória nem pendência de interface nesta tarefa. Feedback poderá ser apresentado espontaneamente pelo responsável, conforme o [PRD](../prd.md#feedback-de-interface).

Esta reconciliação altera somente o contrato documental; preserva implementação e evidências acima. Não presume avaliação executada, integração ou conclusão da tarefa. Status, dependências e gates automatizados permanecem inalterados; não há novas tarefas ou consumidoras afetadas.

Sem publicação remota, CI remoto ou revisão independente nesta entrega.

## Revisão independente — 10/10/2026

Revisor `/root`, árvore local sobre `43ea80314c0a47a2a8357c17064cc01ac9ed5a40`. Sem achado bloqueante identificado no escopo automatizado e inspecionado. Ainda falta conferência operacional e integração; status `in_review` preservado. Gate reproduzido: `rtk mix ci`, 157 testes, cobertura 93,44%, Credo/build/npm audit aprovados. JavaScript inspecionado, sem navegador. Evidências, limites e achado em [docs/review.md](../review.md#revisão-das-entregas-locais--10102026). Nenhum código corrigido ou commit criado.

## Conferência operacional e integração — 10/10/2026

Conferência superficial por `/root`, para liberar a correção autorizada da TASK-040. Entrega presente na base local pelo commit `8f1402a` (snapshot anterior à correção), incluindo interface, testes e documentação. Conferidos os registros de autoavaliação e gates relatados aprovados e a revisão de 10/10 sem achado bloqueante atribuído à TASK-039. Sem pré-requisito humano ou impedimento aberto desta entrega. Não foram reproduzidos testes nesta conferência nem realizada nova revisão independente. O commit existente foi preservado, sem reescrita para separar as entregas. TASK-039 concluída operacionalmente; dependência da TASK-040 liberada. Sem publicação remota.
