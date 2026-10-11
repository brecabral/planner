---
id: "TASK-001"
status: "done"
execution_level: "standard"
execution_rationale: "Configura pt-BR fixo no Gettext existente e traduz a interface base."
specs: ["SPEC-001"]
depends_on: ["TASK-002"]
provides: ["ptbr-interface"]
consumes: ["experimental-crud-removed"]
write_scope: ["config/config.exs", "lib/planner_web/components/layouts*", "lib/planner_web/controllers/page_html/home.html.heex", "priv/gettext/", "test/planner_web/"]
blockers: []
---

# 001 — Fixar a interface base em pt-BR via Gettext

Entrega integrada em `feat/mvp` no commit `5b178f5`, em 24/09/2026. Coordenador `/root` confirmou o commit da árvore aprovada pelo revisor independente `/root/review_task001`: CI com 23 testes e 79,10% de cobertura. TASK-001 concluída; dependência `ptbr-interface` liberada. BLOCK-002 resolvido por conferência documental, com implementação e aceite registrados nesta entrega.

## Objetivo e entrada

Aplicar [SPEC-001](../specs/001-idiomas.md) na infraestrutura existente: locale padrão fixo pt_BR, HTML pt-BR e traduções da interface base, com msgids em inglês. Não criar seletor, preferência em sessão, rota de idioma ou hook de troca. Cada tela futura traduz seus próprios textos. Referência Gettext.

### Decisão de escopo — BLOCK-002, 24/09/2026

A interface base inclui os layouts e a página inicial Phoenix preservada em `lib/planner_web/controllers/page_html/home.html.heex`. A TASK-001 é responsável por envolver seus textos de interface em Gettext e fornecer as traduções pt_BR: chamada principal, descrição, rótulos dos links e nomes acessíveis dos controles, além das mensagens dos layouts. Nomes próprios de produtos e comunidades, URLs e versões são preservados. Não remover a página, redesenhar seu conteúdo nem antecipar o painel do MVP para satisfazer o aceite.

Entradas: configuração Gettext existente, layouts, template inicial e testes web, incluindo `page_controller_test.exs` e `page_html_test.exs` (entregue pela TASK-036 e já incluído no escopo de testes). Consultar as referências de [Gettext](../referencias/gettext.md), [HEEx](../referencias/heex.md) e [testes](../referencias/testes.md). Atualizar as expectativas de idioma preservando as verificações de links, temas e reconexão. Não gerar novo scaffold.

O nível `standard` permanece adequado para integrar configuração, templates, catálogos e testes com comportamento já definido. A correção cabe na própria tarefa; recursos e dependências permanecem inalterados. Telas futuras continuam responsáveis pelas próprias traduções.

## Aceite

1. Abrir e recarregar mantém pt-BR em HTTP/LiveView sem seletor.
2. Mensagens usadas na base são traduzidas; conteúdo digitado é preservado.
3. Ao acessar GET `/` e repetir a requisição, a página preservada responde 200, com `lang="pt-BR"`, chamada, descrição e rótulos traduzidos; nomes próprios, URLs e versão permanecem corretos. Não há fallback inglês para mensagens traduzíveis usadas nessa página.
4. A renderização da página e dos layouts comprova rótulos e nomes acessíveis em pt-BR e preserva os controles de tema, links e avisos de reconexão. Os testes existentes mantêm suas verificações de comportamento, com expectativas de idioma atualizadas.
5. Catálogos usados nesses cenários não têm traduções vazias ou fuzzy. Testes pertinentes, `mix precommit` e CI passam conforme o README, preservando o limiar de cobertura de 70%. O inglês observado na base é o estado inicial esperado da tradução, não um resultado final aceitável; outros impedimentos fora do contrato seguem o protocolo de bloqueios.

## Evidência e revisão

Execução iniciada em 23/09/2026 pelo implementador `/root/implement_task001`, na base `0c5f70d`. Dependências integradas confirmadas pelo coordenador. Interrompida na inspeção inicial pelo [BLOCK-002](../blocks/002-escopo-traducao-interface-base.md): a página inicial preservada contém textos em inglês fora do `write_scope`, impedindo cumprir integralmente o aceite de interface base pt-BR.

Nenhum código ou teste foi alterado. A ajuda Mix de `test`, `gettext.extract`, `gettext.merge`, `precommit` e `ci` foi consultada; testes e gates não foram executados nesta tentativa. Retomada depende da decisão do planejador registrada nos contratos. Revisão independente e integração pendentes.

