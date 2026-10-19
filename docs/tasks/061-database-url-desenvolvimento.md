---
id: "TASK-061"
status: planned
execution_level: standard
execution_rationale: "Altera configuração compartilhada entre desenvolvimento e testes, preservando precedência e isolamento das bases do CI e E2E."
specs: []
depends_on: ["TASK-060"]
provides: ["development-database-url"]
consumes: []
write_scope: ["config/database.exs", "config/dev.exs", "config/test.exs", "test/planner_config/", ".env.example", "README.md", "docs/tasks/061-database-url-desenvolvimento.md"]
blockers: []
---

# 061 — Usar DATABASE_URL em desenvolvimento

## Objetivo e contexto

Implementar a decisão D24 e o pedido do responsável de 19/10/2026: configurar o Repo em desenvolvimento com `DATABASE_URL` literal, mantendo variáveis separadas para o Compose e os testes. `specs: []` porque é manutenção de configuração, sem nova regra de produto. O `.env.example` já contém o exemplo de URL, mas o código ainda não o consome em dev.

Ler `config/database.exs`, `config/dev.exs`, `config/test.exs`, `config/runtime.exs`, `.env.example`, Compose local/de teste, receitas Just e `.github/workflows/ci.yml`. Consultar referências Elixir, Ecto, testes e Mix. A configuração do CI já exporta `DATABASE_URL` para o banco E2E e campos separados para ExUnit: preservar essa separação é essencial.

A dependência TASK-060 serializa README e `.env.example`; Resend não é requisito funcional do banco. Nenhum gerador, schema ou migration é necessário. Não introduzir biblioteca dotenv nem camada nova de configuração.

## Contrato e escopo

- Em dev, ler `DATABASE_URL` do processo com precedência sobre `.env` e entregar a URL ao Ecto. Não montar URL a partir dos campos antigos nem manter fallback silencioso para eles. Ausência ou valor vazio deve falhar identificando a variável, sem revelar credenciais. Reutilizar interpretação de URL do Ecto; não criar parser próprio de conexão.
- O leitor local aceita URLs literais com credenciais percent-encoded e parâmetros de consulta, sem interpolação, expansão de shell ou execução de conteúdo. Preservar comentários em linhas próprias e formato `KEY=value`; erros não devem imprimir linhas contendo segredos. Ajustar a validação restritiva atual somente no necessário para o contrato.
- Em test, continuar usando `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_HOST`, `POSTGRES_PORT` e `POSTGRES_TEST_DB` acrescido de `MIX_TEST_PARTITION`. Ignorar `DATABASE_URL` como fonte da configuração do Repo de teste, mesmo exportada para outra base. Preservar Sandbox e receitas de banco descartável.
- Manter os campos `POSTGRES_*` do `.env.example` necessários ao Compose/testes. Usar URL literal correspondente, sem referências entre variáveis. Orientar atualização conjunta de senha, banco e porta; manter exemplos de produção comentados e preservar os exemplos Resend da TASK-060.
- Atualizar o README para remover o aviso de que a URL ainda não é consumida em dev e documentar a migração manual dos arquivos `.env` existentes. Não ler nem editar o `.env` privado do responsável, alterar volumes, resetar dados ou executar migrations nesta tarefa.
- Produção continua com `config/runtime.exs` e variáveis do processo; configuração Neon/TLS, Fly, e-mail e deploy ficam fora do escopo. Não mudar workflow, Compose ou Just sem contrato adicional: os consumidores separados devem continuar funcionando.

## Aceite e testes

1. Com URL somente no arquivo de ambiente sintético, configuração dev aponta para essa URL. Com URL distinta exportada, prevalece a exportada. Dev não exige os campos separados quando sua URL está disponível.
2. URL ausente ou vazia falha de forma clara e sem expor valores. Valores sintéticos com credenciais percent-encoded e query string atravessam a leitura corretamente. Conteúdo do arquivo nunca é executado ou interpolado; erro de formato não revela credenciais.
3. Com URL apontando para base sintética diferente e campos de teste disponíveis, configuração test usa exclusivamente os campos de teste. Repetir com e sem partição e verificar nome correto da base. O caso reproduz o contrato do CI, onde a URL pertence ao E2E.
4. Testes automatizados versionados em `test/planner_config/` usam fixtures temporárias geridas pela própria suíte, sem acessar `.env` real ou banco remoto. Restaurar ambiente/configuração alterados e evitar interferência concorrente. Usar a configuração real como alvo; não duplicar a implementação no teste.
5. Gates locais e E2E completos continuam aprovados; exemplos e instruções correspondem ao comportamento implementado. Não afirmar conexão Neon ou publicação com base nesses testes.

## Execução e conclusão

Antes de iniciar, conferir integração da TASK-060. Aplicar TDD enxuto e fluxo de implementação, consultar ajuda Mix e executar os gates documentados no README: precommit, qualidade/cobertura mínima de 70% e E2E completo. Registrar autoavaliação pelo fluxo de review, evidências e limites nesta tarefa; revisão independente não é automática. Testes pertencem à suíte versionada, sem verificadores avulsos. Impedimentos seguem `docs/blocks`; não ampliar o escopo para contorná-los. Conferência operacional e commit de integração precedem `done`.

## Estado do planejamento

Criada em 19/10/2026, ainda não implementada. Aguarda TASK-060 para serializar arquivos compartilhados; nenhuma mudança de configuração executável ou ambiente privado nesta rodada.
