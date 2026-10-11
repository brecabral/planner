# Retomada — TASK-040: arrastar tarefas

> **Atualização de 10/10/2026:** pausa encerrada a pedido do responsável. Implementação retomada usando SortableJS instalado via npm (1.15.7 no lockfile), corrigida e entregue em `in_review`. Precommit e CI aprovados: 157 testes e 93,44% de cobertura. Migração aplicada em desenvolvimento. Evidências atuais e limites na [TASK-040](tasks/040-arrastar-tarefas.md). O restante deste arquivo preserva o diagnóstico histórico de 09/10 e não representa pendências atuais; a previsão de vendor foi substituída pela instalação npm informada pelo usuário. Sem commit, integração ou revisão independente.

Registro de 09/10/2026. Trabalho interrompido a pedido do usuário para continuar em contexto novo. Este arquivo registra progresso e próximos passos; instruções operacionais gerais continuam no [README](../README.md).

## Pedido e decisão mais recente

Implementar o plano aprovado “Arrastar tarefas com mouse e touch”, por completo, preservando alterações locais anteriores. Depois o usuário esclareceu: **“nao precisa testar ui ou ux, apenas valide a implementacao e eu testo sozinho”**. Portanto, não instalar navegador, Playwright ou pedir avaliação humana como gate. Validar domínio, persistência, eventos LiveView, bundle e gates do repositório. Não afirmar que mouse/touch foram testados.

O último pedido foi somente registrar a retomada; não continuar implementação nesta sessão.

## Contrato autorizado

- Reordenar Hoje, Backlog e Retry com persistência após recarga.
- Transferir somente Backlog → Hoje, Retry → Hoje e Hoje → Backlog, na posição do drop.
- Entrar em Hoje consome escolha; devolver restitui; reordenar não afeta cota. Concluir não restitui.
- Menu transfere para o final; cadastro acrescenta ao final do Backlog. Concluir continua visível; selecionar/devolver/subir/descer ficam no menu, com ordenação nas três listas.
- Histórico somente consulta por conclusão; sem reabertura nem sincronização automática entre abas.
- SortableJS fixo em assets/vendor, importado pelo bundle existente. Alça, animação, indicação de destino, pressão touch de 200 ms, rolagem fora da alça e rolagem automática durante arraste; destinos vazios utilizáveis.
- Impedir transferências proibidas no cliente e revalidar no servidor. Um evento por drop com tarefa, origem, destino e ordens completas afetadas. Restaurar os mesmos nós DOM antes da atualização dos streams. Bloquear novos movimentos durante espera/desconexão; confirmar apenas após persistência; rejeição recompõe painel com erro pt-BR.
- Operação atômica sob lock por usuário: validar transição, conjuntos completos sem duplicatas, proprietário e cota. Rejeitar conjuntos antigos; no mesmo conjunto prevalece a última reordenação aceita.
- Position para todas as pendências, posições consecutivas/únicas por usuário/lista; compactar origem após transferência/conclusão. Cadastro serializado pelo mesmo lock. Virada acrescenta vencidas ao final de Retry, mantendo ordem existente e prioridade anterior das entrantes.
- Migration inicializa Backlog/Retry pela criação/ID, preserva Hoje e dados existentes. Manter reorder_today/3 compatível.

## Fontes para carregar

1. AGENTS.md e /home/mrrobot/.codex/RTK.md: todo comando shell usa prefixo rtk. Perfil atual é implementador; ler docs/fluxos/implementacao.md. Para autoavaliação, carregar docs/fluxos/review.md e skill pertinente quando aplicável.
2. [TASK-040](tasks/040-arrastar-tarefas.md), [SPEC-002](specs/002-planejamento-diario.md), [SPEC-003](specs/003-dia-e-historico.md), [SPEC-004](specs/004-experiencia-e-acesso.md), decisão D16 em [design](design.md).
3. Referências pertinentes em docs/referencias: Elixir, Ecto, Phoenix, LiveView, interop JS, HEEx, formulários, interface, Gettext, testes e Mix. Já consultadas nesta sessão; novo agente deve reler conforme a área.
4. README para operação e mix.exs/config/config.exs para gates/bundle.

