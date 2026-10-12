---
id: "SPEC-005"
status: ready
requirements: ["RF08", "RF13", "CA13", "CA17"]
---

# 005 — Contas, magic link e isolamento

## Escopo e origem

MVP de produção autorizado em 11/10/2026: cadastro aberto por e-mail, login exclusivamente por magic link e autenticação padrão do Phoenix instalado. O responsável confirmou que dados antigos ficam isolados, sem migração para conta real. O MVP local sem login permanece uma entrega histórica aceita (TASK-009/TASK-037); seus critérios CA-005-01–06 não são gates do fluxo autenticado.

## Arquitetura e casos de uso

Reutilizar `Planner.Accounts.User` e tabela `users`, adaptando o scaffold Phoenix com tokens, notifier, sessão, `Accounts.Scope`, plugs e hooks gerados. Accounts resolve a identidade; o servidor fornece `current_scope.user` às APIs de tarefas/labels/cota e, posteriormente, temas. Não gerar outro contexto de identidade nem sobrescrever migrations já aplicadas. A interface não escolhe proprietário.

### Regras

- RN08: visitante pode registrar e-mail e receber link para confirmar posse e entrar; conta existente solicita novo link. Usar cadastro e solicitação do scaffold, com feedback genérico na solicitação de login. Não criar login, definição ou recuperação de senha, OAuth ou convites neste MVP; remover superfícies de senha geradas que não pertencem ao contrato.
- RN09: manter construção, hash persistido, expiração, confirmação, revogação e sessão do gerador instalado. Magic link de login expira em 15 minutos conforme template local consultado em 11/10/2026; consumo não pode autenticar novamente com o mesmo token. Link inválido/expirado/usado não abre sessão e permite solicitar outro. Preservar proteção CSRF, renovação de sessão e logout com revogação do padrão Phoenix.
- RN10: `/` leva o visitante ao login (`/users/log-in`); autenticado acessando `/` ou login vai a `/tasks`. Após consumir link, destino padrão é `/tasks`; retornos só podem ser internos autorizados, nunca URL externa fornecida pelo cliente. Logout volta ao login.
- RN11: `/tasks`, `/tasks/new` e toda entrada de planejamento exigem identidade válida tanto no HTTP quanto no mount/reconexão LiveView. Não há fallback para usuário padrão em dev/test/prod após integração da TASK-045. Sessão ausente/revogada impede leitura/comando e exige login conforme os helpers gerados.
- RN12: tarefas, labels, histórico, cota e preferências pertencem ao usuário autenticado. IDs/params de outro usuário têm o mesmo resultado de IDs inexistentes; nunca listar, mover, excluir, concluir, associar ou alterar dados alheios. Não confiar em user_id de params, eventos, formulário ou armazenamento local. Duas contas têm cotas independentes.
- RN13: preservar o usuário legado `default`, seus IDs, tarefas, labels, histórico e cota, mas sem e-mail de login/token nem acesso por visitantes/novas contas. Não associar seus dados ao primeiro cadastro, não criar e-mail fictício e não apagar o banco. Migrations aditivas acomodam usuários legados sem e-mail; contas autenticáveis exigem e-mail válido com unicidade normalizada. Cadastro novo não herda `identifier=default` nem depende desse campo legado obrigatório.
- RN14: desenvolvimento usa Swoosh local e `/dev/mailbox`, já existentes, para capturar links com host/porta locais configurados. Não requer credencial nem envio externo. Produção não expõe mailbox/LiveDashboard de desenvolvimento e usa entrega real definida na SPEC-008. Interface/e-mails usam Gettext com mensagens-base em inglês e pt-BR.

## Cenários de aceite

