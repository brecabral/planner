---
id: "SPEC-001"
status: draft
requirements: ["CA10"]
---

# 001 — Idiomas da interface

Origem: suporte a pt-BR e inglês solicitado pelo usuário; [design D09](../design.md#d09--idiomas-com-gettext).

## Arquitetura e casos de uso

Internacionalização é uma capacidade transversal de apresentação: mesma política para navegação HTTP, montagem/reconexão LiveView, formulários, erros e nomes acessíveis. `PlannerWeb.Gettext` é o backend único. Locale pertence à sessão/processo, não ao estado global da aplicação; identidade de conta e conteúdo do usuário não são traduzidos.

O contrato abrange escolher idioma, persistir preferência, aplicar fallback e manter isolamento. Plug HTTP, hook LiveView e seletor são entregas separadas que implementam a mesma spec.

## Escopo e regras

- RN01 (confirmada): a interface oferece português do Brasil e inglês, com seletor acessível por teclado. Locales internos `pt_BR`/`en`; identificação HTML `pt-BR`/`en`.
- RN02 (proposta): sem preferência válida, usar pt-BR.
- RN03 (proposta): a escolha é persistida na sessão e mantida em navegação, recarga e reconexão; não depende de cadastro. Não sincronizar entre dispositivos ou detectar idioma do navegador nesta entrega.
- RN04 (confirmada): uma sessão não altera o idioma de outra; conteúdo digitado pelo usuário não é traduzido.
- RN05 (proposta): entrada de locale desconhecido não altera a preferência válida existente; sem preferência válida, aplicar RN02. Não falhar com erro 500.
- RN06 (confirmada): textos da interface preservada, flashes, acessibilidade, erros e plurais utilizados têm versões pt-BR e inglês. Não traduzir o CRUD que será removido.

## Cenários de aceite

| ID | Dado / Quando / Então | Regras |
| --- | --- | --- |
| CA-I01 | Sem escolha anterior, abrir uma página mostra pt-BR e o seletor disponível. | RN01, RN02 |
| CA-I02 | Escolher inglês atualiza os textos e `lang`; navegar, recarregar e reconectar preservam inglês. Voltar a pt-BR funciona da mesma maneira. | RN01, RN03 |
| CA-I03 | Duas sessões escolhem idiomas diferentes e mantêm seus próprios textos; valores informados pelo usuário permanecem idênticos. | RN04 |
| CA-I04 | Enviar locale inválido mantém a escolha anterior; sem escolha válida, utiliza o padrão, sem erro 500. | RN02, RN05 |
| CA-I05 | Provocar uma validação e exibir singular/plural usados pela interface resulta em mensagens corretas nos dois idiomas. | RN06 |
| CA-I06 | Operar o seletor por teclado permite identificar, escolher e confirmar a opção. | RN01 |

## Dados e implementação

Persistir somente a preferência de idioma conforme RN03. A integração reutiliza Gettext, aplica locale em HTTP e LiveView e protege a atualização de sessão com CSRF. Procedimentos e origem técnica: [Gettext](../referencias/gettext.md). Não criar novas entidades de domínio para essa funcionalidade.

## Dúvidas bloqueantes

Confirmar pt-BR como padrão, persistência em sessão e política de locale inválido (RN02, RN03, RN05). Manter `draft` até essas decisões serem confirmadas.

## Implementação

Distribuída em tarefas pequenas; consultar o [mapa de entregas](../tasks/README.md). Esta spec permanece o contrato comum dos casos de uso acima.
