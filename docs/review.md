# Revisão das tarefas propostas

Data: 23/09/2026. Revisor: Codex, perfil revisor. Resultado: **changes_requested**.

## Parecer

As tarefas têm boa aderência à solução atual e contemplam todos os requisitos funcionais RF01–RF11. A distinção entre pendências e escolhas consumidas está preservada; devolução manual vai para backlog e restitui escolha, virada automática vai para retry e conclusão mantém o consumo. Labels, isolamento por conta, idiomas e publicação remota têm entregas identificadas. Não encontrei expansão para gestão de projetos, compartilhamento, IA ou outros itens explicitamente fora do escopo.

O plano ainda exige ajustes antes de ser tratado como um conjunto de incrementos com aceite consistente. Há uma contradição na fonte de requisitos e duas lacunas na distribuição dos testes de intenção. Além disso, decisões de produto já registradas como pendentes impedem a execução de boa parte da cadeia. Cobertura documental não comprova funcionamento: esta revisão não aprova implementação nem entrega remota.

## Alvo, base e limites

- Alvo: estado local das 35 tarefas TASK-001–TASK-035, seus cabeçalhos e corpos, índice e formato; comparação com PRD, SPEC-001–SPEC-006, DDD e design atuais.
- Base Git de referência: `4db1b79fec1e0e69a503191fd3af20bb5d6c67c1`. Há alterações locais e arquivos não rastreados; o alvo não é somente o conteúdo desse commit.
- O PRD local atualizado é a fonte dos objetivos. Mudanças em relação à versão anterior não foram tratadas automaticamente como distorções, pois a documentação registra novas decisões do responsável em 23/09/2026.
- Método: leitura dos contratos, rastreamento requisito → tarefa → aceite e verificação mecânica das dependências. Aplicados o fluxo de review e a skill `plan-task-graph`, sem executar tarefas.
- Somente este relatório foi criado. Tarefas, specs, estados, código e decisões existentes não foram alterados. A revisão não foi copiada para cada tarefa em respeito ao pedido de não modificá-las.

## Achados que exigem correção

### R1 — P1: o aceite da cota contradiz a devolução que o próprio produto exige

**Local:** `docs/prd.md:66` (CA03), em conflito com `docs/prd.md:68` (CA05), `docs/specs/002-planejamento-diario.md:25` (RN03) e `docs/specs/002-planejamento-diario.md:37` (CA-002-05). A TASK-008 incorpora ambos os critérios em `docs/tasks/008-aceite-mvp.md:31`.

**Condição:** selecionar três tarefas, devolver uma ao backlog e tentar selecionar outra. CA03 exige rejeitar mesmo após devolução; CA05 e a spec exigem liberar uma escolha e permitir a seleção seguinte.

**Impacto:** uma implementação correta de TASK-023/TASK-028 falharia no CA03 literal. Não é possível produzir uma matriz de aceite final coerente atendendo simultaneamente aos dois resultados. Um implementador pode ainda interpretar o critério errado como limite cumulativo que nunca restitui escolhas.

**Correção esperada:** harmonizar CA03 com a regra confirmada: conclusão não libera escolha; devolução manual válida libera. Manter cenários separados para rejeição após conclusão e nova seleção permitida após devolução. A correção é na documentação de aceite, sem inverter o comportamento já especificado nas tarefas.

### R2 — P2: TASK-022 exige um cenário completo cuja operação só será entregue depois

**Local:** `docs/tasks/022-selecionar-tarefa.md:30`, que exige CA-002-02; cenário definido em `docs/specs/002-planejamento-diario.md:34`. A conclusão é produzida por TASK-007 (`docs/tasks/007-historico-e-virada.md:8`).

**Condição:** executar TASK-022 na ordem declarada. CA-002-02 pede selecionar três tarefas, concluir uma e rejeitar a quarta. Nesse ponto, a operação pública de conclusão ainda não existe: TASK-007 depende de TASK-024, que depende de TASK-023, que depende da própria TASK-022.

**Impacto:** o cenário completo não pode ser demonstrado pelo fluxo real nessa entrega sem antecipar implementação fora do escopo. Montar uma fixture já concluída pode testar a seleção isoladamente, mas não prova que concluir preserva o consumo. Adicionar TASK-007 como pré-requisito de TASK-022 criaria um ciclo.

**Correção esperada:** delimitar o aceite de TASK-022 à seleção, cota e concorrência já disponíveis; atribuir expressamente o cenário integrado selecionar → concluir → rejeitar nova seleção à TASK-007 ou a uma verificação posterior. Se mantido um teste com estado preparado na TASK-022, identificá-lo como parcial e preservar o teste integrado posterior.

### R3 — P2: a integração entre troca de fuso e seleção é prometida, mas não aparece no aceite da consumidora

