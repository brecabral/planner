---
id: "TASK-047"
status: "done"
execution_level: "advanced"
execution_rationale: "Modela propriedade única, preparação de contas existentes/futuras e preferência autorizada transacional."
specs: ["SPEC-007", "SPEC-005"]
depends_on: ["TASK-046"]
provides: ["user-theme-entitlements"]
consumes: ["local-magic-link-testing"]
write_scope: ["lib/planner/themes.ex", "lib/planner/themes/", "lib/planner/accounts.ex", "lib/planner/accounts/user.ex", "priv/repo/migrations/", "priv/repo/seeds.exs", "test/planner/", "test/support/", "docs/tasks/047-catalogo-concessoes-temas.md"]
blockers: []
---

# 047 — Criar catálogo, concessões e preferência de temas

## Objetivo e entradas

Implementar SPEC-007 RN01–RN03/RN06 e CA-007-01/03. Ler design D19, Accounts/cadastro autenticado, referências Ecto/Elixir/testes. Recurso novo: contexto pequeno Themes com catálogo/concessões e referência de preferência no usuário; usar migration aditiva, sem gerar CRUD ou interfaces de loja. Nenhum gerador de domínio específico é necessário; não duplicar Accounts/User.

## Aceite e testes

1. Catálogo contém códigos estáveis planner/planner_dark. Contas existentes e futuras recebem ambos com origem gratuita e unicidade usuário/tema; repetir preparação e tentativas concorrentes não duplicam.
2. Preferência inicial é planner; operação autenticada só aceita tema concedido e proprietário do servidor. Tema desconhecido/não concedido e user_id forjado não alteram preferência nem propriedade.
3. Falha transacional não deixa cadastro/concessão/preferência parcial. Migration/backfill preserva contas e dados legados; legado permanece sem login. Testar bases novas e com contas já criadas.
4. Não introduzir carteira, saldo, preços, endpoint de compra ou código de pagamentos. A relação de concessão é a base suficiente para propriedade futura. Integração CSS/seletor é exclusiva da TASK-048.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.


## Entrega e evidências — 13/10/2026

- Implementador: agente `implement_047`, capacidade advanced. Base integrada: `47a10ee02bc61aeba9c31ab763a203f33dfb6eb6`; TASK-046 concluída, specs prontas e nenhum impedimento aplicável. Execução passou por `in_progress` e está em `in_review`, aguardando conferência operacional e commit do coordenador.
- Aceite 1 / CA-007-01: migration aditiva cria catálogo `themes` com `planner`/`planner_dark`, `theme_entitlements` com origem e índice único usuário/tema, e referência `users.theme_code`. Backfill concede ambos somente às contas com e-mail. `Themes.prepare_user/1` serializa preparação pelo lock da conta, preserva seleção e usa conflito idempotente. Testes `themes_test.exs` e `themes_storage_test.exs` comprovam repetição, origem gratuita, unicidade SQL e concorrência efetiva entre conexões distintas com espera de lock PostgreSQL.
- Aceite 2 / CA-007-03: `Themes.list_available_themes/1` recebe Scope; `Themes.select_theme/2` recebe Scope do servidor e exatamente `%{"theme_code" => code}`. Retorna `{:ok, user}` ou `{:error, :invalid_selection | :unavailable_theme | :unauthenticated | :persistence_failed}`. Parâmetros extras, inclusive `user_id` string/átomo, são rejeitados. Preferência inicial `planner`; cadastro não aceita preferência/origem/proprietário do payload. Testes cobrem outra conta intacta, código desconhecido, tema não concedido, ausência de autenticação e scope de conta removida. Erro SQL de seleção retorna `:persistence_failed` após rollback; integração visual e mensagem ao usuário pertencem à TASK-048.
- Aceite 3: cadastro engloba conta e concessões na mesma transação. `themes_storage_test.exs` aplica migrations em schema isolado, parte de base anterior com legado e conta real, verifica preservação dos campos anteriores e prepara cadastro novo. Falhas SQL injetadas por triggers verificam rollback de cadastro, concessões e seleção, com estado persistido confirmado após falha. Preparação/cadastro propagam exceções SQL após rollback; a seleção traduz Postgrex.Error em erro de persistência. O teste de migration de autenticação passou a aplicar migrations posteriores antes de chamar o Accounts atual; as verificações originais de preservação de tarefas, labels, vínculos e cota continuam passando. Legado mantém e-mail nulo, sem concessões ou autenticação criada.
- Aceite 4: inspeção do diff confirma contexto pequeno de temas e referência na identidade existente, sem CSS, seletor, carteira, preços, créditos, loja ou pagamentos. Seeds permanecem sem criar contas; migrations/cadastro cobrem contas existentes/futuras.

