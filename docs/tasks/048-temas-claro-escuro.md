---
id: "TASK-048"
status: "done"
execution_level: "standard"
execution_rationale: "Integra concessões e preferência pronta aos tokens semânticos e renderização inicial autenticada."
specs: ["SPEC-007", "SPEC-004"]
depends_on: ["TASK-047"]
provides: ["user-theme-switching"]
consumes: ["user-theme-entitlements"]
write_scope: ["assets/css/app.css", "assets/js/", "lib/planner_web/", "priv/gettext/", "test/planner_web/", "README.md", "docs/tasks/048-temas-claro-escuro.md"]
blockers: []
---

# 048 — Oferecer temas claro e escuro por usuário

## Objetivo e entradas

Entregar SPEC-007 RN03–RN05/CA-007-02–04 e SPEC-004 RN20. Ler Themes e preferência da TASK-047, root/layouts, CSS/hook atuais, design D19 e referências interface/LiveView/interop/Gettext/testes. Reutilizar daisyUI e bundle; sem nova biblioteca, imagem gerada ou CSS arbitrário por usuário.

## Aceite e testes

1. Preservar claro planner e adicionar planner_dark; seletor pt-BR lista temas concedidos gratuitamente. Persistir escolha antes de confirmar sucesso; falha conserva tema confirmado e informa erro.
2. Render inicial autenticado já usa tema autorizado; patches e reconexão conservam escolha. A/B e novo dispositivo provam preferência por conta; logout/login público usam claro sem herdar localStorage de outra conta.
3. Paletas cobrem painel, menus à esquerda, cadastro, confirmação de exclusão, histórico, erros e arraste através de tokens semânticos. Assets compilam; testes verificam atribuição e eventos sem alegar contraste/gesto real não executado.
4. Não expor loja, preço, crédito ou compra. Atualizar README apenas para comportamento realmente entregue.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.


## Entrega e evidências — 13/10/2026

- Dependência TASK-047 integrada em `839951e`, conclusão registrada em `842b684`; execução desta tarefa sobre `842b684`, sem bloqueios.
- Seletor com botões Claro/Escuro traduzidos, limitado às concessões consultadas em Themes. O evento passa o payload integral ao contrato, rejeitando proprietário forjado e código desconhecido. Estado visual só muda após persistência; erro conserva confirmação e mostra aviso traduzido.
- Root autenticado resolve preferência autorizada antes de enviar HTML. Hook AccountTheme sincroniza o atributo do documento em montagem, patch e reconexão e restaura claro na saída. Não lê localStorage, cookies globais de tema ou preferência do sistema.
- Paleta `planner` preservada e `planner_dark` adicionada com todos os tokens semânticos. Painel, menu à esquerda, cadastro, confirmação, histórico, flashes e arraste já consomem esses tokens; inspeção não encontrou cores fixas nessas superfícies.
- README documenta comportamento entregue e teste técnico do hook. Nenhuma superfície de compra, preço ou crédito foi criada.

### Validação e autoavaliação

Autoavaliação pelo implementador `/root/implement_048`, conforme fluxo de review: diff local da TASK-048 contra `842b684`, incluindo novos arquivos de hook/testes. Conclusão técnica `approved`, sem revisão independente e sem avançar marco de `docs/review.md`.

| Critério | Evidência | Resultado |
| --- | --- | --- |
| 1 — seletor/concessões/persistência/erro | `test/planner_web/theme_test.exs`: tradução, sucesso, código inválido, propriedade forjada, concessão ausente e rejeição SQL controlada | 5 testes web passaram; preferência e tema confirmado preservados nas falhas |
| 2 — HTML inicial/patch/reconexão/A-B/dispositivo/logout | Mesmo arquivo: root renderizado, patch de cadastro, nova montagem/sessão, conta B e login após logout; `assets/js/account_theme.test.mjs` cobre callbacks do hook | Passou; HTML autorizado e nenhuma preferência global |
| 3 — paletas/estados/assets | Inspeção dos componentes e CSS; `mix ci`; `mix cmd node --test assets/js/account_theme.test.mjs` | Assets compilados; 1 teste JS passou; sem prova de contraste ou gesto real |
| 4 — escopo e README | Inspeção do diff e mensagens extraídas | Somente dois temas gratuitos e documentação do comportamento entregue |

- TDD: testes iniciais falharam pela ausência do seletor/evento; o teste de login foi ajustado para visitante porque login autenticado já redireciona ao dashboard.
- Ajuda Mix consultada antes dos comandos. `mix precommit`: **240 testes, 0 falhas**. Primeiro CI apontou somente aliases (Credo), corrigidos antes da execução final.
- `mix ci` final: **240 testes, 0 falhas**, Credo sem achados, cobertura **94,08%** (Layouts 100%, TaskLive.Index 98,72%), assets compilados e auditoria npm sem vulnerabilidades. Limiar de 70% preservado.
- Extração/mesclagem Gettext restrita ao catálogo pt_BR, com as quatro mensagens novas traduzidas. `git diff --check` sem erros.
- Limites: LiveViewTest e DOM mínimo verificam atribuições/eventos, não executam navegador, contraste visual, gestos reais ou reinício de processo. Persistência após nova sessão/montagem é coberta usando o banco real de teste.
- Aguardando conferência operacional e commit de integração pelo coordenador; não iniciar consumidoras antes da integração. Nenhuma publicação realizada.

### Conferência operacional — 13/10/2026

Coordenador `/root`: entrega integrada em `1f388fe` na branch `feat/ux`. Conferidos escopo, autoavaliação, gates relatados aprovados (240 testes, cobertura 94,08% e teste JavaScript aprovado) e ausência de impedimentos. Sem reprodução de testes ou revisão independente. Limites de validação visual preservados. Conclusão operacional libera TASK-011; TASK-049 permanece fora do MVP e bloqueada por decisões próprias.

### Revisão independente — 13/10/2026

Revisor `/root`, alvo `b0810ba49cf6049c7d5aac49960950a5236be22b`, base reconstruída `367bf3555bc2b06e5ce90aedc2118e46e00986de`. Sem achado bloqueante identificado no contrato desta entrega. Parecer global changes_requested por R3 no cadastro de contas. `mix ci`: 240 testes aprovados, cobertura 94,08%; testes JavaScript de arraste/tema: 9 aprovados. Escopo, reprodução adicional com falha, achados documentais e limites em [docs/review.md](../review.md#revisão-das-últimas-entregas-e-documentação--13102026). Sem correção de produto ou mudança do estado operacional nesta revisão.
