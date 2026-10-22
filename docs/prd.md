# PRD — Planner: MVP local e MVP de produção

Escopo mínimo definido pelo responsável em 23/09/2026. MVP local concluído em 05/10/2026, com aceite aprovado na revisão independente de prontidão (histórico em `4ed2a47:docs/review.md`, seção `revalidação-de-prontidão-do-mvp--05102026`), após a correção de CA09 na [TASK-038](tasks/038-tratar-falha-cadastro.md).

## 1. Objetivo do MVP local entregue

Permitir cadastrar tarefas, escolher até três ações para o dia, ordenar, devolver ou concluir e consultar histórico. O MVP é usado com um usuário padrão de teste; não exige contas, login ou configuração pessoal.

## 2. Escopo funcional do MVP local entregue

| ID | Requisito |
| --- | --- |
| RF01 | Exibir backlog, hoje, retry e histórico do usuário padrão. |
| RF02 | Selecionar uma tarefa de backlog ou retry para hoje, preservando identidade. |
| RF03 | Limitar a três escolhas consumidas por dia e ordenar prioridades. |
| RF04 | Concluir uma tarefa de hoje e registrar a data, sem horário. |
| RF05 | Consultar histórico persistente, com conclusões mais recentes primeiro. |
| RF06 | Cadastrar tarefa por título obrigatório. |
| RF07 | Reordenar prioridades e devolver manualmente uma tarefa de hoje ao backlog. |
| RF10 | Associar várias labels opcionais, reutilizando existentes ou criando novas no cadastro. |

## 3. Regras do MVP local entregue

- Selecionar consome uma escolha; concluir mantém o consumo; devolver manualmente ao backlog restitui uma escolha uma única vez.
- Backlog contém tarefas disponíveis, inclusive as retiradas manualmente de hoje. Retry recebe apenas tarefas que permaneceram em hoje sem conclusão quando o servidor observar um novo dia.
- Usar `Date.utc_today()` do Elixir para a data corrente, sem fuso configurável ou horário de negócio.
- Normalizar a virada ao consultar ou executar um comando. Página ociosa pode ficar desatualizada; o usuário recarrega quando precisar. Não há timer ou atualização automática entre abas.
- Todas as visitas usam o mesmo usuário padrão criado para testes. Em desenvolvimento, o primeiro acesso ao painel ou ao cadastro cria essa identidade se ausente, sem exigir seeds; os demais ambientes mantêm preparação explícita. Tarefas, labels e cota pertencem a ele; proprietário é atribuído pelo servidor.
- Interface somente pt-BR pelo Gettext existente, seguindo o padrão Phoenix. Sem seletor de idioma; conteúdo digitado não é traduzido.
- Histórico preserva conclusões. Reabrir/excluir tarefas, editar/excluir labels e gestão completa de projetos ficam fora do MVP.

## 4. Experiência

Hoje tem destaque, prioridades numeradas e escolhas disponíveis. Backlog e retry são listas distintas com ação de selecionar. Cadastro aceita título e várias labels; histórico permanece acessível. Ações apresentam validação e erros sem falso sucesso.

## 5. Arquitetura e qualidade

Manter Phoenix, PostgreSQL e Gettext. Reaproveitar geradores, adaptando o CRUD ao fluxo especificado. Regras de cota, posições e cadastro com labels são atômicas no servidor. Configuração de ambiente não inclui segredos versionados.

A entrega exige testes relevantes, verificações do repositório e **cobertura mínima de 70%**, já exigida pelo CI. O percentual não substitui testes dos limites, devolução, conclusão, falhas e concorrência.

## 6. Critérios de aceite do MVP local

| ID | Cenário e resultado |
| --- | --- |
| CA01 | Base sem tarefas mostra estados vazios; título válido cria backlog e título vazio é rejeitado. |
| CA02 | Selecionar de backlog/retry move a mesma tarefa para hoje; recarga mantém estado. |
| CA03 | Com três escolhas consumidas, concluir uma tarefa não permite quarta seleção; concorrência respeita a cota. |
| CA04 | Reordenação persiste posições consecutivas e únicas; conjunto inválido é rejeitado integralmente. |
| CA05 | Com três escolhas consumidas, devolver uma pendência ao backlog permite nova seleção; repetir não restitui outra escolha. |
| CA06 | Concluir registra uma única data, sem horário; repetição não muda a data nem restitui escolha. |
| CA07 | Reiniciar mantém tarefas, labels, histórico e consumo por data. |
| CA08 | Após mudar a data, recarregar mostra pendências anteriores em retry; comando de tela antiga revalida o dia antes de gravar. |
| CA09 | Falha informa erro e preserva estado anterior, inclusive cota e novas labels. |
| CA10 | Cadastro, seleção, ordem, devolução e conclusão funcionam em pt-BR, com comportamento e estrutura verificados pelos testes existentes. |
| CA11 | Precommit e CI passam, com cobertura de testes de pelo menos 70%. |
| CA12 | Aplicação executa no ambiente de teste com configuração externa e sem segredos versionados. |
| CA13 | Abrir painel usa usuário padrão sem login; repetir seeds não o duplica e parâmetros não trocam o proprietário. |
| CA15 | Cadastro com várias labels existentes/novas persiste todos os vínculos; label incompatível rejeita a transação. |

