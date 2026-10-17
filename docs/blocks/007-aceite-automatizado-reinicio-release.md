# BLOCK-007 — Aceite automatizado de reinício do release

- Estado: aberto.
- Origem: TASK-050, critérios 1 e 3; SPEC-008 RN03/RN05 e CA-008-03.
- Data: 17/10/2026.
- Base inspecionada: `fb9432377522049d66ff84dc810264a4e0871b1c`.
- Relator: implementador `/root/task050`.

## Causa e evidência

A tarefa autoriza criar testes em `test/`, mas exige comprovar persistência após reinício do release local. O AGENTS.md exige validação por testes automatizados versionados e integrados à suíte e proíbe complementar aceite com scripts temporários ou testes manuais.

- `test/test_helper.exs` inicia ExUnit com Sandbox; `config/test.exs` executa a aplicação de teste, sem servidor. Reiniciar esse processo não verifica o artefato de produção.
- `scripts/e2e.sh` constrói e inicia o release, executa Playwright e remove seus recursos; não existe etapa de reinício entre preparação e verificação dos dados.
- `assets/e2e/authenticated.spec.ts` verifica persistência após recarga, sem reinício do release. `compose.e2e.yaml` não fornece controle Docker ao navegador, conforme o isolamento documentado.
- `.github/workflows/ci.yml` também constrói/inicia o release e executa Playwright, sem etapa de reinício. A integração existente do ciclo de vida está fora do `write_scope` da TASK-050.
- TASK-011 registra evidência histórica de reinício via `/tmp/planner-release-smoke.exs`, não um teste versionado da suíte. Esse registro foi preservado; não satisfaz uma execução nova sob a política atual.

## Trabalho preservado e impacto

Nenhum código alterado, teste avulso criado ou comando de reinício executado. TASK-050 permanece na análise inicial, `in_progress`, sem autoavaliação aprovada. TASK-056 e TASK-058 mantêm suas entregas e evidências; não há regressão demonstrada nelas. A lacuna impede consolidar CA-008-03 e o aceite final, não prova falha de persistência do produto.

## Encaminhamento ao planejador

Definir o contrato e a titularidade da integração de teste automatizado de reinício real do release com a suíte existente, incluindo escopos necessários. Não foi criado um orquestrador paralelo dentro de `test/`, ampliado escopo de tooling nem decidido o desenho da solução pelo implementador.

## Condição de retomada

Contrato/escopo autorizado e integração versionada permitem preparar duas contas com seus dados, reiniciar o release sobre o mesmo banco isolado e verificar preservação das relações, isolamento e validade/revogação de tokens conforme SPEC-008. A correção deve ter evidências e gates pertinentes aprovados e estar integrada; o coordenador confere essa condição antes de retomar TASK-050. Planejamento ou este relatório, isoladamente, não concluem o aceite.
