---
review_base_commit: "03e8d31d7990af6575ed2011651c9cd1b4350c4e"
reviewed_commit: "e4875169d2823b9e60f64cb4251d0ef2e33f1c35"
last_approved_commit: "e4875169d2823b9e60f64cb4251d0ef2e33f1c35"
reviewed_at: "2026-09-25"
reviewer: "Codex /root — perfil revisor, independente das implementações"
status: approved
reviewed_tasks: ["TASK-001", "TASK-002", "TASK-009", "TASK-010", "TASK-016", "TASK-036"]
---

# Revisão incremental das tarefas concluídas

Resultado: **approved**, sem achados bloqueantes nas entregas indicadas. O marco acima permite retomar a revisão incremental conforme o [fluxo de review](fluxos/review.md#marco-persistente-de-revisão); não constitui aprovação de todo o planejamento ou do MVP completo.

## Base, alvo e escopo

O histórico de `docs/review.md` identifica `03e8d31` como o último commit que esvaziou o arquivo, removendo suas 105 linhas. Esse commit é a base solicitada, não uma aprovação anterior: o relatório removido tratava do planejamento e tinha resultado `changes_requested`.

Revisado o intervalo `03e8d31..e487516`, concentrado nas seis tarefas de implementação concluídas desde a base, seus testes, contratos e dependências. TASK-002 teve sua remoção implementada antes da base, em `f757265`, mas seu aceite ocorreu no intervalo: conferidos o estado resultante, referências residuais, teste de rotas e evidências de aceite. TASK-003 e TASK-012 já possuíam aceite humano; apenas seus registros foram consultados, sem executar novamente suas ações. A confirmação “o db esta limpo” está registrada na TASK-012.

O código executável local coincide com o alvo commitado. Quatro arquivos já estavam modificados antes desta revisão: `docs/blocks/001-cobertura-apos-remocao-crud.md`, `docs/blocks/README.md`, `docs/tasks/002-remover-crud-experimental.md` e `docs/tasks/README.md`. Foram preservados; suas alterações não integram a aprovação do SHA. Os registros históricos de bloqueio/autoavaliação foram distinguidos dos aceites posteriores. Alterações de workflows/skills no intervalo não são objeto desta revisão das entregas e não recebem aprovação implícita pelo marco.

## Critérios e evidências

| Tarefa | Conferência | Resultado |
| --- | --- | --- |
| TASK-036 | Testes verificam campos, valores, erros, escape de HTML, flash, links, temas e reconexão; asserções observáveis, sem mudança do limiar ou exclusões de cobertura. | Aprovada. |
| TASK-002 | Oito rotas experimentais ausentes; GET `/` preservado; módulos, fixture e migration experimentais ausentes, sem referências de produção. Preparação de base nova e ausência de reset na entrega original têm evidências históricas na tarefa. | Aprovada; nenhum reset executado nesta revisão. |
| TASK-001 | Locale fixo HTTP/LiveView, HTML pt-BR, conteúdo informado preservado, página base traduzida, plurais e nomes acessíveis; catálogos default/errors sem mensagens vazias ou fuzzy, exceto cabeçalhos convencionais. Controles, URLs e nomes próprios preservados. | Aprovada segundo SPEC-001 e decisão do BLOCK-002. |
| TASK-009 | Seeds reais repetidos com e sem usuário prévio preservam identidade, timestamps e outras identidades; consulta não cria usuário; fixtures isoladas; índice único e conflito ignorado sustentam idempotência. | Aprovada no escopo produtor de default-user. |
| TASK-016 | Date UTC por padrão e data explícita para testes; chamadas independentes, sem estado global. | Aprovada no escopo produtor de current-day. |
| TASK-010 | Trim e rejeição de nome vazio; proprietário fora do cast; consultas filtradas, IDs alheios/inexistentes rejeitados; FK; rollback externo remove nova label e preserva anteriores; nomes iguais não são fundidos. | Aprovada no escopo produtor de user-label-catalog. |

Dependências das entregas estão integradas no alvo. As evidências individuais anteriores permanecem nos arquivos das tarefas; esta rodada registra aqui a revisão conjunta solicitada, sem reescrever estados ou evidências históricas.

## Verificações reproduzidas

- Ajuda de `ci` e `precommit` consultada; aliases inspecionados em `mix.exs`.
- `rtk mix ci`: saída 0; compilação com warnings como erros, formatação e Credo estrito aprovados; **39 testes aprovados, 82,65% de cobertura total**, mínimo de 70% preservado.
- Cobertura de linhas via Mix/ExUnit: Accounts, User, Day e Label 100%; Labels 75%; CoreComponents 82,11%; Layouts 100%. Não foi medida novamente a base, portanto não se afirma variação de cobertura nesta rodada.
- Inspeção dos catálogos, migrations, seeds, APIs e testes; busca de referências ao CRUD encontrou apenas o teste negativo de rotas e link documental.
- `rtk mix precommit`: saída 0, 39 testes aprovados; não deixou alterações em código ou lockfile.
- `rtk git diff --check`: aprovado também após as alterações documentais; ancestralidade da base em relação ao alvo confirmada.

## Limites e observações

Nenhum defeito acionável encontrado no escopo revisado. Os testes cobrem HTTP, processos LiveView, renderização e transações; não exercitam JavaScript em navegador, queda física de rede ou criação simultânea do usuário em conexões independentes. PageHTML registra 0% na instrumentação apesar de testes HTTP e de renderização direta; a métrica não substitui suas asserções.

Painel, cadastro integrado tarefa-label e captura de uma data única por operação pertencem às consumidoras futuras. O rollback atual comprova composição com Repo, sem antecipar esse cadastro. Não foram repetidos resets humanos nem a preparação histórica da TASK-002. Aprovação técnica não autoriza publicação remota.

A regra de marco persistente adicionada ao fluxo nesta rodada é uma alteração documental local, fora do SHA aprovado. Sua autoavaliação por cenários confirma: aprovação avança; bloqueio/reprovação preservam; divergência local não aprova HEAD; ancestralidade inválida exige reconstrução; escopo excluído não é pulado.
