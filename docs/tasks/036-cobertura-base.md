---
id: "TASK-036"
status: "in_review"
execution_level: "standard"
execution_rationale: "Testes de contratos de renderização existentes em Phoenix, sem nova regra de produto ou alteração de infraestrutura."
specs: []
depends_on: ["TASK-003"]
provides: ["baseline-test-coverage"]
consumes: ["github-quality-gate"]
write_scope: ["test/planner_web/", "docs/tasks/036-cobertura-base.md"]
blockers: []
---

# 036 — Cobrir os comportamentos da base Phoenix

## Objetivo e contexto

Corrigir o [BLOCK-001](../blocks/001-cobertura-apos-remocao-crud.md): a base preservada após a remoção do CRUD tem 7 testes aprovados, mas cobertura de 35,18%, inferior aos 70% obrigatórios. Manutenção sem nova regra de produto, por isso `specs: []`.

A remoção já existe no commit `f757265`, presente na base inspecionada `03e8d31`. Conferir sua presença na base de execução, sem refazer ou aprovar a TASK-002. Esta correção não depende do aceite da TASK-002: fornece o gate que falta para que ela possa ser revisada, evitando um ciclo no grafo.

Entradas: `lib/planner_web/components/core_components.ex`, página inicial em `lib/planner_web/controllers/page_html/`, testes web existentes e relatório do BLOCK-001. Consultar as referências de [testes](../referencias/testes.md), [HEEx](../referencias/heex.md) e [formulários](../referencias/formularios.md) conforme os componentes exercitados. Execução local conforme o [README](../../README.md).

## Escopo e passos

1. Identificar contratos observáveis sem testes nos componentes preservados, priorizando formulários (valores, opções, estados e erros), mensagens e página inicial. Confirmar o comportamento existente antes de formular expectativas.
2. Acrescentar testes de HTML renderizado com `Phoenix.LiveViewTest` e seletores `LazyHTML`; testar resultados úteis, não chamadas sem asserções ou detalhes internos. Usar casos pequenos para os ramos relevantes existentes.
3. Medir novamente a cobertura da suíte completa, preencher lacunas dentro deste mesmo escopo e registrar evidências por critério. Não inventar funcionalidades para obter linhas cobertas.

Scaffold: nenhum gerador `phx` é pertinente; adicionar testes aos componentes e controllers existentes. Não regenerar a aplicação ou criar CRUD.

Fora do escopo: configuração do CI ou de cobertura, exclusões da medição, dependências novas, alterações no código de produção, reset do banco e funcionalidades do MVP. Se alcançar o aceite exigir outro escopo, parar e registrar o impedimento para decomposição; não contornar o limiar.

## Aceite

1. Testes novos verificam contratos observáveis dos componentes preservados, incluindo renderização de campos e seus erros/estados relevantes, mensagens e conteúdo estrutural da página inicial. Cada cenário possui asserções capazes de detectar regressão do contrato exercitado.
2. A suíte completa mantém os testes existentes aprovados e alcança cobertura total de pelo menos 70%, com o mesmo limiar e conjunto de módulos medidos antes desta tarefa.
3. `mix precommit` e `mix ci` passam na base integrada. Registrar total de testes, percentual, base avaliada e resultados; não reaproveitar o resultado antigo como evidência de aprovação.
4. Revisão independente confirma o valor dos testes e a ausência de mudanças fora do escopo. O coordenador registra a integração e a resolução do BLOCK-001; a TASK-002 ainda precisa ter sua própria revisão retomada antes de liberar consumidoras.

Contrato `baseline-test-coverage`: testes de regressão da base Phoenix e gate aprovado com cobertura mínima de 70%, preservando a política vigente.

## Evidência e revisão

### Implementação e autoavaliação — 23/09/2026

Implementador: subagente `/root/implement_task036`. Base avaliada: `d25f6c9`, branch `feat/mvp`, com `f757265` confirmado como ancestral. A TASK-003 tem aceite humano explícito e seu gate está integrado. As alterações preexistentes de planejamento foram preservadas.

