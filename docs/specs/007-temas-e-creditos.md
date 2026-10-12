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
