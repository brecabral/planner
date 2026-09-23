---
id: "TASK-011"
status: "planned"
execution_level: "standard"
execution_rationale: "Adapta scripts e container gerados às versões, assets e configuração existentes."
specs: []
depends_on: ["TASK-032"]
provides: ["release-scaffold"]
consumes: ["accessible-planner-ui"]
write_scope: ["lib/planner/release.ex", "rel/", "Dockerfile", ".dockerignore", "README.md"]
blockers: []
---

# 011 — Gerar artefatos de release e container

## Entrada e limite

PRD RF11/CA12; consumir accessible-planner-ui. Manutenção de empacotamento sem nova regra de produto; referência Mix.

## Scaffold

```sh
mix phx.gen.release --docker
```

Consultar `mix help` antes de executar. O comando pertence à implementação desta tarefa; não foi executado no planejamento.

## Ajustes desta entrega

Revisar scripts migrate/server e imagens base conforme Elixir/OTP instalados, assets e dependências travadas. Excluir .env e arquivos sensíveis do contexto de build. Registrar build/migrations somente no README. Não publicar nem criar infraestrutura.

## Aceite e teste de intenção

1. Imagem/release é construída e inicializa em ambiente isolado com variáveis externas.
2. Artefato contém assets e scripts necessários, sem incluir segredos locais.

Escrever o teste de intenção antes dos ajustes; preservar testes gerados pertinentes e finalizar com `mix precommit`.

## Evidência e revisão

Pendentes. Registrar teste antes/depois, precommit, revisor independente, alvo/base, critérios, achados e integração. Não liberar consumidora antes de revisão aprovada e integração.
