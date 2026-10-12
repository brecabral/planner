# Decisões de design e arquitetura

## D01 — Phoenix e PostgreSQL

Manter stack existente, `Planner.Repo` e monólito Phoenix. Sem serviços separados ou filas no MVP.

## D02 — Documentação por responsabilidade

PRD define escopo; specs agregam arquitetura e comportamento de cada capacidade; tarefas descrevem incrementos e evidências; DDD nomeia conceitos. Referências ensinam uso do framework. Operação fica somente no README.

## D03 — Remover o experimento antes de modelar

Remover geração experimental de Task, inclusive migration, e construir o modelo definido pelas specs. Não preservar compatibilidade com dados experimentais nem recriar o CRUD genérico.

## D04 — Painel LiveView

Reaproveitar Index/Form gerados. Resolver usuário padrão no servidor e chamar contextos com esse proprietário. Atualizar o resultado das ações próprias; não adicionar polling, timer ou sincronização automática entre abas. Recarga consulta o estado corrente.

## D06 — Persistência e concorrência

Tarefas e labels têm user_id do usuário padrão. APIs recebem esse usuário explicitamente; não há Accounts.Scope autenticado no MVP. Associações não cruzam proprietários.

Persistir cota por usuário/data separada das pendências. Seleção, devolução, ordem e conclusão usam a mesma fronteira transacional, inclusive quando a cota ainda não existe. Cadastro engloba tarefa, novas labels e vínculos muitos-para-muitos em uma transação.

## D08 — Usuário padrão e data

Contexto Accounts contém somente identidade persistente e resolução/criação idempotente do usuário padrão. A resolução nas telas terá criação idempotente habilitada somente pela configuração de desenvolvimento, desabilitada por padrão. Reutilizar a operação existente de criação e o índice único; preservar a consulta estrita `get_default_user!/0` e os seeds explícitos. Não consultar `Mix.env()` no código de runtime nem criar outra variável `ENV`. Não adicionar criação na inicialização da aplicação, para preservar a execução de preparação/migrations sem acesso antecipado às tabelas. Incremento planejado na TASK-037. Não gerar autenticação agora. Data de negócio é Date.utc_today(), com valor controlável nos testes; não persistir fuso nem horário de seleção/conclusão. Normalizar virada na leitura/comando, sem depender de processo web.

## D09 — Gettext fixo em pt-BR

Manter PlannerWeb.Gettext, mensagens-base em inglês e tradução pt_BR. Configurar locale fixo e HTML pt-BR; sem sessão de preferência ou seletor. Conteúdo do usuário permanece inalterado.

## D14 — Scaffolds e incrementos pequenos

Gerar contexto/schema e LiveViews, uma vez por recurso; usar --no-context na interface sobre domínio existente. Sem autenticação gerada, usar --no-scope e declarar user_id explicitamente nos recursos dependentes. Ajustar APIs para receber o usuário padrão do servidor e restringir campos permitidos. Comandos concretos ficam nas tarefas.

## D15 — Tema semântico e cadastro sobre o planejamento

Evolução autorizada em 09/10/2026: usar daisyUI já integrado ao Phoenix/Tailwind, com tema claro único `planner`. Cores ficam nos tokens semânticos do tema; componentes usam `base`, `primary`, `error` etc., preparando futuras paletas sem implementá-las. Remover controles e scripts de seleção de tema, inclusive leitura de preferências antigas. Nenhuma nova dependência.

`/tasks` e `/tasks/new` pertencem a TaskLive.Index; patch controla presença do Form convertido em LiveComponent. O componente conserva validação e captura restrita das falhas do cadastro existente, recebe proprietário do pai e comunica sucesso para atualização do snapshot e flash. Diálogo HTML nativo e hook no bundle cuidam de modalidade, Escape e foco; regras de negócio continuam no servidor. O atributo `open` do diálogo/seção de labels é preservado durante patches via API LiveView; erros de labels forçam expansão. Histórico mantém streams montados em contêiner oculto, evitando perder itens ao expandir/recolher.

A [SPEC-004](specs/004-experiencia-e-acesso.md#evolução-da-experiência--09102026) define o comportamento. Foco, atalhos e apresentação descritos aqui registram escolhas presentes na implementação, não requisitos ou critérios de aceite. Não há avaliação humana obrigatória, conforme o [PRD](prd.md#feedback-de-interface); ajustes estéticos dependem de feedback do responsável.

## D16 — Movimentação persistida de pendências

Plano autorizado em 09/10/2026: SortableJS via npm (licença MIT), instalado pelo responsável na retomada em 10/10/2026, com versão resolvida 1.15.7 no lockfile e importação pelo bundle existente. Hook mantém somente o DOM temporário do gesto, restaura os mesmos nós antes de enviar o evento e deixa streams aplicarem o estado confirmado. Não usar ignore nas listas de streams. Uma operação de domínio valida os conjuntos completos e aplica transferência/posições/cota sob o lock do usuário. Cadastro compartilha esse lock; posições de backlog/retry têm restrições próprias, preservando o índice de hoje por data. A virada acrescenta ao final de retry. Menu usa a mesma ordenação persistida e transferências ao final.

## D17 — Evolução para produção com auth padrão Phoenix

Decisão de 11/10/2026 substitui, para o novo incremento, a resolução pública do usuário padrão em D04/D06/D08/D14. Reutilizar Accounts/User/users com migration aditiva e scaffold de `phx.gen.auth` instalado, sem regenerar tarefas/labels. A TASK-015 é produtora única de auth, tokens, notifier e scope; TASK-045 integra o proprietário autenticado às entradas HTTP/LiveView e mantém APIs de domínio com usuário explícito derivado do scope. Preservar default sem e-mail autenticável, não transferir seus dados e não resetar banco. A restrição de `identifier` legado precisa acomodar contas por e-mail.

Cadastro aberto, magic link sem senha, `/` redireciona ao login ou `/tasks` conforme sessão. Usar os mecanismos de sessão/token/revogação do gerador, sem criar protocolo próprio. Ajuda local e templates de Phoenix 1.8.13 consultados; o template de token usa validade de 15 minutos para login. Configuração local usa Swoosh existente; operação vai ao README na TASK-046. Fornecedor de e-mail/hosting de produção ainda pendentes.

## D18 — Ajustes de tarefas e preservação da cota

Retry → backlog e exclusão reutilizam o lock/transação por usuário. Transferência não altera cota; exclusão de pendência de hoje restitui uma escolha, das demais não; concluídas são preservadas. Normalizar dia antes de decidir o efeito. Remover vínculos ao excluir sem apagar catálogo de labels. Interfaces consomem essas operações e restauram estado confirmado; menus ficam à esquerda com controles sem compressão por pedido explícito do responsável.

## D19 — Catálogo, concessão e seleção de tema

Substitui o limite de tema único de D15 para o MVP de produção. Preservar tokens do claro `planner`, adicionar `planner_dark`, manter CSS semântico no bundle existente. `Planner.Themes` possui catálogo e concessão única usuário/tema; preferência é referência persistida por conta. Contas existentes e futuras recebem ambos gratuitamente. Renderização inicial usa seleção autorizada no servidor; páginas públicas voltam ao claro. Não aplicar preferência global de navegador entre contas.

A relação de concessão é a base para futura propriedade por compra. Créditos, débitos, preços, checkout e saldo não são implementados agora; SPEC-009/TASK-049 ficam bloqueadas por decisões próprias. Não criar abstrações de pagamento nem carteira vazia para preparar uma funcionalidade ainda indefinida.