<a id="validação-humana-da-interface--fora-das-tarefas"></a>

### Feedback de interface

Por decisão do responsável em 09/10/2026, foco, operação por teclado, contraste, layout e questões estéticas não são requisitos nem critérios de aceite do projeto. Não há avaliação humana obrigatória da interface, checklist, evidência exigida ou pendência a registrar, inclusive para movimento reduzido e anúncios por tecnologias assistivas.

O responsável pode levantar observações durante seu uso e avaliação, a seu critério. Esse feedback poderá originar ajustes quando solicitado. Permanecem os requisitos funcionais e os gates automatizados já definidos.

Esta decisão substitui a reserva de validação humana de 05/10/2026 e cancela CA-004-11 da renovação. Menções a avaliação humana pendente em relatórios e evidências anteriores são históricas; não representam obrigação vigente nem comprovação de avaliação realizada.

## 7. MVP de produção — plano autorizado em 11/10/2026

O responsável confirmou o funcionamento do MVP local. A integração está no snapshot `367bf35` (`MVP Local (#7)`); a TASK-040 foi reconciliada com esse aceite. As seções anteriores preservam o contrato entregue, sem impor usuário padrão, ausência de login ou tema único ao novo incremento. Planejamento pronto não significa funcionalidades implementadas ou aplicação publicada.

| Requisito | Entrega do MVP de produção |
| --- | --- |
| RF12 | Menu de ações no canto esquerdo dos cartões, com controles de mover sem compressão. |
| RF07 ampliado | Enviar retry ao backlog por menu/arraste, preservando dados e sem alterar cota. |
| RF16 | Excluir definitivamente pendências com confirmação; excluir de hoje restitui uma escolha, concluídas permanecem preservadas. |
| RF08 | Cadastro aberto por e-mail, magic link com auth padrão Phoenix e dados privados por conta. |
| RF13 | Home direciona ao login; autenticados seguem para `/tasks`; desenvolvimento permite testar links na mailbox local. |
| RF14 | Temas claro existente e escuro gratuitos para todos, concessões e preferência persistidas por usuário. |
| RF11 | Código Phoenix funcional, release local com assets e migrations e aceite integrado reproduzível sem serviços externos. |

Dados do usuário padrão ficam preservados e isolados; não migrar automaticamente para nenhuma conta. Dashboard mantém `/tasks` e cadastro `/tasks/new`. Usar pt-BR, data UTC, limite de três escolhas e recarga manual. O feedback de layout RF12 é uma correção específica solicitada, sem reinstalar checklist visual ou aceite humano obrigatório.

### Aceites do incremento

- CA17: cadastro/login/logout por magic link funcionam; visitantes não acessam planejamento, duas contas não leem nem alteram dados alheios, e dados legados permanecem isolados (SPEC-005).
- CA18: claro e escuro estão disponíveis gratuitamente, seleção persiste por conta e não vaza entre sessões (SPEC-007).
- CA19: menu corrigido, retry → backlog e exclusão respeitam cota, transações e histórico; release mantém esses contratos com contas reais (SPEC-002/004/008).
- CA16: release local inicializa com configuração externa e banco de teste e tem os fluxos da aplicação validados sem provedor externo (SPEC-008).

### Fronteira da entrega de código — decisão de 13/10/2026

O trabalho dos agentes termina no código Phoenix funcional e no release local validado. Hospedagem, domínio/HTTPS, provedor e remetente de e-mail, publicação e operação de backups são responsabilidade do usuário, fora desta entrega e sem constituir bloqueios da fila de código. O usuário pode configurar o provedor posteriormente usando a integração Swoosh existente; desenvolvimento e testes validam o fluxo sem envio externo. A expressão “MVP de produção” identifica o incremento com contas e temas, não uma obrigação de operar um ambiente remoto.

### Escolhas para publicação — decisão de 19/10/2026

