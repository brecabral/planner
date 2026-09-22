# Quality gate: verificações e limites

Avaliação em 22/09/2026. O alias atual `precommit` executa compilação com warnings como erros, limpeza de dependências não usadas, formatação e testes. Não inclui Credo, análise de clones ou evals específicos. Credo foi posteriormente adicionado ao alias `ci`, junto da checagem de formato e testes com cobertura informativa. As demais ferramentas abaixo continuam opcionais.

## Opções

| Opção | Componentes | Uso |
| --- | --- | --- |
| Mínima, sem dependência nova | Compilação, checagem de formato, ExUnit | Primeira barreira reproduzível; não cobre lint de estilo/aninhamento. |
| Recomendada inicialmente | Mínima + Credo estrito | Acrescenta análise estática e aninhamento com pouco ferramental. |
| Evolução após estabilizar | Relatório/limiar de cobertura e detector de clones calibrado | Adicionar somente após medir a base e revisar falsos positivos. |

## O que pode ser automatizado

- **Formatação:** `mix format --check-formatted` detecta divergência; `mix format` sozinho apenas corrige arquivos.
- **Lint e aninhamento:** Credo analisa código estaticamente. `Credo.Check.Refactor.Nesting` detecta profundidade de estruturas aninhadas; não equivale a proibir toda função anônima dentro de outra função. Configurar limites e conferir os checks habilitados. Não precisa inventar parser próprio.
- **Cobertura:** Mix oferece cobertura de linhas nativa com `--cover`, sem exigir ExCoveralls/serviço externo. O limiar padrão documentado é 90; para medir sem reprovar pela porcentagem inicialmente, explicitar `test_coverage: [summary: [threshold: 0]]`. Testes que falham continuam reprovando. Definir limiar real posteriormente, considerando módulos relevantes e justificando exclusões; cobertura não prova todos os ramos ou qualidade das asserções.
- **Duplicação:** jscpd é uma opção de detecção de clones por tokens. Antes de adotá-lo, validar suporte da versão escolhida a Elixir/HEEx e calibrar contra exemplos do repositório. Não é parte do gate inicial. Clones textuais não demonstram violação de DRY; regras equivalentes escritas de formas diferentes podem escapar.
- **Evals:** critérios com entradas e saídas definidas viram testes ExUnit/LiveView reproduzíveis. Para avaliar skills/LLMs futuramente, separar casos/rubrica e medir variabilidade; um juiz LLM não é um gate determinístico. O aplicativo atual não precisa desse serviço.
- **SOLID e padrões:** análise estática oferece sinais, não uma prova de bom design. Avaliar responsabilidade, acoplamento e duplicação semântica no fluxo de review.

Ferramentas estáticas produzem resultados repetíveis com versões, configurações e entradas fixas; testes podem depender do ambiente. Manter lockfile e versão de Elixir/OTP coerentes, e investigar flakiness em vez de escondê-la.

## GitHub

Rulesets ou proteção clássica podem exigir PR e checks obrigatórios. Somente CI verde não bloqueia push direto. Configurar a regra como ativa e controlar bypass; a proteção clássica não inclui administradores por padrão. A disponibilidade depende do plano e da visibilidade do repositório. A [tarefa humana 003](../tasks/003-infra-github.md) descreve os passos, sem configurar o GitHub automaticamente.

## Fontes oficiais e dos projetos

- [Proteção de branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches) e [rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets).
- [Credo](https://credo.hexdocs.pm/overview.html) e [Nesting](https://credo.hexdocs.pm/Credo.Check.Refactor.Nesting.html).
- [Cobertura nativa do Mix](https://mix.hexdocs.pm/Mix.Tasks.Test.html#module-coverage).
- [jscpd](https://github.com/kucherenko/jscpd).
