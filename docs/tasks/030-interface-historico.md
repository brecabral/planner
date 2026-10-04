---
id: "TASK-030"
status: "done"
execution_level: "standard"
execution_rationale: "Integra conclusão e consulta histórica existentes sem alterar a regra de consumo."
specs: ["SPEC-003", "SPEC-004", "SPEC-006"]
depends_on: ["TASK-029"]
provides: ["history-ui"]
consumes: ["planning-order-ui", "complete-task", "history-query"]
write_scope: ["lib/planner_web/live/task_live/index.ex", "priv/gettext/", "test/planner_web/live/task_live_test.exs"]
blockers: []
---

# 030 — Ligar conclusão e consulta de histórico

## Entrada e limite

[SPEC-003](../specs/003-dia-e-historico.md) CA-003-03/05/06 e [SPEC-004](../specs/004-experiencia-e-acesso.md) CA-004-05/06; consumir complete-task, history-query e planning-order-ui.

## Scaffold

Não executar gerador: adaptar o recurso produzido pelas dependências, sem recriar seu scaffold.

## Ajustes desta entrega

Adicionar concluir e histórico acessível no painel existente, com labels e data original. Atualizar snapshot após conclusão sem restituir cota. Não gerar um novo CRUD para conclusões.

## Aceite e teste de intenção

1. Conclusão repetida aparece uma vez no histórico e mantém escolha usada.
2. Três conclusões deixam hoje vazio com cota esgotada; histórico próprio e labels persistem na recarga.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Implementador `/root/implement_mvp`, 04/10/2026. Base `7f51200` com TASK-029 integrada; alvo da autoavaliação: diff local de `index.ex`, catálogos Gettext e `task_live_test.exs`. Sem staging/commit; integração e conferência operacional pendentes. Autoavaliação não é aprovação independente nem altera seu marco.

- Critério 1: teste conclui pela interface e repete evento com data forjada. Histórico contém uma tarefa, título/labels originais e data persistida, com consumo mantido após remontagem. Outro teste repete conclusão de ontem e confirma a data original e a ordenação, sem refundir consumo de hoje.
- Critério 2: três conclusões pela interface deixam hoje vazio e escolhas esgotadas; histórico permanece ordenado por data/ID decrescentes, inclui apenas tarefas próprias e persiste na remontagem. Teste anterior de vazio foi ajustado para limitar sua ausência de títulos à seção hoje, pois títulos concluídos agora aparecem no histórico.
- Conflitos e falhas: devolução por outra sessão torna conclusão antiga inválida e recompõe backlog/cota; IDs alheios/malformados/inexistentes e proprietário forjado não produzem conclusão. Constraint SQL temporária força falha real de gravação e verifica tarefa ainda pendente, histórico vazio e consumo mantido com erro acessível.
- Interface: conclusão usa botão/formulário nativo, bloqueio durante envio, foco visível e destino no cabeçalho do histórico. Histórico é seção nomeada com estado vazio, contagem traduzida, labels e `<time datetime>` com data pt-BR, sem hora/reabertura/exclusão. Coleção usa stream; consulta é sempre limitada ao usuário do servidor. Não há timer ou atualização automática de outras abas.
- TDD: 15 testes existentes aprovados e 4 novos falhando por controles/histórico ausentes antes da implementação; depois 19 testes LiveView aprovados.
- Gates: `mix precommit` e `mix ci` aprovados, 125 testes, Credo estrito sem achados; cobertura total 91,91%, Index 97,64% (antes 91,60%/97,22%), limiar de 70% preservado. Gettext extraído/mesclado em pt_BR; `git diff --check` aprovado.
- Autoavaliação pelo fluxo de review: aceites funcionais atendidos, sem achados bloqueantes. Sem teste visual em navegador de teclado, foco e viewport 360px; verificação estrutural por template/testes. Persistência após reinício real e concorrência são contratos cobertos nas tarefas do domínio, não repetidos nesta integração de interface.
- Alterações operacionais preexistentes preservadas; TASK-032 não iniciada.

### Conferência operacional — 04/10/2026

Coordenador `/root`: registro e resumo conferidos superficialmente, sem impedimentos. Gates locais relatados aprovados: 125 testes, cobertura 91,91%. Entrega integrada na branch `feat/mvp` em `7b98d09`; TASK-032 liberada. Sem revisão independente ou verificação de CI remoto. Verificações de navegador e reinício seguem nas etapas de acessibilidade e aceite final.
