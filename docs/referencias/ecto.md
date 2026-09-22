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