Não spawnar subagentes: usuário não solicitou delegação. Não commitar/publicar sem necessidade/autorização pertinente. Preservar a árvore suja.

## Estado preexistente — preservar

A árvore já estava modificada antes da TASK-040 pela renovação da interface TASK-039. Ela está em in_review, sem commit/integracão afirmada. Os seguintes arquivos **já estavam alterados**, portanto o diff contra HEAD não representa somente o arraste:

- README.md; assets/css/app.css; assets/js/app.js.
- docs/blocks/004-validacao-navegador-acessibilidade.md; docs/design.md; docs/prd.md; docs/referencias/interface.md; docs/referencias/liveview-javascript.md; docs/specs/004-experiencia-e-acesso.md; docs/specs/README.md.
- docs/tasks/008-aceite-mvp.md, 032-acessibilidade-painel.md, 038-tratar-falha-cadastro.md, README.md e arquivo novo 039-renovar-experiencia.md.
- lib/planner_web/components/layouts.ex, layouts/root.html.heex, controllers/page_html/home.html.heex, live/task_live/form.ex, live/task_live/index.ex, router.ex.
- priv/gettext/default.pot e pt_BR/LC_MESSAGES/default.po.
- test/planner_web/controllers/page_controller_test.exs, page_html_test.exs, task_controller_test.exs; live/task_live_test.exs; locale_test.exs.

A interface atual usa TaskLive.Index, streams :today/:tasks (backlog)/:retry/:history e cadastro em LiveComponent com diálogo TaskDrawer. Não substituir nem desfazer a renovação.

## Alterações desta sessão

### Documentação

Specs 002/003/004 atualizadas antes do código, status ready para o incremento; índice mantém evidência histórica do MVP separada. D16 registra integração SortableJS e ordenação. TASK-040 criada em in_progress e incluída no índice. Skill specify-feature foi lida e usada para a etapa de planejamento, depois declarado perfil implementador.

Na pausa, SPEC-004 CA-004-13 e TASK-040 foram reconciliadas com a dispensa de testes UI/UX pelo agente.

### Migration completa, já aplicada em TEST

`priv/repo/migrations/20261009202516_order_pending_lists.exs` gerada pelo Mix e preenchida antes de testar:

- Backfill usando row_number por usuário/kind, ordenado por inserted_at/id, somente backlog/retry pendentes.
- Check tasks_pending_requires_position: pendência exige position.
- Índice único parcial tasks_pending_lists_position_unique em user_id/kind/position para backlog/retry pendentes.
- Preserva índice/checks prévios de Hoje. Down remove novas restrições e limpa posições backlog/retry pendentes.

A execução de testes aplicou a migration. Não tratar como scaffold ainda não aplicado; não alterar e reaplicar silenciosamente. Aplicação em DEV não foi feita/confirmada nesta sessão.

### Domínio parcialmente implementado

`lib/planner/tasks.ex`:

- reorder_today delega a reorder_list(user, kind, ids, date opcional).
- move_task(user, params, date opcional) aceita mapa com chaves string task_id/from/to/orders. Kinds aceitos sem String.to_atom. Valida tarefa, origem, transição e conjuntos finais exatos das listas afetadas sob UserTransaction.run.
- Transferências reutilizam select_task/return_task; resultado de erro causa rollback. Cota checada antes de entrar em Hoje. Persistência da ordem depois da transferência, sem estado parcial.
- Helpers pending_tasks/next_position/valid_order?; persist_order mantém estratégia de posições temporárias acima do máximo para evitar colisões de índice imediato.
- return_task atribui próxima posição Backlog; select_task compacta origem; compact_positions usa persist_order.
- Snapshot lê Backlog/Retry por position/id.
- create_task chama lock do usuário na transação existente e insere com próxima posição Backlog, mantendo labels/vínculos atômicos.

`lib/planner/user_transaction.ex`:

