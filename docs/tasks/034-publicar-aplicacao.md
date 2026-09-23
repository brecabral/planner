---
id: "TASK-034"
status: "planned"
execution_level: "standard"
execution_rationale: "Publica uma release preparada em destino autorizado e verifica acesso e persistência."
specs: []
depends_on: ["TASK-033"]
provides: ["remote-runtime-delivery"]
consumes: ["production-runtime"]
write_scope: ["README.md", "docs/tasks/034-publicar-aplicacao.md"]
blockers: ["Definir destino, domínio, credenciais de acesso e autorização de publicação."]
---

# 034 — Publicar a release no ambiente definido

## Entrada e limite

PRD RF11/CA16; consumir production-runtime. Entrega operacional sem nova regra de produto.

## Execução

Usar release preparada no destino autorizado com banco persistente, HTTPS e migrations sem reset. Registrar URL, configuração não sensível e procedimento no README. Não contratar serviço pago por inferência.

## Aceite

1. Duas contas entram remotamente e veem só seus dados; refresh/logout funcionam.
2. Reiniciar o processo mantém dados e cota; registrar resultado e URL sem credenciais.

Registrar os resultados dos cenários executados. Finalizar alterações locais com `mix precommit`; testes de aplicação não substituem a evidência operacional desta tarefa.

## Evidência e revisão

Pendentes. Registrar versão/ambiente verificados, resultados e limitações, precommit para alterações locais, revisor independente, achados e integração.
