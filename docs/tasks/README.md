# Tarefas de implementação

Specs agregam arquitetura e casos de uso; cada tarefa abaixo entrega um incremento pequeno. Abra a tarefa para encontrar entradas, comando de scaffold (quando aplicável), ajustes e aceite. Status, dependências e bloqueios têm fonte única nos cabeçalhos YAML; convenções no [formato](formato.md).

## Passos de implementação

A ordem abaixo facilita navegação; `depends_on` determina a execução. Remoção libera o trabalho de idiomas; o reset humano também precisa estar concluído antes do scaffold de contas. Demais alterações compartilhadas em contextos, migrations, router e catálogos estão serializadas.

| Incremento |
| --- |
| [003 — Proteger a main e configurar o CI no GitHub](003-infra-github.md) |
| [002 — Remover a geração experimental de Task](002-remover-crud-experimental.md) |
| [012 — Reinicializar o banco após remover o experimento](012-reset-banco.md) |
| [001 — Aplicar locale na sessão HTTP](001-troca-de-idiomas.md) |
| [013 — Aplicar locale na montagem e reconexão LiveView](013-locale-liveview.md) |
| [014 — Adicionar seletor e traduções da interface base](014-seletor-idioma.md) |
| [009 — Gerar a base de autenticação Phoenix](009-contas-e-acesso.md) |
| [015 — Adequar sessões e telas de autenticação](015-integrar-autenticacao.md) |
| [004 — Persistir e validar o fuso da conta](004-configuracao-dia.md) |
| [016 — Calcular a data a partir do fuso do usuário](016-calcular-dia.md) |
| [010 — Gerar o catálogo privado de labels](010-catalogo-labels.md) |
| [005 — Gerar tarefas com cadastro simples no backlog](005-dominio-diario.md) |
| [018 — Criar a relação muitos-para-muitos de labels](018-associar-labels.md) |
| [019 — Cadastrar tarefa e labels em uma transação](019-cadastro-labels-atomico.md) |
| [020 — Criar cota diária e fronteira transacional](020-cota-e-transacao.md) |
| [017 — Editar o fuso na conta com segurança transacional](017-formulario-fuso.md) |
| [021 — Normalizar a virada e consultar o planejamento](021-virada-e-snapshot.md) |
| [022 — Selecionar tarefa e consumir uma escolha](022-selecionar-tarefa.md) |
| [023 — Devolver ao backlog e restituir uma escolha](023-devolver-tarefa.md) |
| [024 — Reordenar somente as prioridades atuais](024-reordenar-tarefas.md) |
| [007 — Concluir uma tarefa preservando o consumo diário](007-historico-e-virada.md) |
| [025 — Consultar conclusões com labels e ordem estável](025-consultar-historico.md) |
| [006 — Gerar LiveViews e expor cadastro simples](006-painel-diario.md) |
| [026 — Adicionar múltiplas labels ao formulário gerado](026-formulario-labels.md) |
| [027 — Mostrar hoje, backlog, retry e cota no painel](027-listas-painel.md) |
| [028 — Ligar seleção e devolução no painel](028-acoes-selecionar-devolver.md) |
| [029 — Adicionar subir e descer prioridades](029-acao-reordenar.md) |
| [030 — Ligar conclusão e consulta de histórico](030-interface-historico.md) |
| [031 — Atualizar o painel na virada e reconexão](031-atualizar-dia-liveview.md) |
| [032 — Ajustar teclado, responsividade e mensagens do painel](032-acessibilidade-painel.md) |
| [011 — Gerar artefatos de release e container](011-entrega-remota.md) |
| [033 — Configurar runtime e entrega de e-mail de produção](033-configurar-producao.md) |
| [034 — Publicar a release no ambiente definido](034-publicar-aplicacao.md) |
| [008 — Executar o aceite final do fluxo integrado](008-aceite-mvp.md) |

## Uma spec, várias entregas

| Contrato amplo | Etapas |
| --- | --- |
| SPEC-001 — Internacionalização | 001 HTTP → 013 LiveView → 014 seletor; novas telas traduzem seus próprios textos. |
| SPEC-002 — Planejamento diário | 005 scaffold; 020 cota/transação; 021 snapshot; 022 seleção; 023 retorno; 024 ordem; 028/029 interface. |
| SPEC-003 — Tempo e histórico | 004 persistência; 016 cálculo; 017 conta; 021 virada; 007 conclusão; 025 consulta; 030/031 interface. |
| SPEC-004 — Experiência | 006 scaffold; 026 formulário; 027 listas; 028/029/030 ações; 031 atualização; 032 acessibilidade. |
| SPEC-005 — Contas | 009 scaffold → 015 sessões/política; contextos e interfaces consumidoras aplicam o scope. |
| SPEC-006 — Classificação | 010 catálogo → 018 associação → 019 cadastro atômico → 026 formulário. |

Release, runtime e publicação são passos separados (011, 033, 034). A persistência após reinício é verificada na publicação. TASK-008 consolida CA01–CA16 usando as evidências das produtoras e um fluxo integrado; não concentra a implementação dos requisitos. O gate aceito permanece na TASK-003.

## Extensão proposta após o MVP

[TASK-035 — Backup e restauração](035-validar-restauracao.md) depende de confirmação de escopo e do MVP aceito. Não integra o gate de CA07/CA16 nem bloqueia a TASK-008.
