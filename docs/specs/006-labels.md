---
id: "SPEC-006"
status: ready
requirements: ["RF10", "CA15"]
---

# 006 — Labels reutilizáveis por usuário

## Escopo e origem

Catálogo de labels do usuário padrão e várias labels opcionais por tarefa, confirmados pelo responsável em 23/09/2026. Labels são classificação livre; não criam projetos ou hierarquias.

## Arquitetura e casos de uso

`Planner.Labels` fornece catálogo do usuário padrão e criação componível; `Planner.Tasks` possui a relação muitos-para-muitos e coordena o cadastro com labels existentes/novas. A tabela de vínculo garante unicidade e compatibilidade de proprietário com tarefa e label. Não usar lista de textos soltos como identidade da associação.

O catálogo é gerado como contexto/schema; o vínculo é gerado como schema sem CRUD público. Uma transação engloba tarefa, novas labels e vínculos, permitindo reuso, múltipla seleção e rollback. Consultas do painel/histórico carregam as associações autorizadas sem reclassificar a tarefa nem traduzir os nomes.

## Regras

- RN01: label tem identidade, proprietário e nome textual não vazio após remover espaços nas extremidades. Listar apenas labels do usuário padrão resolvido no servidor; associar pelo ID, não pelo texto.
- RN02: no cadastro de tarefa, selecionar zero ou várias labels existentes e/ou criar novas. Cada vínculo tarefa/label é único; repetir um ID na entrada não duplica o vínculo. Não impor limite de uma label.
- RN03: todas as labels associadas pertencem ao mesmo usuário da tarefa. ID inexistente ou alheio rejeita o cadastro inteiro, sem criar tarefa, label ou vínculo parcial.
- RN04: criar novas labels e a tarefa no mesmo formulário é uma operação atômica. Falha no título, nome ou persistência não deixa novas labels órfãs dessa tentativa; labels preexistentes são preservadas.
- RN05: selecionar, devolver, levar a retry ou concluir preserva as labels da tarefa. Renomear, excluir e mesclar labels não integra esta entrega. Nomes iguais não autorizam fusão automática de identidades; o usuário reaproveita selecionando a label existente.

## Cenários de aceite

- CA-006-01: cadastrar sem labels é válido; cadastrar com duas labels próprias persiste exatamente dois vínculos.
- CA-006-02: escolher uma existente e criar duas novas persiste tarefa e três vínculos; novas labels ficam disponíveis em outro cadastro do mesmo usuário.
- CA-006-03: nome vazio de nova label, título inválido ou falha de gravação reverte o cadastro inteiro, mantendo labels preexistentes.
- CA-006-04: o cadastro informa label de proprietário incompatível ou inexistente; operação falha sem revelar o catálogo de B ou criar registros parciais.
- CA-006-05: IDs repetidos não duplicam vínculos; movimentação até retry e conclusão mantém os mesmos IDs de labels.

## Implementação

Catálogo, relação, cadastro atômico e formulário são etapas distintas no [mapa de entregas](../tasks/README.md), sem dividir este contrato de classificação em specs por operação.
