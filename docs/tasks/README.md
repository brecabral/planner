# Tarefas de implementação

O MVP local entregue contém o fluxo de planejamento com usuário padrão, pt-BR via Gettext, data corrente e recarga manual. O MVP de produção amplia esse contrato conforme o PRD e a seção própria abaixo. Cabeçalhos YAML são a fonte de status, dependências e bloqueios; convenções no [formato](formato.md). Cada tarefa informa scaffold e ajustes quando houver geração.

## MVP

MVP local encerrado em 05/10/2026: entregas integradas e revisão independente aprovada (histórico em `4ed2a47:docs/review.md`, seção `revalidação-de-prontidão-do-mvp--05102026`) no alvo `2b8ba19`, com R1 encerrado pela TASK-038. Gates reproduzidos pelo revisor: 139 testes aprovados, cobertura de 92,25% e Credo sem achados. A renovação da interface posterior ao MVP está registrada abaixo. A avaliação humana obrigatória foi retirada por [decisão do responsável](../prd.md#feedback-de-interface); registros anteriores de pendência são históricos.

Gate GitHub e base limpa têm aceite humano registrado. As TASK-036, TASK-002, TASK-001, TASK-009, TASK-016 e TASK-010 estão concluídas e integradas, com [revisão independente aprovada](../review.md) no escopo dessas entregas. O [BLOCK-001](../blocks/001-cobertura-apos-remocao-crud.md) está resolvido. A seleção das próximas tarefas deve respeitar suas dependências e bloqueios atuais. O MVP não depende de escolhas de autenticação, idiomas ou fuso. As demais etapas mantêm produtor único e serializam arquivos compartilhados.

| Incremento |
| --- |
| [003 — Proteger a main e configurar o CI no GitHub](003-infra-github.md) |
| [012 — Preparar a base limpa](012-reset-banco.md) |
| [036 — Cobrir os comportamentos da base Phoenix](036-cobertura-base.md) |
| [002 — Remover a geração experimental de Task](002-remover-crud-experimental.md) |
| [001 — Fixar a interface base em pt-BR via Gettext](001-troca-de-idiomas.md) |
| [009 — Gerar e preparar o usuário padrão do MVP](009-contas-e-acesso.md) |
| [016 — Fornecer a data corrente do planejamento](016-calcular-dia.md) |
| [010 — Gerar o catálogo de labels do usuário padrão](010-catalogo-labels.md) |
| [005 — Gerar tarefas com cadastro simples no backlog](005-dominio-diario.md) |
| [018 — Criar a relação muitos-para-muitos de labels](018-associar-labels.md) |
| [019 — Cadastrar tarefa e labels em uma transação](019-cadastro-labels-atomico.md) |
| [020 — Criar cota diária e fronteira transacional](020-cota-e-transacao.md) |
| [021 — Normalizar a virada ao consultar ou executar comandos](021-virada-e-snapshot.md) |
| [022 — Selecionar tarefa e consumir uma escolha](022-selecionar-tarefa.md) |
| [023 — Devolver ao backlog e restituir uma escolha](023-devolver-tarefa.md) |
| [024 — Reordenar somente as prioridades atuais](024-reordenar-tarefas.md) |
| [007 — Concluir uma tarefa preservando o consumo diário](007-historico-e-virada.md) |
| [025 — Consultar conclusões com labels e ordem estável](025-consultar-historico.md) |
| [006 — Gerar o painel e cadastro simples do MVP](006-painel-diario.md) |
| [026 — Adicionar múltiplas labels ao formulário gerado](026-formulario-labels.md) |
| [027 — Mostrar hoje, backlog, retry e cota no painel](027-listas-painel.md) |
| [028 — Ligar seleção e devolução no painel](028-acoes-selecionar-devolver.md) |
| [029 — Adicionar subir e descer prioridades](029-acao-reordenar.md) |
| [030 — Ligar conclusão e consulta de histórico](030-interface-historico.md) |
| [032 — Validar estrutura e mensagens do painel](032-acessibilidade-painel.md) |
| [008 — Executar o aceite do MVP mínimo](008-aceite-mvp.md) |
| [037 — Criar usuário padrão no primeiro acesso em desenvolvimento](037-usuario-padrao-dev.md) |
| [038 — Tratar falha de persistência no cadastro](038-tratar-falha-cadastro.md) |

## Uma spec, vários passos

| Capacidade | Entregas do MVP |
| --- | --- |
| SPEC-001 — Interface pt-BR | 001 configura Gettext e traduz layouts e página inicial preservada; telas futuras traduzem seus próprios textos. |
| SPEC-002 — Planejamento | 005 scaffold, 020 cota, 021 snapshot, 022 seleção, 023 devolução, 024 ordem, 028/029 interface. |
| SPEC-003 — Data e histórico | 016 data, 021 normalização, 007 conclusão, 025 consulta, 030 interface; recarga usa 006/027. |
| SPEC-004 — Painel | 006 scaffold, 026 formulário, 027 listas, 028/029/030 ações, 032 acessibilidade, 038 tratamento de falha no cadastro. |
| SPEC-005 — Usuário padrão | 009 cria/resgata identidade; 006 a resolve no servidor sem login; 037 adiciona criação automática no acesso em dev. |
| SPEC-006 — Labels | 010 catálogo, 018 relação, 019 cadastro atômico, 026 formulário. |

TASK-008 verifica CA01–CA13 e CA15, incluindo cobertura mínima de 70% exigida pelo CI. O aceite de persistência após reinício foi retirado em 17/10/2026; evidências anteriores permanecem históricas.

## Evolução autorizada após o MVP

| Incremento |
| --- |
| [039 — Renovar a experiência do Planner](039-renovar-experiencia.md) |
| [040 — Arrastar tarefas com mouse e touch](040-arrastar-tarefas.md) |

O encerramento da TASK-040 foi reconciliado com a integração `367bf35` e o aceite local do responsável em 11/10/2026. Seus registros de correção/revisão anteriores são históricos.

## MVP de produção — plano de 11/10/2026

Escopo revisto pelo responsável em 13/10/2026: entregar código Phoenix funcional e release local validado. Execução e estados reais seguem os cabeçalhos. TASK-051 e TASK-011 estão integradas e BLOCK-005 encerrado; TASK-050 consolida o aceite local. Escolhas de infraestrutura pertencem ao usuário e não bloqueiam esta sequência.

| Entrega | Tarefa |
| --- | --- |
| Corrigir menu à esquerda e controles comprimidos | [041](041-ajustar-menu-tarefas.md) |
| Enviar retry ao backlog | [042](042-retry-para-backlog.md) |
| Exclusão definitiva de pendências no domínio | [043](043-excluir-pendencias-dominio.md) |
| Confirmação e exclusão pelo painel | [044](044-excluir-pendencias-interface.md) |
| Scaffold de auth Phoenix, cadastro aberto e magic link | [015](015-integrar-autenticacao.md) |
| Home/login/dashboard e isolamento por conta | [045](045-isolar-planejamento-autenticado.md) |
| Testar magic link em dev pela mailbox local | [046](046-magic-link-dev.md) |
| Catálogo, concessões gratuitas e preferência de tema | [047](047-catalogo-concessoes-temas.md) |
| Tema claro/escuro e seletor persistido | [048](048-temas-claro-escuro.md) |
| Recuperação de falha de envio no cadastro (R3) | [051](051-tratar-falha-envio-cadastro.md) |
| Release local com assets e migrations | [011](011-entrega-remota.md) |
| Aceite integrado do código e release local | [050](050-aceite-mvp-producao.md) |

Cadastro aberto e dados antigos isolados foram confirmados. Exclusão preserva concluídas e restitui uma escolha somente ao excluir pendência de hoje. Os dois temas são gratuitos para todas as contas; catálogo/concessões preparam propriedade futura sem saldo ou loja. A SPEC-008 define a entrega local. Configuração remota, publicação e backups pertencem ao usuário. As antigas tarefas [033](033-configurar-producao.md), [034](034-publicar-aplicacao.md) e [035](035-validar-restauracao.md) ficam apenas como registros de cancelamento por escopo.

## Página de criação de conta — plano de 14/10/2026

[TASK-052 — Página pública em /join](052-pagina-join.md): apresentação do Planner e cadastro por e-mail sobre o magic link existente, com compatibilidade de `/users/register`. Depende da TASK-051 concluída; capacidade mínima `standard`. Contrato em SPEC-005 RN16–RN19/CA-005-14–17. Integrada; evidências e limites no arquivo da tarefa.

## Evolução futura — não bloqueia o MVP de produção

| Evolução | Tarefa |
| --- | --- |
| Locale variável em LiveView | [013](013-locale-liveview.md) |
| Seletor de idioma | [014](014-seletor-idioma.md) |
| Fuso configurável na conta | [004](004-configuracao-dia.md) |
| Gerenciamento de fuso | [017](017-formulario-fuso.md) |
| Atualização automática do painel | [031](031-atualizar-dia-liveview.md) |
| Adição de créditos por usuário, com regras a definir | [049](049-creditos-usuarios.md) |

Compra de temas, preços, loja e pagamentos serão decompostos depois de decisões próprias na SPEC-009. Não são dependências dos dois temas gratuitos nem da entrega do release local.

## Retomada após revisão de 13/10/2026

Reconciliação de R6 em 16/10/2026: TASK-051 e TASK-011 estão integradas; BLOCK-005 foi encerrado. A elegibilidade da TASK-050 passa a depender também da correção de R7, conforme cabeçalho atual. R3 foi revalidado pelo revisor; R4/R5 já foram reconciliados. As evidências históricas permanecem nas tarefas e no Git; a limpeza do relatório atual não concede aprovação retroativa.

## Correções de login e temas — 14/10/2026

- [TASK-053 — Destacar Criar conta no login](053-destacar-criar-conta-login.md): capacidade `basic`, após TASK-052; botão equivalente a entrar, mantendo navegação para `/join`.
- [TASK-054 — Corrigir temas na navbar](054-corrigir-temas-na-navbar.md): capacidade `standard`, após TASK-048/052; reproduzir falha, corrigir aplicação visual e oferecer seletor junto de Sair.

Ambas estão integradas, conforme registros das tarefas. O responsável confirmou o destaque do cadastro. A TASK-054 conserva a limitação da reprodução visual original; cenários autenticados da TASK-056 ainda devem verificar paletas no navegador.

## E2E local e obrigatório no CI — plano de 16/10/2026

- [055 — Consolidar ambiente E2E e operação local Just](055-comando-e2e.md): produtora do runner isolado e da operação Just; evidências e integração no arquivo da tarefa.
- [056 — Cobrir os fluxos autenticados no navegador](056-cenarios-e2e.md): consome o runner e acrescenta fixtures/cenários de interface.
- [057 — Tornar E2E obrigatório no GitHub CI](057-e2e-github-ci.md): executa a suíte no check `quality` existente.

Sequência 055 → 057 → 056 serializa README e configuração compartilhada. A 055 integrou o runner local. A 057 fornece infraestrutura própria no GitHub; a 056 amplia cenários públicos para autenticados. Não há nova tarefa humana nem alteração da proteção remota: a TASK-003 já tem aceite humano. Política de uso por front e revisores no [PRD](../prd.md#e2e-obrigatório--decisão-de-16102026); decisões em D20. Entregas históricas permanecem com suas evidências originais.

## Correção de R7 — planejamento de 16/10/2026

[058 — Fixar isolamento do projeto Compose de teste](058-isolar-projeto-compose-teste.md) corrige a identidade herdada nas operações de teste e acrescenta regressão segura. Diagnóstico e condição de retomada no [BLOCK-006](../blocks/006-isolamento-compose-teste.md). O incremento parte das entregas 055/057 já integradas, sem exigir sua aprovação independente prévia. A TASK-058 precede TASK-056 e TASK-050; ambas aguardam a correção. A sequência anterior de tooling foi atualizada nos cabeçalhos, fonte única do grafo. Planejamento não encerra R7 nem comprova correção.
