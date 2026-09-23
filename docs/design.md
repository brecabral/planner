# Decisões de design e arquitetura

## D01 — Phoenix e PostgreSQL

Manter a stack existente, `Planner.Repo` e um monólito Phoenix. Não há necessidade de serviços separados ou filas para o fluxo diário.

## D02 — Documentação por responsabilidade

PRD define escopo; specs definem comportamento; tarefas contêm execução, bloqueios e evidências; DDD nomeia conceitos; este arquivo registra decisões de arquitetura. Referências técnicas ensinam uso do framework. Instruções operacionais ficam somente no README. Consultar apenas o contrato pertinente ao trabalho.

## D03 — Remover o experimento antes de modelar

Remover integralmente a geração de Task, inclusive sua migration, conforme decisão do responsável. O novo modelo parte de base limpa, sem compatibilidade com dados experimentais. Execução da remoção e reset têm registros nas respectivas tarefas; não derivar o produto dos campos do gerador.

## D04 — Painel LiveView

Usar LiveView para o painel autenticado, reaproveitando Index/Form do gerador e componentes existentes, Tailwind e CSS próprio. Contextos validam regras e persistem operações; a interface apresenta resultados e mantém estado visual coerente. Não depender de processo web para efetivar a virada do dia no domínio.

## D06 — Persistência e concorrência por usuário

Tarefas e labels pertencem a uma conta. Todas as consultas e comandos recebem escopo autenticado, atribuindo proprietário no servidor. Vínculos tarefa/label não podem cruzar proprietários.

Persistir cota por usuário/data independentemente da lista de pendências: seleção consome, retirada manual restitui e conclusão mantém consumo. Escolha, restituição, posições e vínculos são transacionais; o bloqueio deve proteger também o conjunto vazio, sem serializar desnecessariamente usuários distintos. Definir constraints e mecanismo concreto na implementação do domínio.

Labels têm relação muitos-para-muitos com tarefas. Cadastro de tarefa com labels novas é uma transação única. O histórico preserva a data original da conclusão.

## D08 — Contas e data individual

Acesso remoto exige autenticação e isolamento em HTTP, LiveView e contexto. Uma única abstração calcula o dia a partir do instante e do fuso persistido na conta; não usar fuso global da instalação. Alteração de fuso deve compor com as transações de planejamento conforme a política da SPEC-003.

Mecanismo de autenticação e hospedagem permanecem decisões de suas entregas. Segredos e configurações de ambiente ficam externos ao código.

## D09 — Idiomas com Gettext

Manter `PlannerWeb.Gettext`, mensagens-base em inglês e catálogos `pt_BR`/`en`. Aplicar locale por requisição/processo LiveView sem estado global que afete outra sessão. Conteúdo do usuário permanece inalterado. Preferência e fallback são definidos na [SPEC-001](specs/001-idiomas.md).

## D14 — Geração seguida de incrementos pequenos

Priorizar geradores Phoenix para autenticação, contexto/schema, LiveViews e release. Cada recurso tem uma única tarefa geradora; as próximas preservam o scaffold e acrescentam regras delimitadas. Gerar a interface com `--no-context` quando domínio e schema já existem. Comandos e ajustes pertencem às tarefas; as specs mantêm a arquitetura e os casos de uso agregados.
