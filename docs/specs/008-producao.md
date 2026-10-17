---
id: "SPEC-008"
status: ready
requirements: ["RF11", "CA16", "CA19"]
---

# 008 — Entrega de código Phoenix e release local

## Escopo e origem

Decisão do responsável em 13/10/2026: entregar código Phoenix funcional; infraestrutura e operação remota ficam sob sua responsabilidade. Substitui o contrato remoto anterior desta spec, preservando os IDs. Prontidão do contrato não significa implementação concluída.

## Regras

- RN01: release contém assets e migrations, executa com configuração externa e PostgreSQL; não inicia Compose de desenvolvimento nem cria conta compartilhada acessível. Não inclui segredos na imagem/repositório. Assets usam dependências e lockfiles existentes.
- RN02: e-mail reutiliza Planner.Mailer/Swoosh e os fluxos Phoenix existentes. Desenvolvimento captura mensagens na mailbox local; testes capturam mensagens sem envio externo. A configuração de adapter, credenciais e remetente reais cabe posteriormente ao usuário. Não criar abstração de provedores nem escolher serviço para esta entrega. Falha de envio não autentica nem anuncia entrega efetiva não confirmada.
- RN03: rotas de desenvolvimento ficam ausentes na configuração de produção. A estrutura do banco é criada e evoluída pelas migrations do Ecto; o runtime usa a estrutura previamente migrada, sem criar ou reparar tabelas, índices ou constraints. Scripts de migration não resetam nem transferem dados legados.
- RN04: backup, retenção e restauração de ambiente remoto estão fora da entrega de código e sob responsabilidade do usuário; não constituem gate do release local.
- RN05: aceite integrado exercita cadastro, captura de link, login/logout, duas contas isoladas, exclusão e retry → backlog, temas. Não exige teste de durabilidade do banco ou de persistência após reinício do release. Gates mantêm cobertura mínima de 70%. Evidências distinguem testes da aplicação, smoke test do release e limites de navegador.

## Cenários de aceite

- CA-008-01: dado banco isolado e configuração de teste, construir e iniciar o release permite migrations e acesso sem Mix no runtime; artefato contém assets e não contém segredos locais.
- CA-008-02: dado adapter local em desenvolvimento ou de teste nos testes, solicitar link captura destinatário/URL corretos; consumir o link autentica e reuso/expiração são rejeitados conforme SPEC-005. Falha de envio não concede sessão. Na configuração de produção, rotas de desenvolvimento estão ausentes. Nenhum envio externo é exigido.
- CA-008-03: retirado por decisão do responsável em 17/10/2026. Persistência após reinício não constitui aceite da aplicação; ID reservado para preservar referências históricas.
- CA-008-04: dado release identificado por versão/base, consolidar evidências das SPEC-002/004/005/007, gates e smoke test permite entregar o código ao usuário, com limites explícitos. Não exige domínio, publicação ou provedor real. Testes com captura de e-mail não comprovam entrega externa.

## Entregas e limites

TASK-011 produz o release local; TASK-050 consolida o aceite do código e do artefato. TASK-033, TASK-034 e TASK-035 foram canceladas por retirada da operação remota do escopo, sem alegação de execução. Não há dúvida externa bloqueante neste contrato. Procedimentos efetivamente testados e pontos de configuração ficam exclusivamente no README.
