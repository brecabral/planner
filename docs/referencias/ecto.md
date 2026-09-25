# Ecto: schemas, consultas e migrations

Origem: regras do gerador Phoenix anteriormente em `AGENTS.md`, traduzidas em 22/09/2026. Aplicação: persistência e validações.

- Fazer preload das associações acessadas nas telas.
- Importar `Ecto.Query` e outros módulos necessários nos seeds.
- Campos textuais de `Ecto.Schema` usam `:string`, mesmo quando a coluna no banco é `:text`.
- `validate_number/3` não aceita `allow_nil`; a validação já considera somente alterações com valor não nulo.
- Ler campos de changesets com `Ecto.Changeset.get_field/2`.
- Campos controlados pelo servidor, como `user_id`, não entram em `cast`; devem ser atribuídos programaticamente.
- Gerar migrations com `mix ecto.gen.migration nome_em_snake_case`, preservando timestamp e convenções.
- Não inferir o modelo final a partir do CRUD experimental. Consultar a spec pertinente antes de definir dados e invariantes.

```elixir
%Entry{user_id: current_user.id}
|> Ecto.Changeset.cast(attrs, [:title])
```

O exemplo ilustra a atribuição segura; não introduz uma entidade no Planner. Estratégia de remoção do experimento: [tarefa 002](../tasks/002-remover-crud-experimental.md).

## TDD e migrations

Escrever os testes de intenção primeiro, mas completar a migration nova antes da primeira execução que possa aplicá-la, inclusive por preparação automática do banco de testes. O scaffold gerado é um ponto de partida: conferir campos, tipos, defaults, nulabilidade, índices, unicidade, chaves estrangeiras e checks exigidos pelo contrato antes de aplicá-lo.

A fase vermelha deve demonstrar comportamento ausente, não depender de uma estrutura de banco deliberadamente incompleta. Preparar a migration completa antes dessa execução é parte do setup; manter o ciclo de falha e implementação para os comportamentos ainda ausentes. Testes de invariantes já satisfeitas pela migration podem passar na primeira execução; registrar essa evidência sem remover constraints para fabricar uma falha.

Aplicar o scaffold incompleto e depois editar sua migration já aplicada exige desfazer e reaplicar a estrutura para testar a versão final. Evitar essa sequência como rotina de TDD. Rollback de migration não se confunde com rollback de transação: testes de atomicidade continuam devendo provocar falhas e verificar que gravações parciais são revertidas. Quando uma correção real exigir rever uma migration já aplicada, avaliar o ambiente e o estado de integração antes de escolher a correção e registrar a justificativa; esta orientação não autoriza reverter migrations de bases compartilhadas.
