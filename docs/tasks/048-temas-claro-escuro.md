---
id: "TASK-048"
status: "planned"
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
