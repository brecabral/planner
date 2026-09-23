# PRD — MVP de prioridades diárias

Escopo mínimo definido pelo responsável em 23/09/2026. Implementação pendente.

## 1. Objetivo

Permitir cadastrar tarefas, escolher até três ações para o dia, ordenar, devolver ou concluir e consultar histórico. O MVP é usado com um usuário padrão de teste; não exige contas, login ou configuração pessoal.

## 2. Escopo funcional do MVP

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

## 3. Regras

- Selecionar consome uma escolha; concluir mantém o consumo; devolver manualmente ao backlog restitui uma escolha uma única vez.
- Backlog contém tarefas disponíveis, inclusive as retiradas manualmente de hoje. Retry recebe apenas tarefas que permaneceram em hoje sem conclusão quando o servidor observar um novo dia.
- Usar `Date.utc_today()` do Elixir para a data corrente, sem fuso configurável ou horário de negócio.
- Normalizar a virada ao consultar ou executar um comando. Página ociosa pode ficar desatualizada; o usuário recarrega quando precisar. Não há timer ou atualização automática entre abas.
- Todas as visitas usam o mesmo usuário padrão criado para testes. Tarefas, labels e cota pertencem a ele; proprietário é atribuído pelo servidor.
- Interface somente pt-BR pelo Gettext existente, seguindo o padrão Phoenix. Sem seletor de idioma; conteúdo digitado não é traduzido.
- Histórico preserva conclusões. Reabrir/excluir tarefas, editar/excluir labels e gestão completa de projetos ficam fora do MVP.

## 4. Experiência

Hoje tem destaque, prioridades numeradas e escolhas disponíveis. Backlog e retry são listas distintas com ação de selecionar. Cadastro aceita título e várias labels; histórico permanece acessível. Ações funcionam por teclado e em celular, com validação e erros sem falso sucesso.

## 5. Arquitetura e qualidade

Manter Phoenix, PostgreSQL e Gettext. Reaproveitar geradores, adaptando o CRUD ao fluxo especificado. Regras de cota, posições e cadastro com labels são atômicas no servidor. Configuração de ambiente não inclui segredos versionados.

A entrega exige testes relevantes, verificações do repositório e **cobertura mínima de 70%**, já exigida pelo CI. O percentual não substitui testes dos limites, devolução, conclusão, falhas e concorrência.

## 6. Critérios de aceite do MVP

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
| CA10 | Cadastro, seleção, ordem, devolução e conclusão funcionam em pt-BR, por teclado e em celular. |
| CA11 | Precommit e CI passam, com cobertura de testes de pelo menos 70%. |
| CA12 | Aplicação executa no ambiente de teste com configuração externa e sem segredos versionados. |
| CA13 | Abrir painel usa usuário padrão sem login; repetir seeds não o duplica e parâmetros não trocam o proprietário. |
| CA15 | Cadastro com várias labels existentes/novas persiste todos os vínculos; label incompatível rejeita a transação. |

## 7. Solução final, fora do MVP

| ID preservado | Evolução |
| --- | --- |
| RF08 | Contas e autenticação com dados privados por usuário. |
| RF09 / CA14 | Fuso escolhido no gerenciamento da conta. |
| RF11 / CA16 | Publicação remota com contas reais e configuração de produção. |

Troca de idioma e atualização automática da tela também ficam para evolução. Essas decisões não bloqueiam o MVP. Equipes, integrações, recorrência, IA e gestão completa de projetos continuam fora do produto definido.

## 8. Planejamento

O [índice de tarefas](tasks/README.md) separa os incrementos do MVP e as entregas futuras. Specs agregam arquitetura e casos de uso; status e evidências ficam nas tarefas.
