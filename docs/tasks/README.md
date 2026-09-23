# Tarefas de implementação

O MVP contém somente o fluxo de planejamento com usuário padrão, pt-BR via Gettext, data corrente e recarga manual. Cabeçalhos YAML são a fonte de status, dependências e bloqueios; convenções no [formato](formato.md). Cada tarefa informa scaffold e ajustes quando houver geração.

## MVP

Gate GitHub e base limpa têm aceite humano registrado. A implementação começa pela TASK-002; não depende de escolhas de autenticação, idiomas ou fuso. As demais etapas mantêm produtor único e serializam arquivos compartilhados.

| Incremento |
| --- |
| [003 — Proteger a main e configurar o CI no GitHub](003-infra-github.md) |
| [012 — Preparar a base limpa](012-reset-banco.md) |
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
| [032 — Ajustar teclado, responsividade e mensagens do painel](032-acessibilidade-painel.md) |
| [008 — Executar o aceite do MVP mínimo](008-aceite-mvp.md) |

## Uma spec, vários passos

| Capacidade | Entregas do MVP |
| --- | --- |
| SPEC-001 — Interface pt-BR | 001 configura Gettext; telas traduzem seus próprios textos. |
| SPEC-002 — Planejamento | 005 scaffold, 020 cota, 021 snapshot, 022 seleção, 023 devolução, 024 ordem, 028/029 interface. |
| SPEC-003 — Data e histórico | 016 data, 021 normalização, 007 conclusão, 025 consulta, 030 interface; recarga usa 006/027. |
| SPEC-004 — Painel | 006 scaffold, 026 formulário, 027 listas, 028/029/030 ações, 032 acessibilidade. |
| SPEC-005 — Usuário padrão | 009 cria/resgata identidade; 006 a resolve no servidor sem login. |
| SPEC-006 — Labels | 010 catálogo, 018 relação, 019 cadastro atômico, 026 formulário. |

TASK-008 verifica CA01–CA13 e CA15, incluindo persistência após reinício e cobertura mínima de 70% exigida pelo CI.

## Evolução futura — não bloqueia o MVP

Estas tarefas só poderão iniciar após redefinir seus contratos e decisões de produto. Não representam trabalho necessário para a entrega mínima.

| Evolução |
| --- |
| [013 — Locale variável em LiveView](013-locale-liveview.md) |
| [014 — Seletor de idioma](014-seletor-idioma.md) |
| [015 — Autenticação e contas reais](015-integrar-autenticacao.md) |
| [004 — Fuso configurável na conta](004-configuracao-dia.md) |
| [017 — Gerenciamento de fuso](017-formulario-fuso.md) |
| [031 — Atualização automática do painel](031-atualizar-dia-liveview.md) |
| [011 — Release de produção](011-entrega-remota.md) |
| [033 — Runtime de produção](033-configurar-producao.md) |
| [034 — Publicação remota](034-publicar-aplicacao.md) |
| [035 — Backup e restauração](035-validar-restauracao.md) |
