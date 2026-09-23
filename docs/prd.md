# PRD — Planner de prioridades diárias

Escopo atualizado em 23/09/2026 a partir das respostas do responsável pelo produto. Implementação pendente.

## 1. Problema e usuários

Pessoas que já organizam responsabilidades em outros lugares precisam escolher poucas ações para executar hoje. O Planner oferece um painel individual, acessível remotamente, para escolher prioridades e consultar conclusões. Cada usuário acessa somente seus próprios dados.

## 2. Objetivos

- Tornar explícitas a primeira, a segunda e a terceira prioridades do dia.
- Limitar a três escolhas por dia: devolver libera uma escolha; concluir não libera.
- Distinguir tarefas ainda não escolhidas das que foram escolhidas e não executadas.
- Preservar conclusões e permitir classificar tarefas com labels reutilizáveis.

O sucesso inicial é conseguir cadastrar, escolher, executar e consultar uma conclusão sem instrução externa, tanto no celular quanto no desktop.

## 3. Escopo funcional

| ID | Requisito |
| --- | --- |
| RF01 | Exibir backlog, hoje, retry e histórico do usuário autenticado. |
| RF02 | Selecionar uma tarefa de backlog ou retry para hoje, preservando identidade. |
| RF03 | Permitir no máximo três escolhas no dia do usuário e ordenar as prioridades. |
| RF04 | Concluir uma tarefa de hoje e registrar sua data de conclusão. |
| RF05 | Consultar o histórico persistente, com conclusões mais recentes primeiro. |
| RF06 | Cadastrar tarefa por título obrigatório. |
| RF07 | Reordenar prioridades e devolver manualmente uma tarefa de hoje ao backlog. |
| RF08 | Autenticar usuários e impedir acesso a tarefas, labels e configurações de outra conta. |
| RF09 | Definir o próprio fuso na página de gerenciamento da conta. |
| RF10 | Associar várias labels opcionais a uma tarefa, reutilizando labels próprias ou criando novas no cadastro. |
| RF11 | Disponibilizar a aplicação remotamente, com persistência e configuração de produção. |

## 4. Regras confirmadas

- O limite é de **três escolhas no dia**, não de três pendências simultâneas. Concluir mantém a escolha consumida; devolver manualmente ao backlog libera uma escolha.
- `backlog` reúne tarefas ainda não selecionadas; `today` reúne prioridades correntes; `retry` reúne tarefas selecionadas e não executadas. Retry oferece a mesma seleção para hoje que backlog.
- Na virada do dia, pendências de hoje vão para retry, sem conclusão automática.
- O dia depende do fuso definido pelo usuário em sua conta.
- Dados pertencem ao usuário; não há compartilhamento entre contas.
- Labels classificam tarefas livremente, por exemplo trabalho, estudo, pessoal ou projeto. Uma tarefa pode ter várias labels, provenientes do catálogo do próprio usuário.
- Conclusões permanecem no histórico. Reabrir ou excluir tarefas não integra o escopo definido.

Detalhes verificáveis e decisões ainda necessárias ficam na spec de cada comportamento, acessível pelo [índice de specs](specs/README.md).

## 5. Experiência

Hoje tem maior destaque, com prioridades numeradas e indicação de quantas escolhas já foram usadas. Backlog e retry são listas distintas com ação de selecionar. O formulário aceita título, escolha de labels existentes e criação de novas. Histórico e gerenciamento da conta permanecem acessíveis.

A interface oferece português do Brasil e inglês, estados vazios, validação junto aos campos e erros de gravação sem falso sucesso. As ações funcionam por teclado e em celular; reordenação não depende exclusivamente de arrastar.

## 6. Fora de escopo

Equipes, compartilhamento, responsáveis, subtarefas, dependências, agenda futura, recorrência, notificações de tarefas, importação, sincronização externa, pontuação automática, IA e gamificação. Labels de projeto não introduzem gestão de projetos.

## 7. Restrições de entrega

Manter Phoenix, PostgreSQL e Gettext. Regras e isolamento devem valer no servidor, inclusive sob concorrência e reconexão. Configurações e segredos são externos ao código. A entrega deve passar pelos gates de qualidade do repositório.

## 8. Critérios de aceite

| ID | Cenário e resultado |
| --- | --- |
| CA01 | Em conta sem tarefas, exibir estados vazios; título válido cria tarefa no backlog e título vazio não persiste. |
| CA02 | Selecionar do backlog ou retry move a mesma tarefa para hoje uma única vez; recarga mantém a seleção. |
| CA03 | Com as três escolhas consumidas no dia, concluir uma tarefa mantém a cota esgotada e uma nova seleção é rejeitada; concorrência não supera a cota. A restituição por devolução manual é verificada separadamente em CA05. |
| CA04 | Reordenação persiste prioridades consecutivas e únicas, sem aceitar tarefas de outra conta. |
| CA05 | Com três escolhas consumidas, devolver manualmente uma pendência ao backlog preserva identidade e labels e permite uma nova seleção; repetir a devolução não restitui outra escolha. |
| CA06 | Concluir retira a pendência e registra uma única conclusão; repetir não altera a data nem repõe escolha. |
| CA07 | Reiniciar mantém histórico, labels e contagem de escolhas por dia. |
| CA08 | Na virada do dia do usuário, pendências aparecem em retry; sessão aberta também atualiza. |
| CA09 | Falha de gravação informa erro e mantém o estado anterior, inclusive cota e labels. |
| CA10 | Em celular e por teclado, cadastrar, selecionar, reordenar e concluir funciona nos dois idiomas. |
| CA11 | A entrega passa pelos aliases de qualidade e pelo CI obrigatório. |
| CA12 | Configuração externa permite executar a entrega sem segredos versionados. |
| CA13 | Visitante não acessa dados privados; usuário A não lê nem modifica dados de B por URLs, eventos ou IDs forjados. |
| CA14 | O usuário salva fuso válido na própria conta; fuso inválido é rejeitado sem alterar preferência nem planejamento. |
| CA15 | Associar várias labels próprias ou criar novas no cadastro persiste os vínculos; label de outra conta é rejeitada integralmente. |
| CA16 | A aplicação remota autentica duas contas distintas e preserva seus dados isolados após reinício. |

## 9. Planejamento

O [índice de tarefas](tasks/README.md) relaciona entregas e critérios. Status, bloqueios e evidências de execução ficam somente nas tarefas.
