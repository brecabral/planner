---
id: "TASK-027"
status: "done"
execution_level: "standard"
execution_rationale: "Representa snapshot autorizado em streams e contadores coerentes após recarga."
specs: ["SPEC-002", "SPEC-004"]
depends_on: ["TASK-026"]
provides: ["planning-panel-read"]
consumes: ["planning-snapshot", "task-live-scaffold"]
write_scope: ["lib/planner_web/live/task_live/index.ex", "priv/gettext/", "test/planner_web/live/task_live_test.exs"]
blockers: []
---

# 027 — Mostrar hoje, backlog, retry e cota no painel

## Entrada e limite

[SPEC-004](../specs/004-experiencia-e-acesso.md) RN01/RN05/RN06; consumir planning-snapshot e task-live-scaffold. Referência LiveView.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Adaptar Index gerado ao snapshot com três streams e contadores/estados vazios próprios. Numerar prioridades e mostrar escolhas disponíveis. Ler snapshot na montagem/recarga e após ações próprias; não manter assinatura de eventos para sincronizar abas. Não implementar botões de transição ainda.

## Aceite e teste de intenção

1. Cada tarefa aparece na coleção correta; contagem vem do domínio e sobrevive à recarga.
2. Estado sem pendências mas com três conclusões mostra cota esgotada, não vagas livres.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Implementador `/root/implement_task025`, em 03/10/2026. Base `3617773`, com TASK-026 integrada em `b3cbf7e`. Alvo: diff local de `lib/planner_web/live/task_live/index.ex`, `test/planner_web/live/task_live_test.exs`, `priv/gettext/default.pot`, `priv/gettext/pt_BR/LC_MESSAGES/default.po` e este registro. Alterações preexistentes em instruções/documentação preservadas; sem staging/commit.

Contrato `planning-panel-read`: Index consulta `Tasks.snapshot/1` na montagem e representa backlog (`:tasks`, preservando IDs anteriores), hoje (`:today`) e retry (`:retry`) em três streams. Contagens de pendências vêm das respectivas coleções e escolhas usadas/disponíveis vêm diretamente do snapshot, sem deduzir consumo do número de pendências. Hoje recebe destaque e posição numerada; todas as coleções exibem labels e estados vazios próprios. Recarga/remontagem relê o domínio; navegação após cadastro monta o painel novamente. Sem timers, assinatura/broadcast ou botões de transição.

| Aceite | Evidência |
| --- | --- |
| 1 — coleções e recarga | Teste cria backlog, tarefa vencida e duas prioridades via APIs do contexto; duas montagens verificam coleções corretas, posições 1/2, labels intactas, contagens 1/1/2 e duas escolhas usadas/uma disponível. Outra conta não aparece no backlog e tarefas hoje/retry não aparecem nele. |
| 2 — cota após conclusões | Teste seleciona/conclui três tarefas por APIs reais, depois monta e recarrega: hoje tem zero pendências, três escolhas usadas e zero disponíveis, com aviso pt-BR de esgotamento e estados vazios. Nenhuma tarefa concluída aparece nas coleções pendentes. |

TDD: **2 falhas iniciais** por ausência de hoje/retry/cota; depois **8 testes LiveView aprovados**. `rtk mix precommit` e `rtk mix ci`: **114 testes aprovados**, compilação/formatação/Credo estrito aprovados, cobertura total **91,16%**, Index **100%**, limiar mínimo 70% preservado. `rtk git diff --check` aprovado. Ajuda Mix consultada nesta sessão; mensagens/plurais extraídos e traduzidos no catálogo pt_BR.

Autoavaliação pelo fluxo de review: aceites atendidos, sem achados bloqueantes no diff da entrega. Não houve alteração de domínio, inferência de cota pelas pendências ou sincronização automática. Limitações: testes LiveView/HTML, sem navegador real; visibilidade dos estados vazios usa padrão `hidden only:block` dos streams. Operações de seleção/devolução/ordem/conclusão e acesso ao histórico aguardam tarefas próprias.

Estado `in_review`, encaminhado à conferência superficial e integração do coordenador, sem revisão independente alegada. Conforme pedido do usuário para parar na próxima tarefa, nenhuma tarefa seguinte foi iniciada.

### Conferência operacional — 03/10/2026

Coordenador `/root`: registro e resumo conferidos superficialmente; gates locais relatados aprovados (114 testes, cobertura 91,16%), sem impedimentos. Entrega integrada em `4611036`; TASK-028 elegível, mas não iniciada por pedido explícito de parada. Restam TASK-028, TASK-029, TASK-030, TASK-032 e TASK-008 para o MVP. Sem revisão independente ou verificação de CI remoto.


### Revisão independente de prontidão — 05/10/2026

Revisor `/root`; alvo `ce0f72bb59eb27efa0a60e867f93242c2e805916`, base `aafed16d7b7a09000404e716cc98dcc43763510e`. Nenhum achado adicional neste escopo; o aceite global do MVP permanece com alterações solicitadas por R1 no cadastro. CI e precommit reproduzidos: 136 testes aprovados; cobertura total 92,16%. Evidências, reprodução, critérios e limites no [relatório de revisão](../review.md#revisão-de-prontidão-do-mvp--05102026). Registro operacional anterior preservado; esta revisão não presume validação humana ou CI remoto.
