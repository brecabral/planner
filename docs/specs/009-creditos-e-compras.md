---
id: "SPEC-009"
status: draft
requirements: ["RF15"]
---

# 009 — Créditos e compra de temas (evolução futura)

## Escopo confirmado

O responsável quer adicionar créditos a usuários e futuramente usá-los para comprar temas que lhes pertençam. Em 11/10/2026 confirmou que créditos e loja ficam após o MVP de produção. A base entregue agora é catálogo/concessões e preferência na SPEC-007; não criar saldo ou endpoint sem este contrato pronto.

## Proposta para definição posterior

- Concessão de créditos deve identificar usuário, quantidade e origem; repetição da mesma concessão não duplica saldo. Autoridade para conceder precisa ser definida, sem endpoint público que aceite autoatribuição.
- Compra futura deverá debitar créditos e conceder propriedade do tema na mesma transação, sem saldo negativo ou cobrança dupla por tema já pertencente ao usuário. Seleção de tema é independente da compra.
- Temas gratuitos já concedidos permanecem disponíveis sem débito.

## Dúvidas bloqueantes

Quem concede créditos e por qual interface/processo? Qual unidade, limites, saldo inicial, expiração e política de reversão? Como registrar/auditar concessões? Quais temas terão preço e quem o define? Como tratar compra repetida, reembolso e remoção de catálogo? Haverá aquisição de créditos por pagamento real? Nenhuma resposta é presumida.

## Aceites a fechar

Antes de tornar a TASK-049 executável, definir cenários verificáveis de concessão autorizada, rejeição de autoatribuição, quantidade inválida, idempotência, concorrência e falha transacional. Decompor compra/loja em novas tarefas somente após suas próprias decisões; não misturar pagamento com a primeira concessão de créditos.

## Entrega futura

[TASK-049](../tasks/049-creditos-usuarios.md) registra a adição de créditos; bloqueada e fora dos gates do MVP de produção.
