---
id: "TASK-001"
status: "planned"
execution_level: "standard"
execution_rationale: "Configura pt-BR fixo no Gettext existente e traduz a interface base."
specs: ["SPEC-001"]
depends_on: ["TASK-002"]
provides: ["ptbr-interface"]
consumes: ["experimental-crud-removed"]
write_scope: ["config/config.exs", "lib/planner_web/components/layouts*", "priv/gettext/", "test/planner_web/"]
blockers: []
---

# 001 — Fixar a interface base em pt-BR via Gettext

## Objetivo e entrada

Aplicar [SPEC-001](../specs/001-idiomas.md) na infraestrutura existente: locale padrão fixo pt_BR, HTML pt-BR e traduções da interface base, com msgids em inglês. Não criar seletor, preferência em sessão, rota de idioma ou hook de troca. Cada tela futura traduz seus próprios textos. Referência Gettext.

## Aceite

1. Abrir e recarregar mantém pt-BR em HTTP/LiveView sem seletor.
2. Mensagens usadas na base são traduzidas; conteúdo digitado é preservado.

## Evidência e revisão

Pendentes. Registrar teste de intenção, precommit e CI com cobertura mínima de 70%, revisor independente, alvo/base, critérios, achados e integração.
