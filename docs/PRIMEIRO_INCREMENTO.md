# Escopo técnico de primeira entrega — Trilhas Locais

**Estado da branch de desenvolvimento:** núcleo Dart, CLI e testes implementados, com catálogo JSON manual, filtros, favoritos e exportação para novo arquivo. A branch principal ainda pode conter apenas a documentação até o PR ser aprovado. Flutter e geolocalização não estão implementados.

## Modelo de percurso sugerido

`Percurso`: ID, nome, distância em km, grau de dificuldade, observações e informação de origem manual. `Favorito`: referência a percurso existente.

## Testes de aceitação para o MVP

1. Cadastrar três percursos fictícios de 2,5 km, 5,0 km e 8,2 km.
2. Filtrar por distância máxima de 5 km e retornar apenas os dois primeiros.
3. Filtrar por dificuldade sem alterar o catálogo original.
4. Adicionar e remover um favorito sem criar duplicatas.
5. Rejeitar distâncias negativas, NaN, nomes vazios e ID repetido.

## Privacidade e segurança

Não implementar coleta automática de GPS no primeiro ciclo. Evitar publicar localização privada, rotas residenciais, nomes de pessoas ou metadados de deslocamento. O projeto é um catálogo manual experimental, não guia de segurança de trilhas.

## Sequência de trabalho

Criar funções puras de modelo e filtro, testes Dart, CLI de demonstração e só depois interface Flutter. Registrar comandos reais de execução no README quando surgirem.

## Entregas do MVP na branch

- `lib/trails.dart`: modelo, validações, filtros, estado imutável e favoritos.
- `lib/pace.dart`: cálculo **estimado** de tempo de caminhada, sem considerar terreno.
- `lib/storage.dart`: leitura validada de JSON e exportação para arquivo novo, sem sobrescrever o anterior.
- `bin/trilhas.dart`: CLI para consultar, favoritar/desfavoritar e exportar catálogo local.
- `test/*.dart`: validação por filtros, casos de erro, arquivos existentes e persistência.
- `.github/workflows/ci.yml`: análise estática e testes Dart em PRs.

A interface Flutter, dados geográficos reais, navegação e serviços externos **não estão incluídos**. Os exemplos são fictícios.
