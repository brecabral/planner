---
id: "TASK-052"
status: done
execution_level: standard
execution_rationale: "Adapta LiveView e rotas existentes, preservando autenticação e recuperação de envio, com testes de integração e acessibilidade da interface."
specs: ["SPEC-005"]
depends_on: ["TASK-051"]
provides: ["public-join-page"]
consumes: ["registration-delivery-recovery"]
write_scope: ["lib/planner_web/router.ex", "lib/planner_web/live/user_live/registration.ex", "lib/planner_web/live/user_live/login.ex", "lib/planner_web/components/", "priv/gettext/", "test/planner_web/", "docs/tasks/052-pagina-join.md"]
blockers: []
---

# 052 — Oferecer página pública de criação de conta em /join

## Objetivo e entradas

Entregar SPEC-005 RN16–RN19/CA-005-14–17: página de criação de conta com apresentação do Planner e continuidade do magic link. Pedido e significado de join confirmados em 14/10/2026. Ler a seção correspondente da [spec](../specs/005-contas-e-acesso.md#página-join--planejamento-de-14102026), RN08–RN15, router, Registration/Login LiveViews, links de cadastro nos componentes e testes existentes de cadastro e falha de envio.

Consultar referências locais de Phoenix, LiveView, HEEx, formulários, interface, Gettext e testes antes das mudanças correspondentes. TASK-051 está concluída e registra integração em `118ba28`; conferir sua presença na base antes de iniciar. Ela depende transitivamente da autenticação TASK-015 e temas TASK-048. Não regenerar o scaffold.

## Escopo e exclusões

Reutilizar Registration como única implementação do formulário. Acrescentar `/join`, preservar `/users/register` por redirecionamento e atualizar links de cadastro. Compor a página e traduções com componentes/tokens existentes. Preservar redirecionamento de autenticados, recuperação por login e concessões. Não alterar Accounts, schema, migrations, tokens, envio externo, home, painel ou layout global para outras telas; não incluir convites, senha, OAuth, loja ou seletor público de tema. Componentes compartilhados só entram no escopo para links de cadastro ou ajuste estritamente necessário à página, preservando consumidores existentes.

## Aceite e verificação

1. CA-005-14: testes HTTP/LiveView verificam rota nova, compatibilidade antiga, link no login e redirecionamentos para usuário autenticado.
2. CA-005-15: testes verificam conteúdo pt-BR, rótulo, campo único e semântica de erros; conferir teclado, foco e larguras de 320/1280 px em navegador, registrando evidências e limites reais.
3. CA-005-16: testes verificam entrada inválida e duplicada sem novo usuário; conferir processamento/desabilitação durante submissão sem duplicar testes internos do scaffold.
4. CA-005-17: adaptar testes de integração de cadastro/envio para começar em `/join`, cobrindo sucesso, consumo do link e falha recuperável. Preservar cobertura de CA-005-13 e testes relevantes de login e isolamento.
5. Aplicar TDD enxuto aos comportamentos novos. Executar testes pertinentes e gates existentes `mix precommit` e CI com cobertura mínima de 70%, conforme README e ajuda Mix. Registrar autoavaliação segundo o fluxo de review, arquivos alterados e evidências por aceite. Não alegar revisão independente.

## Dependências e conclusão

Uma única tarefa produz rotas, página, traduções e verificação, evitando entregas intermediárias inconsistentes. TASK-052 pode iniciar após conferir integração da TASK-051; não depende de publicação ou provedor externo. Serializar eventual trabalho concorrente nos mesmos arquivos, especialmente empacotamento de release. Conclusão exige integração e conferência operacional; este plano não executa nem publica a página.


## Entrega e autoavaliação — 14/10/2026

Implementador `/root`; alvo: diff local sobre `82a166d`. TASK-051 concluída e commit `118ba28` confirmado como ancestral da base. A Registration permanece a única implementação: `/join` apresenta o cadastro; a ação legada redireciona visitantes para `/join`, após a verificação de autenticação. Login aponta para a nova rota. Textos pt-BR, instruções de magic link, associação de erros e foco do link usam os padrões existentes, sem alterar Accounts, concessões, tokens ou layout global.

| Aceite | Evidência e resultado |
| --- | --- |
| CA-005-14 | `AuthenticationFlowTest` cobre `/join`, redirecionamento HTTP/LiveView da rota antiga, navegação pelo login e ambas as entradas autenticadas indo a `/tasks`. `PageControllerTest` verifica o href público. |
| CA-005-15 | Testes verificam título, apresentação, instruções pt-BR, campo único, rótulo associado, descrição e erros com `aria-invalid`, `aria-describedby` e `role=alert`. Marca e flash acessível reutilizam Layouts. Conferência visual em 320/1280 px, foco e teclado no navegador dispensada explicitamente pelo usuário nesta sessão; não realizada nem alegada. |
| CA-005-16 | Submissões inválida e duplicada normalizada mantêm valor/erro e contagem de usuários; acesso ao login continua disponível. Teste verifica `phx-disable-with` traduzido. Bloqueio durante envio reutiliza o mecanismo do LiveView; comportamento no navegador não foi observado, conforme dispensa acima. |
| CA-005-17 | Integrações de cadastro e mailbox agora começam em `/join`, preservando confirmação, consumo do link, isolamento entre contas e recuperação de CA-005-13 com conta/concessões intactas e sem sessão antecipada. |

TDD: execução inicial dos testes direcionados terminou com 7 falhas em 15, evidenciando rota ausente, redirecionamento e link ainda antigos. Após implementação: **15/15 aprovados**. Gates: `mix precommit` e `mix ci`, ambos com **244 testes e 0 falhas**; Credo estrito sem achados, assets compilados e npm audit sem vulnerabilidades. Cobertura total **93,61%**, Registration **100%**, mínimo de **70%** preservado. A cobertura total atual inclui `Planner.Release` a 0%; a métrica histórica da TASK-051 antecede essa entrega e não constitui comparação isolada desta mudança. Catálogos extraídos/mesclados após formatação; `git diff --check` aprovado.

Arquivos alterados: router, Registration/Login, catálogo POT e tradução pt_BR, testes de autenticação, mailbox e controller público, além desta tarefa. Autoavaliação conforme fluxo de review, sem achados bloqueantes no diff e sem aprovação independente. Limitação explícita: HTML/LiveViewTest não comprovam layout, teclado ou estado pendente real no navegador. O servidor temporário solicitado para essa conferência foi encerrado a pedido do usuário; nenhuma publicação realizada.

Entrega inicialmente encaminhada em `in_review`. O marco independente em `docs/review.md` não foi alterado.

### Conclusão — 14/10/2026

O usuário confirmou que revisou a entrega e solicitou explicitamente marcar `done` e realizar o commit. Tarefa concluída com os gates registrados acima e integrada à base local pelo commit que contém esta atualização. Preservada a dispensa de conferência da UI pelo agente, sem inferir quais verificações visuais o usuário realizou.