O responsável escolheu Fly.io com uma única instância de aplicação, PostgreSQL no Neon e Resend para e-mails transacionais. A operação usará a CLI oficial da Fly. A decisão arquitetural está em [D24](design.md#d24--flyio-neon-resend-e-configuração-por-url); procedimentos e estado da preparação ficam no README.

Esta rodada registra escolhas e exemplos de configuração. Não comprova provisionamento, integração Resend/Neon, envio externo ou publicação. O aceite local existente e a fronteira operacional acima permanecem válidos; as antigas tarefas de publicação não são reabertas por este registro. Nome do app, região, domínio e remetente ainda precisam ser definidos.

Pedido complementar autoriza planejar a integração Resend no código: [TASK-060](tasks/060-configurar-resend.md), com contrato em SPEC-008 RN06–RN08. A tarefa configura adapter e remetente por ambiente e valida sem envio externo; credenciais e verificação de domínio permanecem na operação. Não inclui a mudança de banco local para URL ou a configuração Fly/Neon.

### Preparação de segurança — 19/10/2026

O responsável cuidará da Fly e de backups/recuperação Neon fora do desenvolvimento. Autoriza planejar TLS verificado para PostgreSQL (TASK-062), healthcheck público mínimo sem informações do projeto (TASK-063) e limitação de e-mails de autenticação (TASK-064). Confirmou espera na mesma tela de login e limites configuráveis por ambiente, carregados na inicialização. O planejamento propõe padrões iniciais de 60 segundos entre tentativas por e-mail, 5 por e-mail/hora, 20 por IP/hora e teto global de 90 chamadas ao mailer/dia UTC, ajustáveis pelo responsável. Bloqueio é obrigatório no servidor, incluindo eventos LiveView e cadastro.

A preparação identifica também exposição do token no caminho registrado pelo logger padrão; TASK-065 trata logs da aplicação e Referer. Preservar proteções Phoenix existentes de CSRF, origem e escape HTML. Não abrir CORS nem adicionar pacote genérico de segurança sem necessidade. CSP restritiva de scripts é defesa adicional a avaliar separadamente; a política padrão de headers não constitui proteção completa contra XSS. Não houve auditoria completa ou novo aceite de segurança nesta rodada documental.

## 8. Evolução após o MVP de produção

- RF15: adição de créditos a usuários na TASK-049; loja, preços e compra de temas vêm depois. Propriedade futura aproveita as concessões da SPEC-007. Não há saldo, cobrança, pagamento ou loja no MVP de produção.
- RF09 / CA14: fuso por conta (TASK-004/017) e atualização automática (TASK-031) continuam adiados. Idiomas (TASK-013/014) foram retomados em 17/10/2026, conforme decisão abaixo.
- Equipes, integrações, recorrência, IA, reabertura, edição/exclusão de labels e gestão completa de projetos continuam fora deste plano.

## 9. Planejamento

O [índice de tarefas](tasks/README.md) organiza entregas do MVP de produção; cabeçalhos são a fonte de dependências e prontidão. Comportamentos estão nas [specs](specs/README.md), arquitetura em [design](design.md). Créditos têm contrato futuro separado e não bloqueiam os dois temas gratuitos.

## E2E obrigatório — decisão de 16/10/2026

A infraestrutura e os aceites estão em [D20](design.md#d20--e2e-em-navegador-real). Tarefas que alterem front (templates, estilos, navegação, formulários, LiveView ou hooks) devem criar/adaptar cenários E2E do comportamento afetado, usá-los durante a implementação e executar a suíte completa antes da entrega. Todo revisor de código deve executar a suíte completa, inclusive em mudanças de backend, e registrar alvo, resultado e artefatos; evidência de terceiros não substitui essa execução. Autoavaliação segue a mesma regra. Revisão exclusivamente documental usa validação documental.

A exigência passa a ser executável com a integração da TASK-055; até lá, registrar a indisponibilidade como critério não verificado, sem declarar aprovação E2E. Falha ou impossibilidade de execução depois da integração impede aprovação e segue o protocolo de bloqueios. Exceções antigas de execução manual de navegador são históricas e não dispensam a nova política em entregas futuras. Isso não cria revisão independente automática. Operação e comandos ficam no README.


## Identidade Just Three — decisão de 17/10/2026

Nome público passa a **Just Three**. A marca usa três traços horizontais para remeter às três escolhas diárias. Remover o título redundante acima de Hoje; saída por ícone e temas abertos por ícone de quebra-cabeça, alinhados na barra. Contratos em SPEC-004 RN21–RN24 e SPEC-007 RN09–RN10; implementação planejada na TASK-059. Nomes técnicos e registros históricos mantêm Planner. “A fazer” é a tradução de backlog aprovada pelo responsável em 17/10/2026.


## Idiomas pela engrenagem — 17/10/2026

O responsável autorizou troca de idioma funcional pela engrenagem entre tema e saída, abrangendo todos os textos da interface. Marca e conteúdo do usuário são preservados. SPEC-001 está ready: português do Brasil e inglês, seletor também no login/Criar conta, escolha pública no navegador e preferência na conta após login. O responsável confirmou que o usuário pode alterar o idioma durante todo o uso pela engrenagem, atualizando a interface e a preferência salva. Precedência e logout seguem SPEC-001 RN11–RN13. TASK-013/014 aguardam somente integração das dependências; TASK-059 inclui A fazer e é a próxima elegível.
