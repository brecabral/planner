---
id: "TASK-052"
status: planned
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
