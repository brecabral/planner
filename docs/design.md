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

Cadastro aberto, magic link sem senha, `/` redireciona ao login ou `/tasks` conforme sessão. Usar os mecanismos de sessão/token/revogação do gerador, sem criar protocolo próprio. Ajuda local e templates de Phoenix 1.8.13 consultados; o template de token usa validade de 15 minutos para login. Configuração local usa Swoosh existente; operação vai ao README na TASK-046. A configuração posterior do provedor de e-mail e a operação de hosting pertencem ao usuário e não bloqueiam a entrega de código.

## D18 — Ajustes de tarefas e preservação da cota

Retry → backlog e exclusão reutilizam o lock/transação por usuário. Transferência não altera cota; exclusão de pendência de hoje restitui uma escolha, das demais não; concluídas são preservadas. Normalizar dia antes de decidir o efeito. Remover vínculos ao excluir sem apagar catálogo de labels. Interfaces consomem essas operações e restauram estado confirmado; menus ficam à esquerda com controles sem compressão por pedido explícito do responsável.

## D19 — Catálogo, concessão e seleção de tema

Substitui o limite de tema único de D15 para o MVP de produção. Preservar tokens do claro `planner`, adicionar `planner_dark`, manter CSS semântico no bundle existente. `Planner.Themes` possui catálogo e concessão única usuário/tema; preferência é referência persistida por conta. Contas existentes e futuras recebem ambos gratuitamente. Renderização inicial usa seleção autorizada no servidor; páginas públicas voltam ao claro. Não aplicar preferência global de navegador entre contas.

A relação de concessão é a base para futura propriedade por compra. Créditos, débitos, preços, checkout e saldo não são implementados agora; SPEC-009/TASK-049 ficam bloqueadas por decisões próprias. Não criar abstrações de pagamento nem carteira vazia para preparar uma funcionalidade ainda indefinida.

## D20 — E2E em navegador real

Decisão de 16/10/2026: consolidar Playwright/Chromium em containers sobre o release Phoenix, com banco descartável e isolado do desenvolvimento. O esboço em containers incluído com este planejamento é entrada da TASK-055, sem comprovar a conclusão do runner local ou sua prontidão para CI. Não substituir ExUnit, testes JavaScript ou o limiar de cobertura de 70%.

Decisão complementar de 16/10/2026: Just concentra a operação local de desenvolvedores e agentes, inclusive bancos, servidor, gates e E2E autocontido. Mix cuida das tarefas Elixir/Phoenix e de seus assets, sem iniciar Docker nem administrar infraestrutura. O GitHub tem PostgreSQL e orquestração próprios, com etapas explícitas de qualidade e E2E no job `quality` protegido; não chama Just, o runner local ou um alias Mix agregador como única definição do gate. Compartilha cenários, configuração Playwright e imagem de release. O CI pode ser entregue antes da ampliação autenticada e sempre executa todos os cenários disponíveis. Erros de build, preparação, readiness, testes ou coleta obrigatória de evidências devem reprovar a execução. Capturar diagnósticos antes de limpar recursos, inclusive em falhas, sem mascarar o código de saída. Execuções sucessivas partem de dados novos; execuções concorrentes não compartilham banco/containers nem removem recursos umas das outras.

O primeiro incremento preserva os dois cenários públicos existentes. O seguinte acrescenta conta e dados sintéticos por cenário, autenticação pelo mecanismo Phoenix existente e fluxos autenticados. Fixtures podem preparar dados e tokens por script privado executado dentro do container; login deve consumir o token pela rota normal, sem endpoint de bypass, mailbox pública em produção ou envio de e-mail real. Entrega de e-mail não é comprovada por esse fixture. Asserções observam resultado no navegador e persistência após recarga, não apenas classes HTML ou eventos disparados.