Planejamento em 24/09/2026: decisão acima remove a lacuna de escopo do BLOCK-002; `blockers` não contém mais decisão sem solução. A fase `in_progress` foi preservada e a execução permanece parada até o coordenador conferir o contrato e encerrar o relatório. Isso não constitui aceite da implementação nem libera consumidoras antes da conclusão da TASK-001.


### Retomada e autoavaliação — 24/09/2026

Implementador: `/root/implement_task001`; base `0c5f70d`, diff local restrito ao escopo da tarefa. Após encerramento do BLOCK-002 pelo coordenador, implementados backend Gettext fixo em `pt_BR`, HTML `pt-BR`, mensagens-base em inglês nos layouts e página Phoenix e catálogos pt_BR completos. Sem seletor, sessão de idioma ou alteração de rotas; conteúdo, nomes próprios e URLs preservados.

| Aceite | Evidência e resultado |
| --- | --- |
| 1 | `page_controller_test.exs` repete HTTP com Accept-Language inglês e verifica pt-BR; `locale_test.exs` monta duas LiveViews isoladas em processos novos, comprovando locale pt_BR e layout traduzido. |
| 2 | Catálogos default/errors traduzem mensagens existentes; testes de componentes preservam valores/textos informados e verificam erros traduzidos; teste LiveView preserva título em inglês. Singular e plural validados com contagens 1 e 2. |
| 3 | HTTP 200 repetido, lang, chamada e descrição traduzidas; `page_html_test.exs` verifica sete links com rótulos em português, Phoenix Framework e versão. Inspeção dos textos da página não encontrou fallback traduzível. |
| 4 | Testes preservam atributos/comandos dos três temas, nomes acessíveis traduzidos, avisos ocultos de reconexão e atributos connected/disconnected; layout app exercitado pela LiveView isolada. |
| 5 | TDD inicial: cinco falhas esperadas por interface ainda em inglês. `mix precommit`: 23 testes, zero falhas. `mix ci`: 23 testes, zero falhas, Credo estrito sem achados, cobertura total 79,10%, limiar 70% intacto. Inspeção: 19 mensagens default e 24 errors sem traduções vazias ou fuzzy (cabeçalho excluído). Extração/mesclagem sem fuzzy e verificação de atualização passaram. |

Ajuda Mix consultada antes dos comandos. Testes/gates exigiram permissão ao Docker e ao lock TCP do Mix; execução final teve sucesso. Autoavaliação pelo fluxo de review: sem achados bloqueantes; não equivale a revisão independente. Layouts atingiu 100% de cobertura; PageHTML aparece 0% na instrumentação apesar de renderizado por testes HTTP/componentes, portanto a métrica não substitui as asserções de HTML. Não houve teste de navegador real ou interrupção física de rede: reconexão verificada pelos avisos/comandos declarados e locale em processos novos.

Revisão independente e integração pendentes; nenhuma consumidora liberada por esta autoavaliação. Nenhum staging ou commit realizado pelo implementador.

### Revisão independente — 24/09/2026

Revisor: `/root/review_task001`, independente do implementador. Resultado: **approved**, sem achados bloqueantes. Alvo: diff local de configuração, layouts, página inicial, catálogos `priv/gettext` e testes web da TASK-001 contra `0c5f70d6700f0e286c4c229c0573a772abc2fea6`; contrato vigente inclui a decisão posterior do BLOCK-002. Alterações documentais das outras tarefas e bloqueios não integram o código revisado.

Aceites 1–4 conferidos na implementação e nos testes: backend padrão pt_BR e HTML pt-BR; HTTP repetido ignora preferência inglesa; processos LiveView novos usam o mesmo locale; conteúdo informado permanece intacto; erros singular/plural, página inicial, links, nomes acessíveis, temas e avisos de reconexão preservam o comportamento esperado. Inspeção dos catálogos default/errors não encontrou traduções vazias ou fuzzy nas mensagens; nomes próprios e versões são preservados.

Aceite 5: o revisor consultou `rtk mix help ci` e reproduziu `rtk mix ci`: compilação, formato e Credo estrito aprovados, **23 testes aprovados**, cobertura **79,10%**, limiar de 70% intacto. `rtk git diff --check` também passou. `mix precommit` e extração atualizada são evidências relatadas pelo implementador, sem repetição de formatação mutante nesta revisão. Não houve medição comparativa da base; PageHTML permanece com 0% na instrumentação apesar dos testes de renderização, e Layouts atingiu 100%. Avaliação comportamental limitada aos testes HTTP/LiveView/componentes; navegador real e interrupção física de rede não foram exercitados. Aprovação técnica não comprova integração; conclusão e liberação das consumidoras cabem ao coordenador.
