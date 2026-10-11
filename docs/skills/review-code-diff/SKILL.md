---
name: review-code-diff
description: Revisar commits, diffs ou entregas do Planner contra a tarefa e specs, atribuindo regressões corretamente e verificando testes, cobertura e gates; sem corrigir código durante uma revisão.
---

# Revisar código e evidências de entrega

Aplicar o [fluxo de review](../../fluxos/review.md). Esta skill complementa o fluxo com decisões de escopo, atribuição de falhas e validação da evidência; não substitui suas regras de aceite.

## Fixar o objeto da revisão

Resolver os commits antes de ler o diff. “HEAD com o commit anterior” significa o diff do primeiro pai de HEAD para HEAD, salvo indicação diferente. Informar ambos os SHAs e separar alterações locais, staged e arquivos não rastreados. Não presumir main nem usar alterações locais de tarefa/spec como parte de um commit antigo sem explicitar que são uma decisão posterior aplicável.

Ler tarefa, critérios, dependências, evidências e regras atingidas; expandir para chamadores e referências técnicas só quando necessário. Se o código executável local divergir do alvo, validar em checkout isolado ou declarar a limitação: resultados da árvore modificada não comprovam aquele commit. Não restaurar arquivos do usuário para obter uma árvore limpa.

## Julgar o diff pelo contrato

- Conferir o caminho real de cada critério e as superfícies deixadas para trás: rotas, imports, fixtures, seeds, migrations e referências. Remover um CRUD experimental não exige criar um substituto.
- Avaliar mudanças destrutivas pelo escopo explícito. Se o responsável decidiu remover uma migration experimental e preparar uma base nova, não exigir migração compensatória como regra universal. Isso não autoriza o revisor a executar reset ou apagar dados.
- Conferir se testes detectam regressões de comportamento. Teste negativo de rota removida é evidência pertinente; teste de infraestrutura isolada não prova um fluxo integrado. Texto incidental de scaffold geralmente é fragilidade opcional, não defeito funcional bloqueante.
- Examinar isolamento, atomicidade, entradas, concorrência e reconexão quando forem atingidos pelo diff. Não exigir login, fuso configurável ou sincronização se estiverem fora do contrato vigente.

## Validar sem ampliar o escopo

Ler aliases e a ajuda Mix pertinente antes dos comandos; seguir o [README](../../../README.md) e a [política de qualidade](../../referencias/quality-gate.md). Distinguir comandos de leitura dos que formatam arquivos, alteram lockfile ou preparam banco. Usar base de teste isolada quando necessário; nunca tratar teste como autorização para reset humano.

Executar verificações proporcionais e registrar comando, base, resultado e limitações. Quando o usuário proíbe alterações, não executar um alias que possa corrigi-las silenciosamente; usar verificações sem mutação e declarar o que não foi repetido. Se houver restrição de infraestrutura, registrar a falha sem inferir aprovação. Documentação apenas pode ser validada por estrutura, links e coerência sem repetir testes de aplicação já conhecidos, observadas as instruções vigentes.

Uma evidência do implementador é uma evidência relatada até ser reproduzida. Não afirmar que o diff prova a ausência de comandos externos executados no passado. Não iniciar implementação para tornar o gate verde durante a revisão.

## Atribuir falhas e decidir o gate

Comparar configuração e código relevantes com a base antes de classificar uma falha como regressão. Um limiar preexistente que reprova o alvo continua impedindo aprovação quando obrigatório, mas não deve ser apresentado como introduzido pelo diff. Sem medir os dois estados, não afirmar aumento ou redução de cobertura.

Relatar separadamente: defeitos introduzidos, problemas preexistentes que impedem aceite, sugestões e verificações não realizadas. “Nenhum defeito encontrado” não significa “CI aprovado”. A remoção de código/testes autorizada também não demonstra perda de qualidade somente pela quantidade de linhas removidas.

Consultar a política vigente, sem copiar o percentual para esta skill. Não diminuir limiar, excluir módulos, adicionar testes sem asserções úteis ou reabrir a tarefa humana do gate para facilitar aprovação. Encaminhar impedimentos conforme [docs/blocks](../../blocks/README.md), reutilizando a causa já registrada quando cabível e respeitando o escopo de escrita autorizado.

## Entrega da revisão

Usar os estados do fluxo: `changes_requested` para defeitos que exigem correção; `blocked` para aceite impedido por gate/infraestrutura ou evidência obrigatória indisponível; `approved` somente com critérios e gates aplicáveis satisfeitos. Podem coexistir defeitos e impedimentos: descrevê-los sem esconder um pelo outro.

Cada achado acionável precisa de localização precisa, condição de ocorrência, impacto e correção esperada. Vincular comentários inline somente a linhas pertinentes; não atribuir uma configuração preexistente a uma linha arbitrária do diff para produzir um comentário.

Registrar alvo/base, identidade e independência, critérios, comandos/resultados, cobertura e limites. Seguir o destino pedido pelo usuário; não escrever na tarefa se ele restringiu a entrega ao relatório. Revisão de código que o próprio agente implementou é autoavaliação, não aprovação independente. Aprovação não confirma integração nem autoriza commit, push ou deploy por si só.

Para validar alterações desta skill, usar os [casos de avaliação](references/cenarios.md), sem executar ações reais dos exemplos.
