# Fluxo de review e validação de código

Perfil destinado a agentes de ponta. Aplica-se a revisão de PR/commit/diff, auditoria de implementação, testes, cobertura, evals e gates de qualidade. O implementador também usa este procedimento para autoavaliação, identificada como tal; aprovação independente deve vir de outro revisor de ponta.

## Contexto inicial

Identificar alvo exato e base de comparação: PR, intervalo de commits, branch ou alterações locais. Ler diff e histórico relevante, tarefa e critérios, regras da spec afetadas e evidências fornecidas. Não presumir que a base seja `main` nem confundir alterações de terceiros com a entrega revisada. Registrar o commit alvo ou, em mudanças não commitadas, quais arquivos/estado foram avaliados.

Expandir para funções chamadoras, contratos, configurações e testes quando necessário para verificar efeitos. Consultar DDD/design e referências somente dos conceitos atingidos. Uma revisão estreita não autoriza reescrever a arquitetura inteira.

## Procedimento

1. Relacionar cada critério de aceite a implementação e evidência. Procurar comportamento faltante, inventado ou incompatível com a spec; hipótese de produto não é fato para reprovar código.
2. Inspecionar diff e commits: efeitos colaterais, regressões, entradas inválidas, autorização, consistência de dados, concorrência, migrações e tratamento de erros conforme o risco real da mudança.
3. Conferir padrões Phoenix/Elixir do repositório, limites de contexto DDD, nomes, Gettext, configuração externa e uso das dependências estabelecidas. Avaliar tanto adição desnecessária quanto reimplementação indevida de capacidade crítica já disponível, como Req ou Gettext.
4. Avaliar duplicação de regra de negócio, coesão, acoplamento, SOLID, DRY e padrões de projeto como instrumentos. Reportar problema concreto; não exigir abstração, padrão ou camada apenas por preferência estética. Semelhança textual isolada não prova duplicação de responsabilidade.
5. Avaliar os testes: verificam intenção ou repetem a implementação? Cobrem rejeições e invariantes relevantes? Podem passar com comportamento errado? Conferir fixtures, isolamento e fragilidade.
6. Executar verificações pelos aliases Mix documentados. Conferir a ajuda antes de usar opções novas. Usar ferramentas de diff, compilação, testes, cobertura e análise estática já disponíveis; para lacunas de ferramental, registrar proposta específica em vez de instalar dependências automaticamente.
7. Avaliar cobertura do código alterado e dos caminhos críticos. Registrar métrica disponível, escopo, ferramenta, versão/base quando relevantes e limitações. Comparar antes/depois quando mensurável; redução justificada pela remoção de código não é regressão automática. Cobertura de linhas não prova qualidade e não mede todos os ramos; se não houver métrica, informar a lacuna, nunca inventar um número.
8. Fazer avaliação comportamental (eval) com os cenários de aceite. Em workflows de LLM/skills, quando alterados, usar casos representativos, saída esperada e rubrica de sucesso/erro; não introduzir framework de eval de LLM em uma mudança comum de código que não usa modelos.

## Gate e relatório

O gate considera aderência aos critérios, testes relevantes, verificações obrigatórias, política de cobertura existente e ausência de achados bloqueantes. Não há percentual de cobertura aprovado no projeto até que uma decisão o estabeleça. Usar métricas como evidência e investigar caminhos críticos descobertos.

Entregar: alvo/base; critérios atendidos ou não verificados; comandos e resultados; cobertura/evals com limites; achados por gravidade; conclusão `approved`, `changes_requested` ou `blocked`. Para cada achado, informar arquivo/linha, condição que dispara o erro, impacto e correção esperada. Separar sugestões não bloqueantes de defeitos reproduzíveis. Ausência de achados não equivale a teste executado.

Registrar o resumo no campo de revisão da tarefa, com identidade do revisor, alvo e evidência. Código alterado após a revisão exige reavaliar o diff novo e os critérios afetados. `approved` é avaliação técnica, não autorização para merge/deploy e não prova integração. Não corrigir silenciosamente o código em uma solicitação apenas de revisão; quando correções forem autorizadas, separar implementação e revalidação.

## Autoavaliação

Implementadores aplicam os mesmos critérios, registram resultados e encaminham para revisão independente. Não podem preencher sua própria aprovação como revisão independente. Falhas de infraestrutura tornam a verificação correspondente bloqueada, não aprovada; não ampliar escopo só para mascarar a falha.

## Tarefas humanas

Verificar `execution_level` antes de executar. Se for `human`, ou existir pré-requisito humano incompleto, aplicar a [reserva do AGENTS.md](../../AGENTS.md#execução-exclusiva-por-humano): informar a intervenção necessária e recusar execução dessa tarefa. Explicação e inspeção de evidências em leitura são permitidas; execução parcial, delegação e reclassificação para contornar o bloqueio não são.