- lock/1 público reutilizado por run e cadastro (SELECT FOR UPDATE).
- Normalização acrescenta vencidas depois do máximo Retry, por scheduled_for/position/id; preserva datas e identidade.

**Regressão real pendente:** create_task com usuário sem ID ou inexistente agora lança exceção no lock, mas contrato/teste anterior exige {:error, changeset} com erro user_id. Corrigir preservando esse contrato e o lock para usuários válidos; não simplesmente mudar o teste para aceitar a exceção.

Código ainda não formatado/revisado pelo gate; avaliar complexidade/Credo e atomicidade. Possíveis otimizações não são requisito.

### Frontend ainda NÃO implementado nesta sessão

Nenhum hook de arraste, menu, evento move ou generalização de menu foi implementado. Index, app.js, CSS, Gettext e testes LiveView ainda têm apenas modificações preexistentes da TASK-039. Index atualmente trata reorder somente com today_ids e Tasks.reorder_today.

SortableJS ainda **não está disponível**: último ls de assets/vendor mostrou somente heroicons.js e topbar.js. Tentativa de download no sandbox falhou por rede; pedido escalado foi interrompido pelo usuário, sem arquivos presentes na conferência final.

## Dependência JS e conversa com o usuário

Explicado que Mix coordena esbuild/Tailwind, não instala npm; assets.setup instala executáveis e assets.build compila. Projeto não precisa Node/npm para arquivo vendorizado. Usuário pediu como instalar; foram indicados downloads de Sortable.min.js e LICENSE da tag oficial 1.15.6 para assets/vendor/sortable-1.15.6.js e assets/vendor/sortable-LICENSE. Verificar se o usuário os baixou antes de repetir qualquer download. Fonte oficial: https://github.com/SortableJS/Sortable/tree/1.15.6 . Não presumir instalação concluída.

O plano permanece usar arquivo vendorizado, sem introduzir package.json/npm desnecessariamente. Se precisar registrar comandos permanentes de instalação, fazê-lo no README, conforme regra do projeto.

## Evidências e falhas conhecidas

Novo arquivo `test/planner/task_movement_test.exs` tem somente **2 testes**, aprovados após implementação parcial:

1. Reordenar Backlog e cadastrar depois preserva ordem e acrescenta ao final.
2. Backlog → Hoje vazio, com cota/compactação, e retorno para início do Backlog.

Primeira execução com migration completa falhou porque cadastro antigo inseria position nil; foi incompatibilidade do comportamento antigo com a nova invariante. APIs move_task/reorder_list também ainda não existiam. Não alegar uma fase vermelha isolada apenas da movimentação.

Última execução concluída de TasksTest + TaskLiveTest: **73/81 passaram, 8 falharam**:

| Teste/linha aproximada | Falha | Próxima ação |
| --- | --- | --- |
| LiveView browser params cannot switch owner..., 858/883 | Espera position nil no cadastro | Atualizar para posição atribuída pelo servidor, mantendo teste de entrada forjada. |
| Tasks create ignores forged owner..., 897/915 | Espera position nil | Usar posição forjada distinta da posição legítima e provar que foi ignorada, inclusive no segundo cadastro. |
| Tasks stale command sees normalization..., 783/797 | Retry normalizado esperado com nil | Esperar posição 1 e manter verificação de rollback. |
| Tasks snapshot rolls expired..., 728/750 | Retry esperado com nil | Esperar posição 1 e preservar identidade/labels. |
| Tasks snapshot orders each..., 758/776 | Backlog esperado por criação e Retry por ID | Atualizar para posição persistida e prioridade anterior das vencidas; list_tasks continua por criação, não alterar esse contrato. |
| Tasks create distinct backlog..., 863/870 | Espera nil | Verificar posição inicial/final. |
| Tasks create rejects absent/nonexistent owners, 955/957 | Exceção no lock | Corrigir implementação, preservando retorno changeset. |
| Tasks return_to_backlog refunds..., 365/375 | Retorno esperado com nil | Verificar posição no final do Backlog e manter cota/idempotência. |

