---
id: "TASK-003"
status: planned
execution_level: human
execution_rationale: "Configuração do GitHub e escolha dos gates reservadas ao responsável humano pelo repositório."
specs: []
depends_on: []
provides: ["github-quality-gate"]
consumes: []
write_scope: [".github/workflows/", "mix.exs", "mix.lock", ".credo.exs", "README.md"]
blockers: []
---

# 003 — Proteger a main e configurar o CI no GitHub

**Execução humana.** Esta tarefa precisa ser concluída para liberar a remoção do CRUD (TASK-002) e, depois, a troca de idiomas (TASK-001).

## O que fazer

1. Confira se você tem permissão de administração e se o plano do GitHub permite proteger este repositório, especialmente se ele for privado.
2. Crie um workflow de GitHub Actions para PRs destinados à `main` e pushes na `main`, com um job de nome estável, por exemplo `quality`. Use versões de Elixir/OTP compatíveis com o projeto, dependências travadas e PostgreSQL de teste. Pode usar o Compose atual ou um serviço PostgreSQL do Actions; com serviço externo, configure `PLANNER_SKIP_COMPOSE=true` e as variáveis do README. Não use credenciais reais.
3. Crie um alias `mix ci`, em ambiente `test`, que execute compilação com warnings como erros, `format --check-formatted`, testes com warnings como erros e Credo em modo estrito. Credo é a única dependência nova sugerida inicialmente. O `precommit` atual não tem linter e corrige formatação; não basta reutilizá-lo sem adaptar a checagem para CI.
4. Faça o job rodar ao menos uma vez. Em Settings → Rules → Rulesets, crie uma regra ativa para `main` exigindo PR e o check `quality`, com branch atualizada antes de merge. Bloqueie force push e exclusão e não conceda bypass a pessoas ou bots que devam cumprir o gate. Alternativa: regra clássica em Settings → Branches, aplicando-a também a administradores.
5. Se houver outro revisor habilitado, exija uma aprovação. Se você trabalha sozinho, não imponha aprovação de outro usuário sem ter quem possa fazê-la; PR obrigatório e CI obrigatório continuam necessários.

O job obrigatório deve executar em todo PR, sem filtros de caminho que o deixem pendente nem `continue-on-error`/condições que permitam pular os testes. Configurar apenas status checks não impede, por si só, push direto: exigir PR também é necessário.

## Opção inicial recomendada

Comece com testes + compilação + formatação + Credo. Depois gere cobertura nativa como relatório, calibrando o limite após remover o código experimental. Não ative um percentual arbitrário: `mix test --cover` tem limiar padrão que pode falhar o job; para relatório inicial, configure explicitamente o limiar como zero e mantenha as falhas dos testes bloqueantes.

Evals de comportamento são os cenários das specs convertidos em testes. Não adicionar avaliador por LLM ou plataforma de qualidade agora. Opções de cobertura, aninhamento e duplicação: [referência de quality gate](../referencias/quality-gate.md).

## Quando está pronto

- PR com teste falhando ou formatação incorreta não pode ser mesclado; corrigir faz o check passar.
- A configuração ativa exige PR e rejeita push direto à `main` para os colaboradores/bots sujeitos à regra, sem bypass indevido; force push e exclusão estão bloqueados. Confira na interface/API; se testar bloqueio de push, use ambiente descartável com a mesma regra, sem arriscar conteúdo da `main`.
- Workflow e alias estão versionados, instruções de execução estão no README e há um PR de exemplo com check verde.

Registre aqui o link do PR/check e confirme que a proteção foi ativada. Se a opção não estiver disponível no plano ou as telas forem diferentes, consulte a [documentação de proteção do GitHub](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches).

## Confirmação

Pendente de execução e confirmação pelo responsável humano. Agentes não devem executar esta tarefa.

## Preparação autorizada do CI

O usuário autorizou explicitamente o agente a preparar o workflow e o alias CI. Foram adicionados `.github/workflows/ci.yml`, `mix ci`, Credo e cobertura informativa. Esta autorização é limitada à preparação local; ativação das regras no GitHub permanece humana e a tarefa continua pendente. O check a exigir é `quality`. A execução remota ainda depende de publicar as alterações.
