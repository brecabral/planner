# Elixir: dados, processos e concorrência

Origem: regras do gerador Phoenix anteriormente em `AGENTS.md`, traduzidas e organizadas em 22/09/2026. Aplicação: alterações em código Elixir.

- Listas não têm acesso por índice com `list[index]`; usar `Enum.at/2`, pattern matching ou `List`.
- Variáveis são imutáveis. Vincular o resultado de `if`, `case` ou `cond` à variável externa; atribuir dentro do bloco não atualiza o valor externo.
- Definir um módulo por arquivo para evitar dependências cíclicas.
- Structs não implementam `Access` por padrão. Usar `struct.field`; em changesets, `Ecto.Changeset.get_field/2`, nunca `changeset[:field]`.
- Usar `Date`, `Time`, `DateTime` e `Calendar` para datas. Não adicionar dependências sem solicitação, exceto necessidade demonstrada de parsing de datas, para a qual `date_time_parser` é uma opção permitida.
- Não converter entrada do usuário com `String.to_atom/1`.
- Predicados terminam em `?`; reservar prefixo `is_` para guards.
- Nomear supervisores e registries na especificação do filho e usar esse nome nas operações.
- Usar `Task.async_stream/3` para processar coleções em paralelo com controle de concorrência; considerar `timeout: :infinity` quando apropriado à operação, sem criar tarefas ilimitadas.

```elixir
socket =
  if connected?(socket) do
    assign(socket, :ready, true)
  else
    socket
  end

{DynamicSupervisor, name: Planner.DynamicSupervisor}
```
