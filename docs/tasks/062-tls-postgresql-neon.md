---
id: "TASK-062"
status: planned
execution_level: standard
execution_rationale: "Configura transporte seguro do Postgrex e precedência da URL, preservando migrations e release E2E com banco isolado sem TLS."
specs: ["SPEC-008"]
depends_on: ["TASK-061"]
provides: ["verified-postgres-tls-config"]
consumes: []
write_scope: ["config/runtime.exs", "test/planner_config/", "compose.e2e.yaml", ".github/workflows/ci.yml", ".env.example", "README.md", "docs/tasks/062-tls-postgresql-neon.md"]
blockers: []
---

# 062 — Configurar TLS verificado para PostgreSQL Neon

## Objetivo e entradas

Implementar SPEC-008 RN09 e CA-008-08–09. Consultar D24, `config/runtime.exs`, Postgrex/Ecto instalados, Dockerfile (já inclui certificados CA), release/migrations e referências Ecto, Elixir e testes. Fonte técnica: [Neon com Ecto](https://neon.com/docs/guides/elixir-ecto). Não usar `sslmode=require` como prova de que o Postgrex ativou TLS.

TASK-061 serializa testes de configuração, README e exemplo de ambiente; a TASK-060 ancestral já terá alterado runtime e ambiente E2E. Usar recursos existentes, sem gerador ou dependência adicional.

## Entrega e aceite

1. Em prod, `DATABASE_SSL` ausente ou `true` configura TLS com `cacerts: :public_key.cacerts_get()` e verificação de cadeia/hostname, preservando defaults seguros do Postgrex. `false` desativa TLS apenas por opção explícita. Outros valores, inclusive vazio, falham identificando a variável sem imprimir segredos.
2. Considerar a precedência real do Ecto sobre opções da URL. Rejeitar parâmetros de SSL na URL que contradigam a política, em vez de permitir downgrade silencioso. Documentar URL compatível e não implementar parser PostgreSQL próprio. Não desligar verificação para contornar certificado ou rede.
3. Passar `DATABASE_SSL=false` explicitamente aos bancos isolados de release E2E e CI, inclusive etapa de migration. Não alterar TLS de dev/test nem dados locais. Preservar variáveis Resend sintéticas da TASK-060.
4. Testes versionados em `test/planner_config/` cobrem padrão seguro, flag explícita, valores inválidos, tentativa de downgrade por URL e opções efetivas entregues ao Repo. Restaurar ambiente e configuração; não usar credenciais ou banco Neon real. E2E completo comprova compatibilidade do release com a exceção local, sem alegar handshake Neon executado.
5. README e `.env.example` explicam a configuração e distinguem padrão de produção da exceção de teste. Nenhuma criação de conta, configuração Fly, backup ou deploy.

## Execução e conclusão

Aplicar TDD enxuto; consultar ajuda Mix e referências antes de modificar. Executar precommit e qualidade com cobertura mínima de 70%, além de E2E completo, pelos comandos do README. Registrar autoavaliação pelo fluxo de review, resultados e limites; sem revisão independente automática. Só marcar `done` após conferência operacional e integração. Impedimentos seguem `docs/blocks`.

Planejada em 19/10/2026; não implementada, aguardando TASK-061.
