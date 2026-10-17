---
id: "SPEC-001"
status: draft
requirements: ["CA10"]
---

# 001 — Idiomas da interface com Gettext

## Escopo e arquitetura

O MVP exibe somente português do Brasil, por decisão do responsável em 23/09/2026. Reutilizar `PlannerWeb.Gettext` e as convenções Phoenix: mensagens-base em inglês e traduções no catálogo `pt_BR`. Locale fixo para toda a aplicação; sem preferência, sessão de idioma, seletor ou detecção do navegador.

## Regras e casos de uso

- RN01: páginas, formulários, erros, plurais e nomes acessíveis aparecem em pt-BR. HTML usa `lang="pt-BR"`.
- RN02: HTTP e LiveView usam o mesmo locale fixo, inclusive após recarga. Configurar o backend/aplicação existente; não criar infraestrutura de troca de idiomas.
- RN03: títulos e labels digitados permanecem exatamente no idioma do conteúdo informado.

## Cenários de aceite

- CA-I01: abrir e recarregar o painel apresenta interface pt-BR e lang correto, sem seletor.
- CA-I02: cadastro inválido, limite de escolhas e demais erros usados no fluxo aparecem traduzidos via Gettext.
- CA-I03: singular/plural e nomes acessíveis usados no painel estão em pt-BR, sem traduzir conteúdo do usuário.

## Implementação

Configuração base e traduções das telas são passos distintos no [mapa de tarefas](../tasks/README.md). Suporte a outros idiomas fica fora deste contrato do MVP.


## Troca de idioma — evolução solicitada em 17/10/2026

O contrato pt-BR acima permanece histórico e implementado. O responsável autorizou seletor funcional por engrenagem e tradução de todos os textos da interface; isso substitui a exclusão de idiomas adicionais do MVP nesta evolução. O estado draft refere-se ao novo contrato, não revoga a entrega anterior. Entregas: TASK-013 (preferência e locale) e TASK-014 (catálogos e interface).

### Regras confirmadas

- RN04: engrenagem de configurações entre tema e saída na barra autenticada abre opções de idioma, com escolha atual identificada. Os três ícones mantêm centros na mesma altura em 320 e 1280 px. O ícone tem nome acessível traduzido “Configurações”; o grupo de opções é identificado por “Idioma”. Acionar novamente, clicar fora ou Escape fecha sem alterar preferência; Escape devolve foco ao acionador. Opções usam os nomes dos idiomas no próprio idioma.
- RN05: selecionar idioma permitido troca todos os textos fornecidos pela aplicação na tela atual, sem exigir recarga manual, incluindo navegação, títulos de página, botões, menus, temas, formulários, placeholders, validações, flashes, estados vazios, confirmações, plurais e nomes acessíveis. Textos criados após a troca também usam a seleção. Datas apresentadas e atributo HTML `lang` acompanham o idioma sem alterar data de negócio ou fuso.
- RN06: usar `PlannerWeb.Gettext`, mensagens-base em inglês e catálogos completos para os idiomas oferecidos; não usar tradução automática em runtime. Just Three permanece marca invariável. Títulos e labels do usuário permanecem intactos. O rótulo pt-BR de backlog é A fazer (SPEC-004 RN25).
- RN07: HTTP e processos LiveView resolvem o mesmo locale, inclusive em navegação, patch, recarga e reconexão. A troca preserva rota, painel de cadastro aberto, valores digitados, erros e dados do planejamento; textos já renderizados e mensagens armazenadas precisam ser reconstruídos no novo idioma. Não compartilhar locale global entre usuários.
- RN08: locale não permitido é rejeitado sem mudança da seleção. Gravação pendente impede envios repetidos; falha mantém idioma confirmado e mostra erro nele. Preferência de idioma não altera tema, sessão autenticada, tarefas, labels ou cota.

- RN09: oferecer exatamente Português (Brasil) (`pt_BR`, HTML `pt-BR`) e English (`en`, HTML `en`), conforme confirmação do responsável. Inglês usa as mensagens-base completas; pt-BR usa catálogo traduzido, incluindo “A fazer”. Sem preferência anterior, iniciar em pt-BR; não detectar idioma do navegador automaticamente.
- RN10: login (`/users/log-in`) e Criar conta (`/join`, incluindo acesso por `/users/register`) oferecem controle visível “Idioma” com as duas opções, utilizável sem autenticação. Não depender da engrenagem autenticada nem adicionar tema/saída às páginas públicas. Trocar idioma mantém URL e entradas do formulário, traduz textos e erros existentes e os produzidos depois da troca. Navegar entre login e cadastro conserva a escolha pública; recarga/reconexão também a preserva. O mecanismo e a precedência após login dependem da decisão de persistência abaixo.

### Aceites da evolução

- CA-I04: autenticado, abrir engrenagem exibe idiomas permitidos e seleção atual; escolher cada idioma troca todos os textos de RN05 e `lang`. Fechar sem escolher não altera estado. Tema, configurações e saída mantêm ordem e alinhamento nos dois tamanhos de viewport.
- CA-I05: trocar com cadastro aberto, rascunho e erro de validação mantém valores e formulário, mas traduz erro e controles. Criar erro, abrir confirmação, expandir histórico e alternar tema depois da troca produz textos no idioma atual. Dados escritos pelo usuário e marca não mudam.
- CA-I06: navegar, aplicar patch, recarregar e reconectar mantém a preferência conforme a persistência definida. Duas sessões de usuários diferentes não contaminam locales. Payload inválido e falha de gravação preservam idioma anterior e permitem nova tentativa.
- CA-I07: suíte versionada verifica catálogos sem traduções vazias ou fuzzy para os idiomas oferecidos, plurais, erros e textos dinâmicos. E2E percorre páginas e estados representativos em todos os idiomas; não considerar apenas a troca do rótulo ou `lang` como tradução completa.

- CA-I08: em sessão não autenticada, visitar login e `/join`, alternar Português (Brasil) ↔ English e verificar títulos, campos, botões, instruções, validações e `lang`. Navegar pelos links entre telas, recarregar/reconectar e entrar por `/users/register` conserva a escolha. Trocar com e-mail preenchido e erro visível mantém a entrada e traduz o erro. Validar nas duas larguras (320/1280 px), sem exibir controles autenticados.

### Decisões pendentes

- Persistência: perguntado ao responsável; conta entre dispositivos ou apenas navegador. A escolha pública já deve ser conservada entre login e cadastro; resta definir armazenamento durável e precedência ao entrar, sair e trocar de conta. Recomendação ainda não aprovada: preferência por conta após login e preferência no navegador antes da autenticação.

Idiomas e seletor público estão confirmados; TASK-013/014 permanecem bloqueadas somente pela definição de persistência e precedência. TASK-059 é independente e continua elegível.
