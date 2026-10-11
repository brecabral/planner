# Modelo de especificação

Copiar para `NNN-assunto.md`; substituir os campos ilustrativos. Metadados usam chaves técnicas em inglês; descrição e regras em português.

```yaml
---
id: "SPEC-NNN"
status: draft
requirements: ["RFxx"]
---
```

## Problema e resultado

Qual requisito é atendido e como o usuário observa o resultado.

## Escopo

Comportamentos incluídos, atores e exclusões.

## Arquitetura e casos de uso

Definir fronteiras, contratos entre componentes, propriedade dos dados e invariantes transversais. Agrupar os casos de uso da capacidade; não descrever comandos de scaffold nem transformar cada etapa técnica em outra spec.

## Regras de negócio

- RN01: condição, ação permitida e efeito observável; indicar se é confirmada ou proposta.
- Definir invariantes e transições quando relevantes, sem derivar o domínio de um schema experimental.

## Cenários de aceite

- CA01, vinculado a RN01: Dado um estado inicial, quando ocorre uma ação, então o resultado é verificável.
- Acrescentar exemplos de rejeição, limites e concorrência pertinentes.

## Dados e efeitos

Dados necessários, persistência, efeitos externos e compatibilidade; apenas o que afeta o contrato.

## Dúvidas bloqueantes

Perguntas e decisão necessária; remover o bloqueio apenas com evidência, não por hipótese do agente.

## Referências e entrega

Links para PRD/design e tarefas que implementam as regras. Ao concluir, relacionar critérios aos testes e à revisão integrada, sem copiar logs.
