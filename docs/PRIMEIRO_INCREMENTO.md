# Escopo técnico de primeira entrega — Trilhas Locais

**Estado confirmado:** repositório conceitual com `README.md`; sem Flutter/Dart implementados.

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
