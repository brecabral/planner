---
id: "SPEC-007"
status: ready
requirements: ["RF14", "CA18"]
---

# 007 — Temas disponíveis e preferência por usuário

## Escopo e origem

Decisão de 11/10/2026: manter o claro existente e adicionar escuro, ambos gratuitos para todas as contas. O responsável confirmou créditos e loja para depois. Este contrato pronto cobre somente temas e sua disponibilidade; não autoriza saldo, cobrança ou compra.

## Arquitetura e regras

`Planner.Themes` possui catálogo e concessões; Accounts mantém a identidade e a referência de preferência. Tokens semânticos daisyUI existentes continuam sendo a fonte visual. Separar tema selecionado (preferência) de tema disponível ao usuário (concessão); não armazenar CSS arbitrário vindo do cliente.

- RN01: catálogo tem códigos estáveis `planner` (claro atual) e `planner_dark` (escuro), sem preço neste MVP. Catálogo/cores são definidos pela aplicação, não editados pelo usuário.
- RN02: cada conta real recebe concessão gratuita dos dois temas, com unicidade usuário/tema e origem `free`. Preparação inclui contas existentes e futuras, idempotente e transacional; não exige compra nem saldo. A conta não pode conceder temas a si própria por payload. Usuário legado não vira conta autenticável por receber preferência.
- RN03: preferência inicial é `planner`. Seletor permite escolher entre temas concedidos e persiste a seleção no servidor somente para o usuário autenticado. Reinício, recarga e novo dispositivo mantêm a escolha; um usuário não altera a preferência de outro. Código desconhecido/não concedido é rejeitado sem mudar a escolha.
- RN04: aplicar a preferência no HTML inicial autenticado e durante patches/reconexões. Login e páginas públicas usam claro; logout e troca de conta não carregam a preferência da conta anterior por localStorage/cookie global. Não seguir tema do sistema nem preferências antigas sem decisão explícita.
- RN05: ambos os temas cobrem painel, cadastro, menus, confirmações, histórico, flashes e estados de erro/arraste usando tokens semânticos; não alterar comportamento, cota, títulos ou labels.
- RN06: futura compra concederá uma relação de propriedade ao usuário, distinta da seleção. As concessões gratuitas existentes não serão cobradas retroativamente. Nesta entrega não há carteira, créditos fictícios, preço, loja, pagamento ou endpoint de compra; evolução na TASK-049, bloqueada por decisões próprias.

## Cenários de aceite

- CA-007-01: preparação repetida e cadastros novos recebem exatamente uma concessão por tema; falha não deixa concessão/preferência parcial. Contas já existentes também ficam habilitadas.
- CA-007-02: A escolhe escuro, recarrega/reconecta e preserva seleção; B continua claro. Novo login/dispositivo de A recupera escuro; logout mostra login claro.
- CA-007-03: evento com user_id alheio, código desconhecido ou tema sem concessão não muda preferência nem concede propriedade. Falha de persistência mantém tema confirmado e informa erro.
- CA-007-04: HTML inicial e patches conservam `data-theme` autorizado; ambos os conjuntos de tokens compilam, sem cores fixas que impeçam menus, formulário, estados e arraste de acompanhar o tema.

## Entregas

TASK-047 produz catálogo, concessões e preferência persistida; TASK-048 integra paletas/seletor e renderização. Não há dúvidas bloqueantes para esses dois temas. Monetização tem rascunho separado na SPEC-009.

## Correção do seletor e da aplicação visual — 14/10/2026

Origem: responsável relata que os temas não funcionam e solicita seleção na barra superior, ao lado de “Sair”. O relato confirma o problema percebido; sua causa técnica ainda não foi reproduzida neste planejamento.

- RN07: em `/tasks` e `/tasks/new`, apresentar um único seletor compacto com rótulo “Tema”, opções “Claro” e “Escuro” e valor atual visível, na barra superior imediatamente antes de “Sair”. Usar controle de seleção acessível por teclado, com nome acessível e foco visível. Remover os botões de tema do corpo do painel. Em 320 px e desktop, seletor e saída permanecem acessíveis sem sobreposição ou rolagem horizontal. Páginas públicas não exibem seletor.
- RN08: selecionar uma opção concedida e confirmar a persistência aplica imediatamente a paleta à página inteira, incluindo barra, fundo, painel e formulário aberto, sem recarregar manualmente. Durante gravação, indicar processamento e impedir envios repetidos pelo controle. Falha mantém a última escolha confirmada no controle e na página e apresenta erro acessível junto ao seletor. Preservar RN03–RN05.
- CA-007-05: conta autenticada em `/tasks` vê um único seletor “Tema” ao lado de “Sair”, com opção persistida selecionada; teclado permite alternar claro → escuro → claro. Em 320 e 1280 px os dois controles são utilizáveis; login e `/join` não apresentam seletor.
- CA-007-06: no navegador com assets compilados, alternar temas muda as cores computadas do fundo, barra e painel, e mantém texto legível. Abrir/fechar `/tasks/new`, atualizar dados do painel, recarregar e reconectar preserva a seleção e a paleta. Abrir diretamente `/tasks/new` recupera a preferência. Verificar CSS efetivo, não apenas atributo `data-theme` ou resposta do servidor.
- CA-007-07: falha de persistência mantém opção e paleta anteriores, permite nova tentativa e anuncia erro; código inválido/não concedido não altera preferência. Logout retorna ao claro, e login de outra conta aplica somente a preferência dela. Preservar os cenários CA-007-02/03.

Entrega corretiva: [TASK-054](../tasks/054-corrigir-temas-na-navbar.md). Reutilizar catálogo, concessões e preferência existentes, sem migration, novas paletas, tema do sistema, armazenamento global no navegador ou dependências adicionais. Sem dúvidas bloqueantes de produto; diagnóstico técnico faz parte da implementação.


## Acionador por ícone — 17/10/2026

Pedido explícito do responsável; substitui a apresentação permanentemente visível do seletor em RN07/CA-007-05, preservando RN01–RN06 e RN08. Planejado na TASK-059.

- RN09: em `/tasks` e `/tasks/new`, mostrar ícone de peça de quebra-cabeça com nome acessível “Tema”, antes do ícone de saída; quando a TASK-014 integrar idiomas, a engrenagem fica entre os dois. Não mostrar permanentemente “Tema:”, listbox ou valor selecionado na barra. Acionar o ícone abre as opções concedidas “Claro” e “Escuro”, identificando a seleção atual. Acionar novamente, clicar fora ou pressionar Escape fecha sem alterar preferência. Escolher uma opção usa a persistência existente e fecha após sucesso; falha mantém opções abertas, última seleção confirmada e erro. Impedir seleção repetida durante gravação. Páginas públicas continuam sem seletor.
- RN10: preservar operação por teclado e foco visível de RN07, nome traduzido e indicação de abertura no acionador; Escape devolve foco ao acionador. Usar ícones e componentes existentes, sem novas dependências ou paletas.
- CA-007-08: autenticado, opções começam fechadas; clique ou teclado no quebra-cabeça abre Claro/Escuro com opção atual identificada. Repetir acionamento, clicar fora e Escape fecham sem gravação. Escolher tema aplica paleta após confirmação e fecha opções; recarga e navegação para cadastro preservam preferência. Executar alternância nas duas direções no navegador e manter CA-007-06/07, incluindo falha e isolamento entre contas.
