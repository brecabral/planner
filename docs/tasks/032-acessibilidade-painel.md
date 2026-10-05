---
id: "TASK-032"
status: "done"
execution_level: "standard"
execution_rationale: "Ajusta mensagens e estrutura acessível do painel, com testes LiveView, sem modificar regras de domínio."
specs: ["SPEC-001", "SPEC-004"]
depends_on: ["TASK-030"]
provides: ["accessible-planner-ui"]
consumes: ["history-ui", "ptbr-interface"]
write_scope: ["lib/planner_web/live/task_live/", "assets/css/", "priv/gettext/", "test/planner_web/live/task_live_test.exs"]
blockers: []
---

# 032 — Validar estrutura e mensagens do painel

## Entrada e limite

[SPEC-004](../specs/004-experiencia-e-acesso.md) CA-004-01 a CA-004-06 e [SPEC-001](../specs/001-idiomas.md) CA-I01 a CA-I03; consumir history-ui. Referências interface, HEEx e Gettext.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Corrigir nomes acessíveis e mensagens/plurais ausentes do painel, verificando estrutura e eventos com os testes LiveView existentes. Preservar componentes gerados e dados digitados. Não mudar regras de domínio nem adicionar preferências de idioma. Validação real de teclado, foco, layout e anúncios por tecnologias assistivas fica fora desta tarefa e dos seus gates, reservada à validação humana do PRD. Não instalar ferramentas de navegador nem acrescentar infraestrutura de testes.

## Aceite e teste de intenção

1. Testes LiveView exercitam cadastro, seleção, reordenação, devolução e conclusão pelos controles existentes, verificam o estado esperado após eventos e remontagem e mensagens em pt-BR. Reutilizar a cobertura das produtoras e complementar apenas lacunas relevantes.
2. Testes verificam erros associados aos campos, marcação de alertas, nomes dos controles e estados vazios com as ações pertinentes presentes; conteúdo do usuário permanece igual. Esses testes não atestam apresentação visual, foco nem anúncios reais.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

A retomada foi autoavaliada pelo implementador conforme o fluxo de review; conferência operacional e integração pelo coordenador pendentes. Não houve revisão independente, conforme o fluxo atual. Não liberar consumidora antes dos gates e da integração.

Execução interrompida em 04/10/2026 pelo [BLOCK-004](../blocks/004-validacao-navegador-acessibilidade.md), base `69d4a20`. Firefox headless encerrou com sinal 11 no sandbox; solicitação de execução escalada foi abortada pelo usuário, sem autorização concedida. Nenhum código foi alterado; aceite de teclado/layout/foco não demonstrado, gates desta tarefa não executados. Alterações preexistentes preservadas. Em 05/10/2026, o responsável transferiu essas verificações para validação humana fora das tarefas. O contrato acima foi atualizado e o BLOCK-004 resolvido por essa decisão; a tarefa pode retomar em `in_progress`, sem presumir execução, aceite ou revisão.


### Retomada e autoavaliação — 05/10/2026

Implementador `/root/implement_032`; base `69d4a20`, com TASK-030 integrada em `7b98d09`. Alvo: alterações locais em `lib/planner_web/live/task_live/form.ex`, `lib/planner_web/live/task_live/index.ex` e `test/planner_web/live/task_live_test.exs`. Alterações documentais preexistentes preservadas; sem staging/commit pelo implementador.

- Critério 1 / CA-004-01 a CA-004-06: reutilizados os testes de cadastro com labels, seleção de backlog/retry, subir/descer, devolução, conclusão, cota esgotada, conflito e falha real de persistência. Eles acionam formulários existentes e verificam estado autoritativo, identidade, labels, histórico e remontagem. Acrescentada verificação do nome contextual das ações selecionar/devolver/concluir, composto do texto pt-BR do botão e título original via `aria-labelledby`.
- Critério 2: erros de título, labels existentes e novas labels agora possuem `aria-invalid`, associação por `aria-describedby` e contêiner com `role="alert"`; ajuda de novas labels permanece associada junto do erro. Componente local reutiliza o input gerado e a tradução existente, sem modificar componentes compartilhados. Teste verifica ausência de erro inicial, associação por campo, limpeza após correção, erro traduzido e preservação do título/conteúdo digitado. Alertas de conflitos e persistência continuam cobertos pelos testes existentes.
- SPEC-001 CA-I01 a CA-I03: cobertura existente confirma pt-BR e `lang="pt-BR"` na remontagem, mensagens traduzidas e conteúdo original; novos asserts verificam estados vazios, link de cadastro e singular/plural das escolhas. Nenhuma mensagem-base nova ou alteração do catálogo foi necessária. A contagem zero mantém a forma singular definida pelo pluralizador pt_BR existente.
- TDD: execução inicial teve 18/21 testes aprovados e três falhas: duas reproduziram as lacunas de associação de erros/nome contextual; uma era expectativa incorreta do plural zero e foi ajustada à regra existente, sem alterar produto. Após implementação, 21/21 testes LiveView aprovados.
- Gates: `rtk mix precommit` e `rtk mix ci` aprovados com 127 testes; Credo estrito sem achados. Cobertura total 92,12%, Form 97,73%, Index 97,66%, mantendo limiar de 70% (evidência anterior da TASK-030: total 91,91%, Index 97,64%). `rtk git diff --check` aprovado. A métrica é de linhas, não comprova todos os ramos nem experiência assistiva.
- Autoavaliação: critérios estruturais e funcionais atendidos, sem achados bloqueantes; conclusão técnica `approved` somente como autoavaliação. Inspeção do diff confirma escopo restrito à apresentação, sem alteração de domínio, persistência ou autorização. Não avança o marco de revisão independente.
- Limitações: sem execução de navegador, teclado, foco, layout ou tecnologia assistiva real. Essas verificações estão fora dos gates por decisão registrada no BLOCK-004 e permanecem na validação humana do PRD. `in_review` aguarda conferência operacional e integração do coordenador.

### Conferência operacional — 05/10/2026

Coordenador `/root`: registro e resumo conferidos superficialmente, sem impedimentos. Gates locais relatados aprovados: 127 testes e cobertura de 92,12%. Entrega integrada na base de trabalho em `616b72d`; TASK-008 liberada. Sem revisão independente ou verificação de CI remoto. Validação humana da interface permanece pendente fora dos gates. Alterações documentais preexistentes fora desta tarefa foram preservadas.