- CA-005-07: cadastrar e-mail novo e seguir link confirma a conta, inicia sessão e abre dashboard vazio próprio; repetir cadastro não duplica e-mail normalizado. Conta existente pode entrar por novo magic link; senha não tem rota/formulário utilizável.
- CA-005-08: token inválido, expirado, já consumido e duas tentativas concorrentes não geram autenticação adicional; primeira confirmação e logout preservam revogações do scaffold. Testes usam tempo controlado quando necessário.
- CA-005-09: visitante em `/`, `/tasks` e `/tasks/new` termina no login sem dados privados; autenticado em `/`/login termina em `/tasks`. Mount direto/reconexão sem sessão não recuperam dados; logout invalida a sessão de acordo com o fluxo gerado.
- CA-005-10: A e B cadastram tarefas/labels; consultas e todos os comandos com IDs forjados não cruzam contas, inclusive histórico, exclusão, movimentos e cota. Seleções em A não consomem escolhas de B.
- CA-005-11: aplicar migration sobre banco com `default` e dados preserva registros/FKs; criar duas contas reais não revela nem transfere o legado. Fixtures e seeds deixam de depender de acesso público ao default; banco novo e existente funcionam.
- CA-005-12: solicitar link em dev entrega mensagem somente na mailbox local; abrir link permite login e sair/entrar com outra conta testa isolamento. Em configuração prod, rotas dev não existem. README contém o procedimento somente após implementado.

## Dados, limites e entregas

Tokens e preferências não pertencem ao usuário padrão compartilhado. Sem migração de propriedade, exclusão de conta, alteração de e-mail, senha ou gestão administrativa neste incremento. Preservar mecanismos internos necessários do scaffold; não expor telas extras apenas porque foram geradas.

TASK-015 produz auth/schema/scope e telas de entrada; TASK-045 protege o planejamento e substitui a resolução padrão; TASK-046 prepara e documenta teste de e-mail local. As três são sequenciais e não autorizam publicação intermediária. Sem dúvidas bloqueantes de produto; provedor de produção é pendência da SPEC-008.

## Contrato histórico do MVP local — substituído no incremento de produção

RN01–RN07 e CA-005-01–06 abaixo preservam a rastreabilidade das TASK-009/037 e de seus aceites. Não autorizam acesso compartilhado depois da TASK-045; as regras vigentes do novo incremento são RN08–RN14 acima.


- RN01: preparar os dados cria o usuário padrão uma única vez, com identificador estável. Repetir seeds não duplica o usuário nem altera seus dados de planejamento.
- RN02: abrir o painel usa automaticamente esse usuário, sem redirecionar para login ou pedir escolha de conta.
- RN03: proprietário de tarefa/label vem do usuário padrão no servidor, nunca de um campo editável ou parâmetro do navegador. Vínculos entre tarefa e label continuam exigindo proprietário compatível.
- RN04: testes criam sua fixture de usuário sem depender de seed global; validações de proprietário podem usar outra fixture para rejeitar IDs incompatíveis. Isso não cria um fluxo de múltiplas contas na interface.

- RN05: em ambiente de desenvolvimento (`dev` da configuração Elixir), acessar o painel ou diretamente o formulário de cadastro garante a existência do usuário de identificador `default` antes de resolver o proprietário. Se ausente, cria somente esse usuário; acessos repetidos, remontagens LiveView e acessos simultâneos reutilizam a mesma identidade. Não escolher o primeiro registro arbitrário do banco.
- RN06: criação automática no acesso fica desabilitada por padrão e em `test`/`prod`. Nesses ambientes, ausência do usuário continua exigindo preparação explícita; testes usam fixtures. Seeds explícitos mantêm seu contrato idempotente. A configuração vem do servidor, nunca de parâmetros da requisição.
- RN07: banco e migrations são pré-requisitos. A criação automática não cria banco, aplica migrations ou mascara erros de persistência; não insere tarefas/labels demonstrativas nem altera dados existentes.

## Cenários de aceite

- CA-005-01: repetir preparação mantém um único usuário padrão.
- CA-005-02: abrir painel permite usar o planejamento sem login; recarregar preserva proprietário e dados.
- CA-005-03: enviar user_id forjado no cadastro não troca o proprietário; label incompatível é rejeitada sem gravação parcial.

- CA-005-04: dado banco migrado em `dev` sem usuário padrão, abrir `/tasks` ou, em cenário independente, `/tasks/new` cria `default` e permite usar a tela sem executar seeds previamente; repetir acesso e conexão LiveView mantém sua identidade.
- CA-005-05: dado usuário padrão com tarefas e labels, repetir acesso em `dev` preserva identidade, timestamps e dados. Se existir apenas outro usuário, cria `default` sem assumir ou alterar a identidade existente. Criações simultâneas convergem para um único `default` pela unicidade já existente.
- CA-005-06: com criação automática desabilitada, resolver usuário ausente não insere registros e mantém o erro de ausência; usuário previamente preparado continua utilizável. Configurações de `test` e `prod` não habilitam a criação automática.