Entrega limitada a dois arquivos novos de testes: `test/planner_web/components/core_components_test.exs` (13 cenários) e `test/planner_web/controllers/page_html_test.exs` (1 cenário), além deste registro. Nenhuma alteração de produção, dependências, banco ou configuração de cobertura.

| Critério | Evidência | Resultado |
| --- | --- | --- |
| 1 — Contratos observáveis | Campos textuais com label, valor e restrições; identidade derivada e sobrescrita; erros singulares e com contagem; supressão para campos não usados; hidden; checkbox com fallback falso e estados checked/disabled; select simples/múltiplo; textarea multiline com escape de markup; flash presente/ausente, prioridade do slot e comando de dispensa; botões/links; header; página inicial com links, temas e avisos de conexão. Seletores e asserções sobre HTML renderizado com LiveViewTest e LazyHTML. | 14 testes novos aprovados, capazes de detectar remoção ou alteração dos resultados exercitados. |
| 2 — Suíte e cobertura | `mix test --cover` antes: 7 aprovados, total 35,18%, saída 3 pelo limiar. Depois: 21 aprovados, total 75,38%, saída 0. Mesmo conjunto de 17 módulos e limiar de 70%, sem exclusões. | Atendido. `PlannerWeb.CoreComponents` passou de 17,07% para 82,11%. |
| 3 — Gates | `mix precommit`: 21 aprovados, saída 0. `mix ci`: compilação e formatação aprovadas, Credo estrito sem achados, 21 aprovados, cobertura 75,38%, saída 0. `git diff --check` sem erros. | Atendido na árvore de trabalho sobre a base indicada; integração da entrega ainda pendente. |
| 4 — Revisão e integração | Autoavaliação pelo fluxo de review, limitada aos dois arquivos novos e este registro. | Revisão independente e integração pendentes; BLOCK-001 não encerrado pelo implementador. |

A primeira execução dos testes novos revelou problemas no próprio teste (helper com nome em conflito com macro, seleção apenas dos nós raiz e atributo não declarado no componente); eles foram corrigidos dentro do escopo antes dos gates. Como a tarefa apenas acrescenta testes de comportamento existente, não houve alteração de produção nem ciclo de implementação de funcionalidade.

Limites: testes exercitam renderização e comandos declarados, sem executar JavaScript em navegador. O relatório ainda mostra `PlannerWeb.PageHTML` com 0%; seu HTML de cobertura assinala somente a linha 1 (`defmodule`), embora o novo teste invoque diretamente `home/1` e o teste existente faça GET `/`. Não se adicionaram chamadas artificiais para aumentar essa métrica. Cobertura de linhas não demonstra todos os ramos; tabelas e listas não receberam cenários nesta entrega. A suíte usa o banco de testes configurado no README, sem reset.

Autoavaliação: critérios 1–3 atendidos, sem achados bloqueantes identificados; não constitui aprovação independente. Encaminhado ao coordenador para revisão dos arquivos novos, integração e resolução do BLOCK-001. A revisão própria da TASK-002 continua necessária antes de liberar consumidoras.

### Revisão independente — 23/09/2026

Revisor: coordenador `/root`, independente da implementação. Resultado: `approved`. Alvo: os dois arquivos novos de testes e este registro sobre `d25f6c9`; alterações preexistentes de outros documentos excluídas da entrega. Asserções conferidas contra os componentes existentes, incluindo erros, valores, escape e estrutura da página; nenhum achado bloqueante.

Validação independente: `POSTGRES_TEST_DB=planner_coord_20260923 mix ci`, saída 0, 21 testes aprovados, cobertura total 75,38%, Credo sem achados. Banco isolado preparado pelo alias, sem reset. `mix precommit` aprovado conforme evidência do implementador; não repetido por não haver alteração posterior de código. Critérios 1–3 atendidos; revisão do critério 4 aprovada, aguardando registro do commit para conclusão. Limites de cobertura e ausência de execução JavaScript em navegador permanecem os registrados acima.
