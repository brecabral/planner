---
id: "TASK-001"
status: planned
execution_level: advanced
execution_rationale: "Integra locale entre HTTP, sessão e processos LiveView, com isolamento, reconexão e validação de entrada."
specs: ["SPEC-001"]
depends_on: ["TASK-002"]
provides: ["interface-locale-switching"]
consumes: ["experimental-crud-removed"]
write_scope:
  - "lib/planner_web/"
  - "priv/gettext/"
  - "config/config.exs"
  - "test/planner_web/"
  - "test/support/"
  - "mix.exs"
  - "README.md"
blockers:
  - "Confirmar RN02, RN03 e RN05 da SPEC-001 e marcar a spec como ready."
---

# 001 — Integrar troca de idiomas com Gettext

## Objetivo e contexto mínimo

Implementar a [SPEC-001](../specs/001-idiomas.md), critérios CA-I01 a CA-I06. Consultar [Gettext](../referencias/gettext.md) para a integração técnica. `PlannerWeb.Gettext` e os helpers web já existem; verificar o estado da base após TASK-002 antes de editar.

## Escopo exclusivo

Entregar `interface-locale-switching`: seletor acessível, persistência da preferência, aplicação do locale em HTTP/LiveView, `lang` correspondente e catálogos da interface preservada. Atualizar a documentação de operação quando houver novo comando. Não remover CRUD nesta tarefa, não recriar domínio nem adicionar autenticação.

Usar a integração existente, proteger alterações de sessão e manter redirecionamentos internos seguros. Não criar uma tela de produto apenas para testar montagem LiveView; usar fixture quando necessário. Rotas, layout e README são arquivos transversais também afetados pela limpeza, por isso a dependência de TASK-002 é explícita.

## Aceite e teste de intenção

Antes de implementar, escrever testes para preferência/persistência e entrada inválida, isolamento entre sessões e locale no ciclo LiveView. Cobrir plural/validação com exemplos relevantes, sem repetir um teste para cada mensagem. Usar IDs estáveis e conferir CA-I01 a CA-I06. Revisar extração/mesclagem dos catálogos conforme a referência técnica; finalizar com `mix precommit`.

## Evidência e retomada

Implementação pendente. Ao executar, registrar a entrega integrada, critérios verificados, resultado dos testes e qualquer próximo passo. Não marcar conclusão enquanto a spec ou a dependência estiverem pendentes.

## Revisão independente

Pendente. Na execução, registrar revisor de ponta, alvo/base, critérios verificados, evidências de testes/cobertura/evals aplicáveis, achados e decisão do gate conforme o [fluxo de review](../fluxos/review.md). A autoavaliação do implementador não substitui esta etapa. Integração ainda pendente.
