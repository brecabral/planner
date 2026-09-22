# Testes de intenção e Phoenix

Origem: regras do gerador Phoenix anteriormente em `AGENTS.md` e política de TDD do projeto, traduzidas em 22/09/2026. Aplicação: alterações com comportamento verificável.

- Antes de implementar comportamento, escrever teste enxuto que expresse o resultado esperado; evitar reproduzir detalhes internos sem valor de regressão.
- Cobrir cenários relevantes em casos pequenos; regras no contexto e integração na camada web.
- Iniciar processos de teste com `start_supervised!/1` para garantir limpeza.
- Não sincronizar testes com `Process.sleep/1` nem `Process.alive?/1`. Para término, usar monitor e mensagem `DOWN`; para garantir processamento anterior, `_ = :sys.get_state(pid)`.

```elixir
ref = Process.monitor(pid)
assert_receive {:DOWN, ^ref, :process, ^pid, :normal}
```

- LiveView usa `Phoenix.LiveViewTest` e `LazyHTML`. Submeter formulários com `render_submit/2` e alterar campos com `render_change/2`.
- Usar IDs estáveis da interface em `element/2`, `has_element?/2` e demais seletores; não comparar HTML bruto.
- Preferir presença e comportamento dos elementos a textos sujeitos a revisão, exceto quando o texto traduzido for o próprio contrato testado.
- Testar o HTML efetivamente produzido pelos componentes. Para diagnosticar seletores, usar `LazyHTML.from_fragment/1` e `LazyHTML.filter/2` para inspecionar somente o trecho necessário.
- Não considerar testes verdes prova suficiente de aderência ao produto: conferir também os exemplos e invariantes da spec.

Execução dos testes: [README](../../README.md). Regras específicas de formulários: [formulários](formularios.md).
