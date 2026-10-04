---
id: "TASK-028"
status: "in_review"
execution_level: "standard"
execution_rationale: "Integra duas transições existentes ao painel com tratamento de limite, conflito e falha."
specs: ["SPEC-002", "SPEC-004"]
depends_on: ["TASK-027"]
provides: ["planning-selection-ui"]
consumes: ["planning-panel-read", "select-today", "return-to-backlog"]
write_scope: ["lib/planner_web/live/task_live/index.ex", "priv/gettext/", "test/planner_web/live/task_live_test.exs"]
blockers: []
---

# 028 — Ligar seleção e devolução no painel

## Entrada e limite

[SPEC-002](../specs/002-planejamento-diario.md) CA-002-02/03/05 e [SPEC-004](../specs/004-experiencia-e-acesso.md) RN03–RN05; consumir planning-panel-read, select-today e return-to-backlog.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Adicionar ações trazer para hoje no backlog/retry e devolver ao backlog em hoje. Recarregar snapshot após sucesso/conflito; mostrar processamento, limite e falha sem falso sucesso. IDs em eventos não substituem usuário passado pelo servidor.

## Aceite e teste de intenção

1. Selecionar consome; devolver libera uma vez e volta ao backlog. Retry só recebe virada automática.
2. Quarta escolha e evento forjado falham sem estado visual incorreto.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Implementação entregue para conferência operacional do coordenador em 04/10/2026; integração e commit pendentes.

- Alvo: alterações locais em `index.ex`, catálogos Gettext e `task_live_test.exs`, sobre a base `fc53790`. Autoavaliação pelo implementador `/root/implement_mvp`, conforme fluxo de review, sem atribuir aprovação independente nem alterar seu marco.
- Critério 1: teste LiveView seleciona backlog e retry, repete seleção sem consumo adicional, devolve e repete devolução sem restituição adicional; verifica identidade, labels, prioridade compactada, retorno ao backlog e persistência após remontagem. Controles consomem os casos de uso existentes com usuário do servidor.
- Critério 2: teste mantém a cota esgotada após três escolhas e uma conclusão em outra sessão, rejeita a quarta escolha e recompõe listas/contadores; IDs alheios, inexistentes e malformados, proprietário/data forjados e devolução de concluída não alteram o domínio.
- Falhas: dois testes impõem constraints SQL temporárias para falhar consumo/restituição depois da movimentação. Erro acessível é mostrado, transação reverte tarefa e cota, sem confirmação otimista.
- Processamento/acessibilidade: formulários nativos com botões nomeados, `phx-disable-with` traduzido, foco visível e destino estável por `JS.focus`; erros usam `role=alert`; botões permitem quebra de linha e largura limitada. Inspeção de template e testes de atributos; teclado, bloqueio durante envio e layout em navegador a 360px/desktop não foram exercitados visualmente.
- TDD: primeiro teste do arquivo resultou em 8 testes existentes aprovados e 3 novos falhando pela ausência dos controles; após implementação e adição do cenário de falha na devolução, suíte completa com 118 testes aprovados.
- Gates: `mix precommit` aprovado; `mix ci` aprovado com Credo sem achados, 118 testes e cobertura total de 91,14%, `PlannerWeb.TaskLive.Index` 96,34% (limiar preservado em 70%). `git diff --check` aprovado. Extração Gettext e mesclagem pt_BR atualizadas.
- Autoavaliação: critérios de domínio atendidos, sem achados bloqueantes. Caminhos de indisponibilidade da leitura têm mensagem explícita e preservam snapshot anterior, mas não receberam injeção de falha nesta entrega. Concorrência/virada permanecem contratos transacionais cobertos pelo contexto; não foram reimplementados na interface.
- Alterações operacionais preexistentes fora do escopo foram preservadas. Consumidora aguarda conferência e integração pelo coordenador.
