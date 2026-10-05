# BLOCK-004 — Validação de acessibilidade em navegador

- Estado: resolvido por decisão de escopo em 05/10/2026.
- Origem: TASK-032, em 04/10/2026, implementador `/root/implement_mvp`.
- Base: `69d4a20`, com TASK-030 integrada.

## Causa e evidência

TASK-032 exige demonstrar operação por teclado em 360px e desktop. Testes LiveView verificam estrutura e eventos, mas não executam foco, layout nem teclado reais. Não há ferramenta de navegador MCP disponível. Inspeção local encontrou `/usr/bin/firefox` e Node, mas não Chromium/Chrome, Playwright ou Puppeteer nas localizações usuais consultadas.

Tentativa de Firefox headless com perfil exclusivo em `/tmp/planner-firefox-task032` e depuração remota na porta 9222 terminou com sinal 11 (código 139), antes de disponibilizar uma sessão. A hipótese de restrição do sandbox motivou solicitação de escalonamento pela ferramenta. Essa solicitação foi abortada pelo usuário após aproximadamente 23 segundos; não houve autorização concedida nem confirmação de execução externa. O sinal 11, isoladamente, não prova a causa técnica da falha.

## Trabalho preservado e impacto

Nenhuma alteração de código, CSS, tradução ou teste foi feita nesta tarefa. Documentos/contratos e arquivos de entrada foram inspecionados. Alterações operacionais preexistentes preservadas. Execução interrompida em `in_progress`, sem staging/commit e sem alegar aceite ou gates desta entrega. TASK-008 permanece impedida pela dependência de TASK-032.

## Condição original de retomada

É necessário disponibilizar execução de navegador autorizada e funcional para registrar teclado, foco e layout nos dois tamanhos, ou encaminhar evidência equivalente de validação humana explicitamente executada. A interrupção da solicitação não equivale a permissão para tentar execução externa por outro meio. Coordenador deve encaminhar a limitação; implementação não decide dispensa do aceite nem instala infraestrutura fora do escopo.

Retomada exige comprovar acesso autorizado ao navegador ou registrar decisão explícita sobre o processo de validação. Depois disso, executar os ajustes de TASK-032, testes de intenção, avaliação do fluxo real e gates obrigatórios. Nenhum aceite foi reduzido por este registro.


## Resolução por decisão do responsável — 05/10/2026

O responsável determinou: “deixe essas questoes para validação humana, fora das tasks”. Teclado, foco, layout em 360px/desktop e anúncios reais por tecnologias assistivas ficam na seção de validação humana do PRD, pendentes e fora dos gates das tarefas. PRD CA10, SPEC-004 CA-004-02 e TASK-032 foram alinhados para validação de comportamento e estrutura com os testes LiveView existentes, sem adicionar ferramentas ou infraestrutura.

A decisão explícita e sua incorporação aos contratos resolvem a causa deste bloqueio; não houve correção técnica nem comprovação de navegador funcional. TASK-032 pode retomar em `in_progress` para executar o escopo remanescente, testes e gates já previstos. TASK-008 continua dependente da conclusão, revisão e integração de TASK-032. Nenhuma validação humana, tarefa ou entrega foi considerada concluída por esta alteração documental.
