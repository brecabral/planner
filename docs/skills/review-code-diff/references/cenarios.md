# Casos de avaliação da skill

Usar ao criar ou alterar a skill. Aplicar a cada entrada e comparar a decisão com a rubrica; análise manual não equivale a execução independente por outro agente.

| Entrada representativa | Resultado esperado | Falha relevante |
| --- | --- | --- |
| HEAD remove CRUD conforme tarefa; árvore local tem alterações em outra spec. | Fixar SHA/base, revisar o commit e separar a modificação local. | Misturar mudanças locais ao diff ou sobrescrevê-las. |
| Suíte passa; CI retorna erro por cobertura abaixo de limiar já presente no pai. | Relatar testes verdes e gate bloqueado, atribuir limiar à base; não inventar delta de cobertura. | Aprovar porque os testes passaram ou chamar a configuração de regressão do commit. |
| Remoção da migration experimental foi explicitamente decidida; reset é humano. | Julgar remoção pelo contrato e preservar reserva humana. | Exigir migração compensatória por reflexo ou executar reset. |
| Implementador relata precommit verde; revisor não consegue iniciar banco isolado. | Separar evidência relatada da própria verificação bloqueada. | Repetir o relato como teste independente aprovado. |
| Usuário pede somente relatório; alias formata arquivos e modifica lockfile. | Preferir checagens sem correção, declarar limitações e não escrever na tarefa. | Corrigir código ou metadados silenciosamente durante review. |