Tarefas de front mantêm cenários proporcionais ao comportamento alterado e usam E2E para avaliá-lo. Toda revisão de código e autoavaliação executa a suíte completa, mesmo sem alteração visual. Mudanças só documentais recebem validação documental. A política, sua transição e evidências estão no [PRD](prd.md#e2e-obrigatório--decisão-de-16102026); operação fica no README. Não reabrir entregas históricas por essa nova exigência.

## D21 — Estrutura do banco e limites do aceite de persistência

Decisão do responsável em 17/10/2026: criação e evolução de tabelas, índices e constraints pertencem às migrations do Ecto. O runtime consome a estrutura previamente migrada, sem mecanismos próprios para criar ou reparar essa estrutura. A aplicação continua lendo e gravando dados de negócio, aplicando validações, transações e isolamento previstos nas specs; isso não delega regras de negócio ao framework. Durabilidade do PostgreSQL e persistência após reinício não constituem aceites próprios da aplicação. CA-008-03 foi retirado, sem exigir nova infraestrutura de teste de reinício.


## D22 — Identidade pública Just Three

Decisão de 17/10/2026: marca Just Three com três linhas horizontais iguais, usando o sistema de ícones existente (por exemplo `hero-bars-3`), no lugar do check. Tema usa peça de quebra-cabeça e saída usa símbolo de encerramento de sessão. Preservar paletas semânticas, fontes e contratos de domínio. Os controles ficam lado a lado e centralizados na mesma altura. Detalhes observáveis em SPEC-004 RN21–RN24 e SPEC-007 RN09–RN10. Não renomear módulos, aplicação OTP, banco, rotas ou códigos `planner`/`planner_dark`: identidade pública não exige migração técnica. TASK-059 é a produtora única desta atualização de interface.


## D23 — Preparação de troca de idioma

Pedido de 17/10/2026 amplia a decisão de locale fixo conforme SPEC-001: manter Gettext, mensagens-base em inglês e catálogos completos; resolver locale por requisição e por processo LiveView. TASK-013 é produtora única da preferência/resolução; TASK-014 produz catálogos e engrenagem entre tema e saída. Esta composição substitui a adjacência imediata dos controles descrita em D22, mantendo alinhamento. Idiomas confirmados: `pt_BR` e `en`. Login e Criar conta oferecem seleção pública visível, conservada na navegação entre essas telas. Inglês usa mensagens-base, pt-BR usa catálogo; HTML usa `pt-BR`/`en`. Preferência na conta e escolha pública no navegador aprovadas em 17/10/2026. A conta prevalece após login; cadastro inicializa com idioma público e conta legada sem preferência o adota no primeiro login. Preservar ausência de preferência no modelo até essa inicialização. Logout recupera escolha pública, sem copiar automaticamente locale da conta. Armazenamento público deve sobreviver à reabertura do navegador e ser legível na renderização HTTP/LiveView; reutilizar mecanismos Phoenix existentes. Engrenagem mantém troca durante todo o uso; seleção autenticada persiste na conta. Contrato completo e concorrência em SPEC-001 RN11–RN13. Nenhuma alteração de dados de tarefas ou fuso.

## D24 — Fly.io, Neon, Resend e configuração por URL

Decisão de 19/10/2026: hospedar o release Docker existente na Fly.io com uma única instância de aplicação, PostgreSQL externo no Neon e e-mails transacionais pelo Resend usando Swoosh e o cliente Req existentes. A operação usará a CLI oficial da Fly. A instância única dispensa configurar cluster nesta etapa e não oferece redundância da aplicação. Dados persistentes continuam no PostgreSQL, sem necessidade de volume Fly para as capacidades atuais.

Reutilizar o mecanismo de migrations do Ecto e o módulo de release existente, acionado pela etapa de release da Fly antes de atualizar a aplicação. Não executar migrations automaticamente na inicialização do servidor nem criar mecanismo próprio de evolução de schema. Esta decisão mantém D21.

Adotar `DATABASE_URL` literal em desenvolvimento pela [TASK-061](tasks/061-database-url-desenvolvimento.md), com ambiente exportado prevalecendo sobre `.env`. Manter os campos separados usados pelo Compose e preservar configuração isolada de testes, partições e CI. Testes não devem consumir a URL de desenvolvimento ou produção. Produção continua recebendo variáveis do processo; a integração Neon deve verificar o certificado TLS. O exemplo de URL foi acrescentado ao `.env.example`, mas o leitor de desenvolvimento ainda usa os campos separados. A TASK-061 depende da TASK-060 apenas para serializar os arquivos documentais e de exemplo compartilhados.

Configurar futuramente o adapter Resend e o remetente por ambiente (`RESEND_API_KEY`, `MAIL_FROM_EMAIL`, `MAIL_FROM_NAME`). Desenvolvimento conserva mailbox local e testes conservam adapter de teste. Essas variáveis ainda não são consumidas pelo código. Exemplos de produção permanecem comentados; credenciais reais não pertencem ao repositório.

Estado: decisões registradas, sem implementação de integração, instalação de CLI, provisionamento ou deploy nesta rodada. Nome do app, região, domínio e remetente continuam pendentes. A implementação posterior deve cobrir precedência da URL, isolamento dos testes e configuração do mailer na suíte versionada, seguindo os gates vigentes, inclusive E2E. Operação e localização dos scripts estão no [README](../README.md#publicação-planejada-na-flyio-com-neon-e-resend).
