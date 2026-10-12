---
id: "SPEC-008"
status: draft
requirements: ["RF11", "CA16", "CA19"]
---

# 008 — Entrega do MVP de produção

## Escopo

Empacotar a aplicação com contas isoladas, magic link, ajustes de tarefas e dois temas gratuitos. Release local pode ser preparada antes do destino remoto; publicação depende de decisões externas, não de implementar créditos, idiomas ou fuso.

## Contratos confirmados

- RN01: release contém assets e migrations, executa com configuração externa e banco PostgreSQL persistente; não inicia Compose de desenvolvimento nem cria conta compartilhada acessível. Não inclui segredos na imagem/repositório. Assets usam dependências e lockfiles existentes.
- RN02: produção usa domínio/HTTPS e entrega real de magic link pelo Swoosh existente, com host correto e remetente configurado. Não usar mailbox local como transporte de produção. Falha no envio não autentica usuário nem anuncia entrega efetiva não confirmada.
- RN03: rotas de desenvolvimento ficam ausentes; reinício preserva contas, tokens válidos segundo suas regras, tarefas, cotas, labels, concessões e preferências. Scripts de migration não resetam nem transferem dados legados.
- RN04: backup/restauração precisa ser comprovado em destino isolado, preservando relações de proprietário, histórico, cota e temas. Não testar restauração destruindo a base ativa.
- RN05: aceite integrado exercita cadastro, entrega de link, login/logout, duas contas isoladas, exclusão e retry → backlog, temas, persistência após reinício e restauração. Gates mantêm cobertura mínima de 70%; evidências automatizadas não equivalem a publicação nem a teste visual real.
- CA-008-01: construir release local e iniciar com banco/configuração de teste permite migrations e acesso sem Mix no runtime; arquivos e imagens não contêm segredos locais.
- CA-008-02: no destino homologado, link entregue ao e-mail correto usa host HTTPS correto, permite login e rejeita reuso; contas A/B permanecem isoladas e `/dev/mailbox`/`/dev/dashboard` não existem.
- CA-008-03: reiniciar release e restaurar backup isolado preservam dados/relacionamentos e preferências das duas contas; registrar evidência do procedimento.
- CA-008-04: aceite integrado das SPEC-002/004/005/007 passa no artefato candidato; publicação usa esse artefato e registra destino/versão e verificação posterior.

## Dúvidas bloqueantes

Responsável confirmou em 11/10/2026 que hospedagem, domínio e serviço de e-mail ainda não foram escolhidos. Definir também remetente, destino/retenção de backups e acesso necessário para validar o ambiente. Essas escolhas bloqueiam runtime específico, restauração remota e publicação, não tarefas locais. Não presumir fornecedor, criar conta externa ou enviar e-mail real durante planejamento.

## Entregas

TASK-011 cobre empacotamento local usando RN01/CA-008-01 já definidos, com SPEC-005/007 prontas como entrada; SPEC-008 permanece rascunho para a parte remota. TASK-033, TASK-035, TASK-050 e TASK-034 só iniciam com contrato remoto pronto e dependências integradas. Procedimentos operacionais serão escritos exclusivamente no README durante implementação.
