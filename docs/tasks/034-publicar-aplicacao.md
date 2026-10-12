---
id: "TASK-034"
status: "planned"
execution_level: "standard"
execution_rationale: "Entrega artefato já aceito em destino definido e verifica acesso e persistência remotos."
specs: ["SPEC-008"]
depends_on: ["TASK-050"]
provides: ["remote-runtime-delivery"]
consumes: ["verified-production-candidate"]
write_scope: ["README.md", "docs/tasks/034-publicar-aplicacao.md"]
blockers: ["Definir destino/domínio e acesso de publicação; publicação remota requer autorização específica quando o resultado estiver pronto."]
---

# 034 — Publicar o MVP de produção validado

## Objetivo e entradas

Publicar o artefato da TASK-050 conforme SPEC-008 CA-008-04 e CA16 do PRD. Planejamento atual não publica nem cria recursos externos. Destino, operação, e-mail e restauração devem estar definidos e documentados; consumir release/configuração sem regenerar artefato diferente do validado.

## Aceite e limites

1. Registrar versão/commit/artefato e destino; executar migrations sem reset ou perda de dados, preservando configuração externa.
2. Verificar HTTPS, home/login, entrega de magic link e dashboard privado após publicação, com contas de teste autorizadas; ausência das rotas dev e disponibilidade dos dois temas.
3. README registra endereço e operação realmente implantada; tarefa registra evidência e limitações. Falha de publicação não equivale a conclusão. Não incluir créditos, compras ou migração automática de dados default.

## Execução, validação e conclusão

Antes de iniciar, conferir dependências integradas e specs prontas. Aplicar o fluxo de implementação, TDD enxuto aos comportamentos alterados e referências técnicas pertinentes. Consultar a ajuda Mix antes de tarefas/geradores. Registrar autoavaliação pelo fluxo de review, testes/gates executados e limites; finalizar com `mix precommit` e `mix ci` conforme README, mantendo cobertura mínima de 70%. Mudança em hook exige também teste JavaScript documentado; LiveViewTest não executa navegador. Revisão independente não é gate adicional automático. Registrar commit de integração e conferência operacional antes de `done`; documentação pronta não comprova implementação. Não publicar nem iniciar consumidoras automaticamente.
