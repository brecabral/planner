---
id: "TASK-054"
status: planned
execution_level: standard
execution_rationale: "Integra layout, eventos LiveView, hook e CSS compilado com preferência autorizada já existente; exige reprodução da falha e regressão no navegador."
specs: ["SPEC-007"]
depends_on: ["TASK-048", "TASK-052"]
provides: ["navbar-theme-selection"]
consumes: ["user-theme-switching"]
write_scope: ["lib/planner_web/components/layouts.ex", "lib/planner_web/components/layouts/root.html.heex", "lib/planner_web/live/task_live/index.ex", "assets/css/app.css", "assets/js/account_theme.js", "assets/js/account_theme.test.mjs", "assets/js/app.js", "priv/gettext/", "test/planner_web/live/task_live/", "test/planner_web/components/", "test/planner_web/controllers/page_controller_test.exs", "docs/tasks/054-corrigir-temas-na-navbar.md"]
blockers: []
---

# 054 — Corrigir troca de temas e mover seletor para a barra superior

## Objetivo e entradas

Entregar [SPEC-007 RN03–RN05/RN07–RN08 e CA-007-02–07](../specs/007-temas-e-creditos.md). TASK-048 e TASK-052 estão concluídas na base; a dependência de 052 serializa mudanças posteriores ao seu escopo de componentes. Ler Layouts/root, TaskLive.Index (render/mount/select_theme), AccountTheme, registro do hook em app.js, paletas em app.css e testes de tema. Consultar Themes apenas para o contrato de seleção existente. Referências: interface, LiveView, interop JavaScript, HEEx, Gettext e testes.

## Fatos e diagnóstico necessário

O código atual coloca botões de tema em um fieldset no corpo do painel; a barra tem apenas a saída. Há duas paletas e um hook que escreve no elemento HTML. O usuário relata falha na troca; não há reprodução nem causa comprovada neste planejamento. Reproduzir em navegador com assets compilados e registrar caminho/resultado antes de corrigir; investigar evento, persistência, lifecycle do hook e CSS efetivamente aplicado. Não tratar alteração de `data-theme` isolada como prova de correção.

## Escopo e contratos

Única produtora da correção de aplicação visual e do seletor na navbar. Reutilizar a seleção autorizada em Themes e estado da LiveView; o layout recebe o necessário para renderizar o controle sem criar outra fonte de preferência. Usar seleção compacta com rótulo e opções traduzidos conforme RN07. Retirar seletor antigo e manter erro/processamento junto ao novo controle. Preservar aplicação inicial do servidor e sincronização após patches/reconexão, saída e troca de conta.

Não alterar domínio, concessões, migrations, autenticação, cadastro/login, regras de planejamento ou dependências. Se o diagnóstico exigir alteração fora desse contrato, registrar impedimento e devolver ao planejamento com evidência, sem ampliar o escopo.

## Aceite e testes

1. CA-007-05: único controle na navbar imediatamente antes de Sair, valor atual, teclado/foco e comportamento responsivo; sem seletor público.
2. CA-007-06: claro → escuro → claro altera visual computado em navegador, inclusive barra, painel e formulário. Confirmar entrada direta, navegação, patch, recarga e reconexão.
3. CA-007-02/03/07: persistência por conta, isolamento, rejeição de opção inválida e falha mantendo seleção/paleta confirmadas, feedback e possibilidade de tentar novamente.
4. Regressão enxuta que falhe para a causa reproduzida; testes LiveView para controle/evento/erro, teste do hook quando necessário e assets compilados. Preservar testes de domínio existentes. Registrar evidência de navegador; teste com DOM simulado não prova paleta visível.

## Validação e entrega

Executar conforme README e consultar `mix help` antes de tarefas Mix. Finalizar com `mix precommit` e cobertura mínima existente de 70%. Registrar causa reproduzida, correção, cenários observados, comandos/resultados, limitações e commit. Autoavaliação segue fluxo de review; conclusão exige conferência operacional e integração pela coordenação, sem revisão independente automática. Impedimentos seguem docs/blocks/README.md.

## Estado

Planejada em 14/10/2026; dependências concluídas na base. Implementação e diagnóstico em navegador não iniciados. Pode ocorrer independentemente de TASK-053: escopos de escrita separados.
