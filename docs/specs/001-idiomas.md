---
id: "SPEC-001"
status: ready
requirements: ["CA10"]
---

# 001 — Interface pt-BR com Gettext

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