**Local:** `docs/tasks/017-formulario-fuso.md:31` promete verificar a integração na produtora de seleção; `docs/tasks/022-selecionar-tarefa.md:28` inicia um aceite que cobre disputa por vaga, rollback, repetição e ID alheio, mas não essa integração. O risco é explicitado em `docs/specs/003-dia-e-historico.md:41`.

**Condição:** alterar o fuso enquanto outra conexão seleciona uma tarefa, sobretudo quando a alteração muda a data local ou retorna a uma data que já tem consumo registrado.

**Impacto:** testar a trava na TASK-017 e testar seleções concorrentes na TASK-022 não comprova que os dois comandos reais releem a mesma preferência e aplicam corretamente a política de vigência. É possível aprovar ambos os aceites listados sem demonstrar que não há consumo na data errada, reposição indevida da cota ou destino incorreto das pendências. Trata-se de uma lacuna do plano de verificação, não de um defeito de código constatado.

**Correção esperada:** após decidir a política da SPEC-003, incluir na TASK-022 o teste integrado prometido, com conexões distintas, instante controlado e as duas ordens de execução. Verificar data, cota e destino das pendências, incluindo retorno a uma data já utilizada. Declarar `timezone-settings` como consumo tornaria esse contrato mais explícito; sua produtora já é ancestral, portanto não falta uma aresta para alcançá-la.

## Aderência aos objetivos

A tabela indica cobertura planejada; nenhum item representa aceite executado nesta revisão.

| Objetivo / requisito | Tarefas responsáveis | Avaliação |
| --- | --- | --- |
| Cadastrar pelo título e distinguir backlog/hoje/retry — RF01/RF06 | 005, 006, 021, 027 | Coberto; estado e proprietário são definidos no servidor, com rejeição de título inválido. |
| Escolher e ordenar até três prioridades — RF02/RF03/RF07 | 020, 022, 023, 024, 028, 029 | Coberto no desenho; corrigir R1 e a distribuição de aceite de R2. |
| Concluir sem repor cota e preservar histórico — RF04/RF05 | 007, 025, 030 | Coberto; data original, idempotência e disputa com devolução estão previstas. |
| Identidade e isolamento — RF08 | 009, 015 e contextos/interfaces consumidores | Coberto transversalmente, inclusive IDs forjados e sessão já conectada; política de autenticação ainda pendente. |
| Fuso individual e virada — RF09/CA08/CA14 | 004, 016, 017, 020, 021, 031 | Coberto em intenção; depende da política temporal e do teste integrado de R3. |
| Labels reutilizáveis e múltiplas — RF10/CA15 | 010, 018, 019, 026; preservação em 025/030 | Coberto; cadastro atômico, vínculo único e proibição de associação entre contas. |
| Uso remoto e persistência — RF11/CA07/CA12/CA16 | 011, 033, 034, 035, 008 | Coberto; publicação depende de destino e acesso definidos. Restauração amplia o aceite mínimo, conforme observação abaixo. |
| Idiomas, teclado, celular e erros — CA09/CA10 | 001, 013, 014, tarefas de interface, 032 | Coberto em critérios; falta executar a avaliação visual e comportamental futura. |
| Qualidade e aceite integrado — CA11 e CA01–CA16 | 003, verificações em cada entrega, 008 | Gate humano registrado como aceito; entrega atual ainda não validada. Matriz final depende de corrigir R1. |

A arquitetura também preserva os limites da solução: monólito Phoenix/PostgreSQL, contextos com escopo autenticado, domínio responsável pela cota, Gettext e geradores sem exposição do CRUD genérico. A tarefa produtora da fronteira transacional é `advanced`, assim como sessão/invalidação e normalização temporal; as consumidoras reutilizam esses contratos em vez de criarem concorrência própria.

## Grafo e prontidão

A verificação dos cabeçalhos encontrou **35 tarefas, 35 recursos publicados e 35 arestas**, sem ciclos, referências de dependência inexistentes, recursos duplicados ou consumos cujo produtor não fosse alcançável. A única tarefa `done` é TASK-003, sem dependências ou bloqueios incompatíveis com esse estado. Seu aceite humano foi respeitado, sem reabertura do gate.

A serialização resolve a maior parte dos conflitos de escrita: somente os pares TASK-012/TASK-001, TASK-012/TASK-013 e TASK-012/TASK-014 não têm relação de ancestralidade. TASK-012 não declara escrita em arquivos, e as demais atuam sobre locale. Não identifiquei disputa de produtor nesses ramos. Isso valida a estrutura declarada, sem provar que o trabalho será implementado com os limites previstos.

No estado atual, **TASK-002 é a única tarefa de agente elegível** pelas regras documentadas. Não foi executada. Os bloqueios seguintes são reais e já estão representados no plano:

