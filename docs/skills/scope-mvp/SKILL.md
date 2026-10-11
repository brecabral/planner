---
name: scope-mvp
description: Delimitar o MVP do Planner e separar evolução futura quando o usuário reduzir ou redefinir o escopo do produto, antes de decompor tarefas.
---

# Delimitar o MVP

Ler o pedido e somente os trechos pertinentes do PRD, specs e decisões arquiteturais. Atuar como planejador; não implementar os atalhos propostos.

- Distinguir resultado essencial do usuário, suporte técnico indispensável e capacidade da solução final. Uma decisão arquitetural futura não se torna automaticamente funcionalidade do MVP.
- Para cada capacidade adiada, definir como o fluxo mínimo funciona sem ela. Registrar a alternativa concreta e seus limites na fonte competente, sem criar infraestrutura especulativa. Conferir as decisões atuais do PRD em vez de cristalizar escolhas históricas nesta skill.
- Preservar padrões do framework que não exigem uma funcionalidade adicional. Usar Gettext, por exemplo, não implica oferecer seletor de idioma. Verificar os contratos técnicos aplicáveis antes de simplificá-los.
- Separar dúvidas que impedem comportamento observável de escolhas adiáveis. Incorporar respostas explícitas já dadas pelo usuário; perguntar apenas o que altera a entrega e continua sem resposta.
- Atualizar escopo no PRD, comportamento nas specs e decisões técnicas no design apenas quando cada fonte for afetada. Não repetir a mesma explicação em todas elas.
- Ao ajustar tarefas, usar [plan-task-graph](../plan-task-graph/SKILL.md). Capacidades futuras não podem permanecer como pré-requisitos do MVP por inércia; preservar IDs e registrar seu adiamento segundo o formato vigente.

Entregar a fronteira do MVP, as decisões realmente pendentes e o próximo trabalho elegível. Teste de consistência: o usuário consegue completar o fluxo mínimo sem depender de uma capacidade adiada, e cada requisito mantido tem uma razão concreta para existir nesta entrega.
