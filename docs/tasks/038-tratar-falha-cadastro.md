---
id: "TASK-038"
status: "in_review"
execution_level: "standard"
execution_rationale: "Integra tratamento delimitado de exceções no formulário com preservação de entradas, tradução e teste de rollback no contrato existente."
specs: ["SPEC-004", "SPEC-006"]
depends_on: ["TASK-037"]
provides: ["task-registration-failure-feedback"]
consumes: ["task-label-form", "task-create-with-labels"]
write_scope: ["lib/planner_web/live/task_live/form.ex", "priv/gettext/", "test/planner_web/live/task_live_test.exs", "docs/tasks/038-tratar-falha-cadastro.md"]
blockers: []
---

# 038 — Tratar falha de persistência no cadastro

## Objetivo e contexto

Corrigir R1 da [revisão de prontidão](../review.md#revisão-de-prontidão-do-mvp--05102026): exceção de persistência em `Tasks.create_task/2` encerra a LiveView de cadastro. Cumprir PRD CA09 e [SPEC-004](../specs/004-experiencia-e-acesso.md) RN04/RN06 e CA-004-03, preservando a atomicidade de [SPEC-006](../specs/006-labels.md) RN02–RN04 e CA-006-04.

Entradas: formulário em `lib/planner_web/live/task_live/form.ex`, testes em `test/planner_web/live/task_live_test.exs`, cadastro atômico da [TASK-019](019-cadastro-labels-atomico.md) e formulário da [TASK-026](026-formulario-labels.md). Consultar o tratamento de persistência do painel em `lib/planner_web/live/task_live/index.ex` como padrão existente. Referências aplicáveis: [LiveView](../referencias/liveview.md), [formulários](../referencias/formularios.md), [Gettext](../referencias/gettext.md), [Ecto](../referencias/ecto.md) e [testes](../referencias/testes.md).

TASK-037 está integrada em `015eb6d`; sua dependência serializa o ajuste com todas as entregas atuais que alteraram formulário, catálogos e testes. TASK-026 e TASK-019 são ancestrais dessa dependência. Não reabrir nem repetir tarefas humanas já aceitas.

## Alteração e limites

Adaptar o formulário existente, sem gerador. Tratar exceções pertinentes de persistência (`Ecto.ConstraintError`, `Postgrex.Error` e `DBConnection.ConnectionError`) na fronteira da chamada de cadastro, após rollback da transação. Manter a LiveView e as entradas, apresentando erro visível em pt-BR via Gettext, sem navegar ou anunciar sucesso. Não capturar indiscriminadamente erros de programação nem alterar o contrato transacional para ocultar falhas.

Preservar tratamento de changesets, proprietário resolvido no servidor, seleção de labels e criação atômica. Sem alteração de schema, migration, contexto de domínio, bootstrap de usuário ou política de reconexão. Validação humana em navegador continua fora dos gates, conforme o PRD.

## Aceite e testes de intenção

1. Dado formulário aberto com título válido, labels próprias selecionadas e nomes de novas labels, quando a gravação lança exceção de persistência, o mesmo processo LiveView permanece ativo, exibe alerta traduzido e preserva título, seleção e nomes informados; não há navegação nem mensagem de sucesso.
2. A falha não deixa tarefa, novas labels ou vínculos parciais e preserva registros anteriores. Reproduzir R1 com constraint temporária no banco de testes, isolada e revertida pelo SQL Sandbox, sem migration de produção. O teste deve observar resposta da interface e persistência, não apenas a presença de um `rescue`.
3. Removida a causa da falha no teste, reenviar o formulário preservado cadastra uma única tarefa com os vínculos esperados e segue o fluxo normal de sucesso. Validação de campos inválidos e rejeição de labels alheias continuam funcionando.
4. Exercitar os caminhos adicionais de erro PostgreSQL/conexão de forma determinística com os recursos existentes, sem desligar banco compartilhado ou adicionar dependência. Se a infraestrutura não permitir verificar um caminho dentro do escopo, registrar o impedimento conforme o protocolo, sem substituir evidência por suposição.

## Evidências esperadas

Aplicar TDD enxuto: registrar a falha observável do teste de R1 antes do ajuste e sua aprovação depois. Consultar ajuda Mix antes das tarefas; executar os gates do [README](../../README.md), incluindo precommit e CI com cobertura mínima de 70%. Registrar testes, cobertura, autoavaliação conforme o fluxo de review e limitações reais nesta tarefa. Conferência operacional e integração seguem o fluxo de coordenação; a implementação não altera o review histórico nem seu marco de aprovação.

## Estado do planejamento

Planejada em 05/10/2026 a partir de R1. Dependência integrada e specs prontas; próxima tarefa elegível do MVP. Nenhuma correção de código ou revalidação de CA09 foi executada nesta etapa. Após a entrega, nova revisão pode verificar R1 sobre o diff integrado sem presumir aprovação pelo gate automatizado.


## Implementação e evidências — 05/10/2026

Implementador `/root/coordinate_task038/implement_task038`. Base `30b2fd4efa7c828c4d7ef3ac7bc8de620f11f5b9`; alvo da autoavaliação: diff local de `lib/planner_web/live/task_live/form.ex`, `priv/gettext/default.pot`, `priv/gettext/pt_BR/LC_MESSAGES/default.po`, `test/planner_web/live/task_live_test.exs` e este registro. Dependência TASK-037 concluída e integrada. Alterações documentais preexistentes preservadas; staging e integração reservados ao coordenador.

Entrega: captura restrita a `Ecto.ConstraintError`, `Postgrex.Error` e `DBConnection.ConnectionError`, somente ao redor de `Tasks.create_task/2`, fora da transação. A resposta reconstrói os formulários com os parâmetros submetidos e apresenta alerta via Gettext: “Não foi possível cadastrar a tarefa. Tente novamente.” Nova submissão limpa o alerta anterior, mantendo o tratamento existente de changesets e sucesso. Não houve alteração no contexto, schema, migrations, resolução do proprietário ou política de reconexão.

| Aceite | Evidência observada |
| --- | --- |
| 1 — processo, alerta e entradas | Três testes LiveView submetem diretamente título, label própria e dois nomes novos com espaços/quebra de linha, sem depender de validação anterior. O mesmo processo monitorado responde com alerta `role=alert` em pt-BR; título, seleção e texto exato permanecem no formulário, sem flash de sucesso ou navegação. |
| 2 — rollback integral | Constraint temporária em `task_labels` rejeita o vínculo da primeira label nova após inserir tarefa, duas labels e vínculo da label existente. Trigger de teste reproduz `Postgrex.Error` no mesmo ponto. Ambos verificam que só a tarefa, label e vínculo anteriores permanecem; DDL existe na transação do SQL Sandbox e é revertido ao terminar. Sem migration de produção. |
| 3 — reenvio e rejeições | Removida a constraint/trigger ou liberada a conexão, o teste reenvia o formulário renderizado sem fornecer novamente os valores. Exatamente uma nova tarefa e três vínculos são persistidos; ocorre navegação normal e flash de sucesso, sem alerta antigo. Testes existentes de título/nome inválido e IDs alheios/inexistentes continuam aprovados. |
| 4 — PostgreSQL/conexão | Trigger com função em `pg_temp` lança exceção PostgreSQL real. `Repo.checkout/1` mantém ocupada a conexão compartilhada do Sandbox durante a submissão, provocando `DBConnection.ConnectionError` por fila indisponível; a conexão é liberada ao retornar. Sem mocks, dependências novas, interrupção do banco ou configuração global. |

TDD: primeira execução de `rtk mix test test/planner_web/live/task_live_test.exs` teve **27/30 testes aprovados**, com três falhas por encerramento da LiveView causadas, respectivamente, pelas três exceções previstas. Após implementação, **30 testes aprovados**. O teste foi depois fortalecido para falhar após o primeiro vínculo, cobrindo também sua reversão.

Ajuda Mix consultada antes de test, gettext.extract, gettext.merge, precommit e ci. Extração/merge restritos a pt_BR, uma mensagem nova traduzida e nenhum fuzzy. Gates finais:

- `rtk mix precommit`: **139 testes aprovados**, compilação e formatação aprovadas.
- `rtk mix ci`: **139 testes aprovados**, Credo estrito sem achados e cobertura total **92,25%**, Form **98,00%**, Tasks **98,31%**; mínimo de 70% preservado. Base documentada no review: 92,16% total e 97,73% no Form.
- `rtk git diff --check`: aprovado.

Autoavaliação conforme o fluxo de review: **approved como autoavaliação**, critérios atendidos e sem achado bloqueante identificado. Captura não abrange renderização, validação local nem erros de programação; dados continuam autorizados pelo usuário resolvido no servidor e o rollback permanece responsabilidade da transação existente. O marco de revisão independente e o relatório histórico não foram alterados.

Limitações: cobertura por linhas não prova todos os cenários de conexão; o teste de conexão reproduz indisponibilidade na aquisição, não perda de comunicação durante commit. Testes via LiveViewTest, sem avaliação humana de navegador, teclado, foco ou anúncios por tecnologia assistiva. Não houve CI remoto nem publicação. Estado `in_review`, aguardando conferência operacional e commit local pelo coordenador.