| Bloqueio | Decisão ou ação necessária | Trabalho impedido |
| --- | --- | --- |
| SPEC-001 em `draft` / TASK-001 | Confirmar idioma padrão, persistência e fallback. | Idiomas e, pela cadeia atual, autenticação e restante do produto. |
| TASK-012 — Reinicializar o banco após remover o experimento (`human`) | Uma pessoa deve executar o reset após integrar TASK-002 e registrar confirmação e resultado de base limpa. | TASK-009 e todas as suas descendentes; o ramo de idiomas não depende desse reset. |
| SPEC-005 em `draft` / TASK-009 | Definir entrada, criação/recuperação e cadastro aberto ou por convite. | Scaffold ajustado à política e contrato de autenticação. |
| SPEC-003 em `draft` / TASK-004 | Definir fuso inicial, vigência de mudanças e prazo de atualização. | Contrato de dia e entregas dependentes. |
| TASK-034 | Definir destino, domínio, acesso e autorização de publicação. | Publicação, restauração remota e aceite final. |

Essas pendências não são omissões escondidas nem autorização para o implementador decidir produto. Tornar as specs `ready` exige resolver seus pontos abertos e revisar as tarefas afetadas. Em particular, escolher fuso obrigatório no cadastro pode exigir ampliar o escopo de telas hoje concentrado em Settings; escolher autenticação externa pode exigir revisar o comando Phoenix proposto. O bloqueio existente evita tratar essas alternativas como já decididas.

## Observações não bloqueantes

1. **A cadeia é quase inteiramente serial.** Isso é justificável para arquivos compartilhados e execução incremental, mas também impõe esperas de coordenação: o catálogo de labels depende do cálculo de dia e a primeira tela só chega depois de todo o domínio histórico. O custo é descobrir problemas de usabilidade mais tarde. Considerar antecipar uma fatia utilizável se rapidez de feedback for prioridade, preservando produtor único e serialização onde houver conflito real. Não há obrigação de paralelizar.
2. **Restauração é uma exigência adicional ao aceite de reinício.** TASK-035 exige provar backup/restauração e bloqueia TASK-008. CA07/CA16 exigem preservar dados após reinício, o que não implica, por si só, um ensaio de recuperação de backup. É uma proteção operacional útil, mas deve ser reconhecida como ampliação do mínimo exigido e mantida como gate por decisão explícita de escopo, não apresentada como equivalência direta desses critérios.
3. **O sucesso sem instrução externa merece evidência própria.** TASK-032 e TASK-008 verificam operação e acessibilidade, mas não explicitam uma observação de alguém percorrendo o fluxo sem orientação. Um ensaio curto pode avaliar a clareza de hoje, retry e escolhas usadas. É uma melhoria de validação do objetivo do PRD, não requisito para criar pesquisa ou ferramenta nova.
4. **Alguns registros são genéricos demais.** O texto repetido de scaffold/TDD em tarefas de aceite ou publicação e a justificativa idêntica de nível `standard` acrescentam pouca informação. Também há consumos mencionados no corpo e omitidos no YAML, como `select-today` e `return-to-backlog` na TASK-007. Os produtores são alcançáveis, portanto isso não quebra o grafo atual; explicitar os contratos melhora futuras revisões e reordenações.

## Evidências e limitações da verificação

- `git status --short`, `git rev-parse HEAD`, `git diff --stat`, `git diff --numstat` e consulta de diffs relevantes identificaram a base e as propostas locais.
- Leitura de PRD, design, DDD, seis specs, 35 tarefas, formato e índice; `rg -n` e `nl -ba` localizaram as referências dos achados.
- Script Python somente em memória leu os frontmatters no formato usado pelo projeto, percorreu ancestralidade e verificou recursos, dependências, ciclos e consistência de conclusão. Não instalou parser, não criou grafo paralelo e não alterou arquivos. Resultado: zero erros estruturais nos controles descritos acima. Não equivale a validar toda sintaxe YAML possível ou todas as interseções semânticas de arquivos.
- O executor padrão falhou ao iniciar por erro de montagem do sandbox. As leituras foram realizadas pelo executor com permissão ampliada; isso não afetou o conteúdo avaliado.
- Não foram executados geradores, reset, publicação, testes de aplicação, cobertura, CI ou evals de interface. O alvo é o planejamento. `mix precommit` inclui formatação e desbloqueio de dependências não usadas (`mix.exs:124`); executá-lo poderia alterar arquivos além deste relatório, contrariando o pedido. Não há alegação de gates aprovados para a implementação proposta.
- Não foram auditados mecanismos concretos de persistência, segurança ou concorrência futuros. Os achados tratam de contradições e lacunas verificáveis nos contratos atuais.

## Encaminhamento

Solicitar correção de R1–R3 no planejamento e resolver as decisões pendentes antes de executar as entregas correspondentes. Não é necessário refazer toda a decomposição: a cobertura funcional e a estrutura do grafo são aproveitáveis. A aprovação futura deve confirmar os aceites redistribuídos e a coerência entre PRD, specs e tarefas; o funcionamento real dependerá das evidências de implementação.
