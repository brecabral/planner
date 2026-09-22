# Mix e dependências

Origem: regras do gerador Phoenix anteriormente em `AGENTS.md`, traduzidas em 22/09/2026. Aplicação: uso ou alteração de tarefas Mix.

- Ler `mix help nome_da_tarefa` antes de usar uma tarefa ou suas opções.
- Finalizar mudanças com `mix precommit` e corrigir falhas relacionadas ao trabalho.
- Executar verificações pelo Mix; comandos de uso e configuração têm fonte única no [README da raiz](../../README.md).
- Para depurar, usar testes do arquivo relevante ou `mix test --failed` para falhas anteriores.
- Não usar `mix deps.clean --all` sem uma justificativa concreta.
- Não adicionar dependências para algo coberto pela biblioteca padrão ou pelas dependências existentes. HTTP usa `Req`.
- O alias atual formata arquivos; não confundir essa correção com uma verificação de CI que detecta formatação divergente.