Testes existentes de concorrência em TasksTest usam conexões reais, worker com Task.Supervisor, Sandbox.unboxed_run e pg_blocking_pids. Reutilizar padrão; não sincronizar por sleep.

**Ainda não executados para esta entrega:** suíte total final, precommit, ci, cobertura, assets.build, extração/merge Gettext e autoavaliação final. Os 142 testes/92,61% documentados em TASK-039 pertencem à entrega anterior, não à TASK-040.

## Sequência para continuar

1. Conferir git status e arquivos acima; preservar todas as alterações anteriores. Verificar se o SortableJS já foi baixado. Não reiniciar do zero nem marcar TASK-039 concluída por inferência.
2. Corrigir regressão de proprietário no cadastro e atualizar expectativas que mudaram legitimamente com positions. Conferir assertions de posição nil em todos os testes: concluídas devem continuar sem posição; não fazer substituição global indiscriminada.
3. Completar testes de domínio: três listas; transferências início/meio/fim/vazio; menu no final; cota esgotada; destinos proibidos; IDs inválidos, alheios, duplicados ou incompletos; origem incorreta; conjuntos antigos; virada com Retry já ordenado; rollback real por constraint; cadastro/reordenação/movimento concorrentes e serialização da última ordem aceita. Verificar restrições da migration e preservação dos dados preexistentes com estratégia apropriada.
4. Finalizar domínio e executar testes focados até passarem, mantendo o limiar e contratos. Cadastro usa somente lock dentro de sua transação atual para não normalizar datas de fixtures por engano; reavaliar conscientemente se mudar essa escolha.
5. Integrar SortableJS em hook externo registrado no app.js, preservando TaskDrawer. Usar alças e metadados estáveis nos itens/listas. Configurar delay touch 200 ms, animação, auto-scroll, destinos vazios e transições permitidas. Snapshot dos nós antes do arraste; restaurar DOM original antes de pushEvent; servidor responde após persistência/refresh. Implementar estado pendente/desconectado e limpeza no destroyed. Avaliar também ações de menu simultâneas e patch durante gesto para não disputar DOM.
6. Index: evento único com payload move_task; usuário/data do servidor. Reutilizar captura restrita de erros de persistência e refresh_snapshot. Generalizar IDs de listas usados por reorder de menu. Concluir visível; menu secundário para seleção/devolução/ordem, preservando IDs de testes quando útil. Não transformar streams em coleções comuns nem usar ignore nas listas.
7. Escrever testes LiveView de eventos, menus, contadores, mensagens, falhas, recarga/remontagem e dados forjados. Não executar teste visual/UX ou navegador: usuário fará essa parte. Verificar hook por inspeção e compilação e declarar esse limite.
8. Atualizar Gettext com mensagens-base inglês e pt_BR; consultar ajuda Mix antes de tarefas ainda não lidas. Rodar gates previstos no README, inclusive precommit/ci e compilação assets. Corrigir falhas relevantes; mínimo de cobertura 70% permanece.
9. Fazer autoavaliação conforme fluxo de review; conferir diff e evidências sem atribuir aprovação independente. Atualizar TASK-040 com resultados reais e limitações, normalmente in_review ao entregar. Não afirmar done/integração apenas por testes locais. Atualizar este arquivo ou apontar que foi superado pelas evidências finais.

## Ambiente e permissões

Projeto em /home/mrrobot/Projetos/planner, shell bash, data da sessão 09/10/2026. Sandbox bloqueou sockets locais do Mix e acesso Docker; testes precisaram execução escalada com justificativa. Prefixo rtk mix já consta permitido no ambiente, mas usar o mecanismo de escalada quando necessário. Tentativas Mix sem escalada falharam com eperm/permission denied; isso não é falha do código. Ler ajuda de cada tarefa Mix antes de usar (test e ecto.gen.migration já consultadas nesta sessão).

Não há bloqueio de produto/humano identificado nem BLOCK novo aberto; pausa é solicitada pelo usuário e a implementação permanece incompleta, com trabalho preservado. Nenhum commit ou publicação foi feito nesta sessão.
