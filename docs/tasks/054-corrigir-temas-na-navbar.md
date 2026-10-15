---
id: "TASK-054"
status: in_review
execution_level: standard
execution_rationale: "Integra layout, eventos LiveView, hook e CSS compilado com preferência autorizada já existente; exige reprodução da falha e regressão no navegador."
specs: ["SPEC-007"]
depends_on: ["TASK-048", "TASK-052"]
provides: ["navbar-theme-selection"]
consumes: ["user-theme-switching"]
write_scope: ["lib/planner_web/components/layouts.ex", "lib/planner_web/components/layouts/root.html.heex", "lib/planner_web/live/task_live/index.ex", "assets/css/app.css", "assets/js/account_theme.js", "assets/js/account_theme.test.mjs", "assets/js/app.js", "priv/gettext/", "test/planner_web/live/task_live/", "test/planner_web/components/", "test/planner_web/controllers/page_controller_test.exs", "test/planner_web/theme_test.exs", "docs/tasks/054-corrigir-temas-na-navbar.md"]
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

Implementada em 15/10/2026, encaminhada à conferência operacional. Dependências TASK-048/TASK-052 integradas; TASK-053 foi integrada separadamente durante esta execução. Commit da entrega: a registrar pelo coordenador após conferência.

## Ajuste de contrato — 15/10/2026

Incluído `test/planner_web/theme_test.exs` no escopo de escrita: a regressão existente interage com os botões que RN07 manda remover e deve acompanhar o seletor da navbar. A adaptação preserva os cenários de persistência, isolamento, concessões e falha existentes; não altera regras de produto nem autoriza mudanças no domínio. Dependências e produtora permanecem iguais, sem conflito com TASK-053.


## Entrega e evidências — 15/10/2026

A instrução explícita atual do responsável, “nao valide no navegador, eu valido”, substitui a execução em navegador prevista nesta tarefa. Nenhum navegador foi usado. Cores computadas, legibilidade, uso real por teclado e dimensões 320/1280 px ficam para validação do responsável; não são declarados aprovados por testes de DOM mínimo.

Diagnóstico: o seletor anterior era um fieldset no corpo do painel. A inspeção encontrou as duas paletas no CSS compilado e `AccountTheme` registrado no bundle; evento e persistência existentes passaram pelos testes. Não foi reproduzida uma causa técnica para o relato original de ausência de troca visual. A entrega muda o controle e seu ciclo de confirmação; não afirma ter reproduzido ou eliminado uma causa visual desconhecida.

Implementação: `Layouts.app` recebe slot para o controle, mantendo o estado na LiveView. Um select nativo com rótulo traduzido aparece imediatamente antes de Sair; ambos ficam agrupados na mesma linha e o grupo pode quebrar após a marca em telas estreitas. Não há seletor no corpo nem nas páginas públicas. O hook encaminha a opção, bloqueia repetição e mostra processamento até a resposta. Após a resposta aplica o tema confirmado ao HTML e restaura o valor do select, inclusive quando a rejeição não produz novo diff. Desconexão bloqueia o controle; reconexão reabilita a seleção e callbacks obsoletos são ignorados. Autorização e persistência continuam em Themes, sem alterações de domínio, CSS de paletas, autenticação ou dependências.

| Critério | Evidência e resultado | Limite |
| --- | --- | --- |
| CA-007-05 | LiveView confirma único select, rótulo Tema, opções Claro/Escuro, posição antes de Sair, ausência no main/login/join. CSS existente fornece foco visível; select é nativo. | Layout e teclado reais ficam com o responsável. |
| CA-007-06 | LiveView cobre claro → escuro → claro, abertura por patch, entrada direta em `/tasks/new`, nova montagem e outro dispositivo. JS cobre montagem, patch, reconexão e aplicação ao HTML. Assets compilados contêm ambas as paletas e superfícies semânticas. | Não comprova cores computadas ou percepção visual; causa original não reproduzida. |
| CA-007-02/03/07 | Testes preservam isolamento da conta B, rejeição de código inválido/forjado/não concedido, falha real de constraint no banco, seleção confirmada e nova tentativa bem-sucedida, logout claro. JS verifica espera, duplicação bloqueada, restauração e callback obsoleto. | Harness JS é DOM mínimo, sem navegador. |
| Regressão e gates | TDD LiveView: 2 falhas esperadas por ausência de select/navbar antes da mudança, depois 5 testes aprovados. JS: 2 falhas esperadas por ausência de listener/controle de seleção, depois 3 aprovados. `mix precommit`: 245 testes aprovados. `mix ci`: 245 testes, cobertura 93,71%, Credo sem achados, assets compilados e audit npm sem vulnerabilidades. `mix cmd node --test assets/js/account_theme.test.mjs`: 3 aprovados. `git diff --check`: limpo. | Os novos testes comprovam os requisitos do controle, não reproduzem uma falha visual da versão anterior. |

## Autoavaliação

Implementador `/root/implement054`, diff local dos seis arquivos da entrega sobre a base inicial `1b5b5a8`, com TASK-053 integrada separadamente na base `183aae7`. Fluxo de review aplicado como autoavaliação, sem revisão independente e sem alterar seu marco. Conclusão técnica: `approved` para o escopo verificável do controle e sincronização, sem achados bloqueantes; aceite visual não verificado por instrução do responsável. Cobertura do CI: Layouts 100%, TaskLive.Index 98,71%, total 93,71%. Nenhuma redução de limiar ou exclusão de cobertura. A coordenação deve preservar a limitação sobre o relato visual original ao registrar a entrega.