### Validação e autoavaliação

- TDD: migration foi completada antes de ser aplicada; testes de intenção falharam inicialmente pela ausência do campo/APIs. Após corrigir a fixture para conta real, fase vermelha confirmada novamente. Implementação levou os cinco primeiros cenários a verde. Teste de falha SQL na seleção também falhou antes da tradução para `:persistence_failed` e passou após implementação.
- Testes direcionados de domínio/migrations: sete cenários verdes na execução inicial; posteriormente adicionados conta removida e tentativa de forjar cadastro. Suite final: **235 testes, zero falhas**.
- `mix precommit` final: aprovado, seed `728705`; compilação, dependências, formatação e testes.
- `mix ci` final: aprovado, seed `953588`; Credo estrito sem achados, 235 testes, cobertura total **93,93%** (mínimo 70% preservado), `Planner.Themes` e schemas **100%**, Accounts **89,74%**, User **92,86%**; assets compilados e auditoria npm sem vulnerabilidades. A primeira execução do CI identificou apenas ajustes locais de Credo, corrigidos antes dos gates finais.
- Limitação observada: uma execução intermediária de precommit (seed `638548`) teve 234/235 testes verdes; `TasksTest` em `test/planner/tasks_test.exs:125` comparou structs completas e falhou apenas por `updated_at` atravessar um segundo (`12:07:51` → `12:07:52`) em cenário preexistente e fora desta entrega. Não alterado fora do escopo. Repetição seed `347582`, precommit final e CI final passaram. A ocorrência foi preservada como evidência de instabilidade, sem afirmar sua correção.
- Autoavaliação pelo fluxo de review: alvo são as alterações locais desta tarefa sobre a base acima, incluindo arquivos novos Themes, migration e testes. Critérios 1–4 atendidos; sem achados bloqueantes identificados. Não constitui revisão independente nem avança seu marco. Testes medem domínio/PostgreSQL e assets existentes, não UX do seletor, navegador ou deploy. Commit/integração ainda a cargo do coordenador; nenhuma consumidora iniciada pelo implementador.

### Conferência operacional — 13/10/2026

Coordenador `/root`: entrega integrada em `839951e` na branch `feat/ux`. Conferidos escopo, autoavaliação, gates finais relatados aprovados (235 testes e cobertura 93,93%) e ausência de impedimentos. Instabilidade intermediária preexistente preservada no registro, sem alegar correção. Sem reprodução de testes ou revisão independente. Conclusão operacional libera TASK-048.

### Revisão independente — 13/10/2026

Revisor `/root`, alvo `b0810ba49cf6049c7d5aac49960950a5236be22b`, base reconstruída `367bf3555bc2b06e5ce90aedc2118e46e00986de`. Sem achado bloqueante identificado no contrato desta entrega. Parecer global changes_requested por R3 no cadastro de contas. `mix ci`: 240 testes aprovados, cobertura 94,08%; testes JavaScript de arraste/tema: 9 aprovados. Escopo, reprodução adicional com falha, achados documentais e limites em docs/review.md (histórico em `4ed2a47:docs/review.md`, seção `revisão-das-últimas-entregas-e-documentação--13102026`). Sem correção de produto ou mudança do estado operacional nesta revisão.
