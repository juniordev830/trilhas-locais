# Trilhas Locais

> Status: concepção. Este repositório contém apenas o escopo inicial; ainda não há aplicação executável ou funcionalidades implementadas.

## Ideia

Catalogar percursos de caminhada com distância, dificuldade e observações.

## Primeira versão planejada

- [ ] Cadastrar percurso manualmente.
- [ ] Filtrar por distância e dificuldade.
- [ ] Salvar lista de percursos favoritos.

## Modelo inicial

Percurso e favorito.

## Regras e limites

Não coletar localização automaticamente; dados iniciais serão demonstrativos.

Escopo mantido pequeno: sem pagamentos, integrações externas, infraestrutura de produção ou uso de dados pessoais reais nesta etapa.

## Tecnologia proposta

Dart + Flutter.

A escolha é uma proposta para a futura implementação; nenhuma dependência foi instalada e a tecnologia ainda não foi implementada.

## Critério de conclusão do primeiro incremento

Um filtro de até 5 km deve excluir percursos acima dessa distância.

## Próximos passos

1. Revisar este escopo antes de começar a implementação.
2. Preparar o ambiente mínimo da tecnologia escolhida.
3. Implementar um fluxo completo e validar o critério acima.
4. Documentar a execução e acrescentar exemplos demonstrativos.

## Possíveis evoluções

Depois de validar o fluxo principal, avaliar persistência, acessibilidade e uma interface mais completa conforme a plataforma. Evoluções não fazem parte da entrega atual.

## Como executar

Ainda não há comandos de execução. Eles serão adicionados quando existir uma primeira versão funcional.

## Documentação técnica

Confira o [roteiro de validação e próximos incrementos](docs/PRIMEIRO_INCREMENTO.md) para revisar a implementação e os critérios de qualidade antes de mudanças futuras.

## Primeiro incremento executável (em revisão)

O catálogo em Dart permite cadastrar trilhas fictícias, filtrar por distância e dificuldade, marcar favoritos e exportar/importar um backup JSON. Não utiliza GPS nem dados de localização. **Não há ainda interface Flutter**.

```bash
dart run bin/main.dart
dart run bin/main.dart 5 facil
dart run bin/main.dart --self-test
```

As trilhas de exemplo são inventadas e não representam rotas reais. Testes e análise estática são executados pelo GitHub Actions do PR.
