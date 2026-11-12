# Trilhas Locais

MVP demonstrativo em **Dart 3**, para catalogar percursos cadastrados manualmente, filtrando por distância, dificuldade e favoritos — **sem coletar geolocalização**.

## Funcionalidades

- Cadastrar percursos no catálogo JSON (ID, nome, distância, dificuldade e observações).
- Validar nomes, IDs e distâncias positivas e finitas.
- Filtrar até a distância máxima informada e por dificuldade (`facil`, `moderada`, `dificil`).
- Gerenciar favoritos com estado imutável e exportar um catálogo JSON atualizado para **novo arquivo**, sem sobrescrever o original.
- Ordenar resultados por distância e nome.
- Testar que filtro de até 5 km exclui percurso de 7,2 km.

## Executar

Requer SDK Dart 3.3 ou superior:

```bash
dart pub get
dart analyze
dart run test/catalog_test.dart
dart run test/pace_test.dart
dart run test/storage_test.dart
dart run bin/trilhas.dart examples/trilhas.json --max=5
dart run bin/trilhas.dart examples/trilhas.json --max=5 --dificuldade=facil --favoritas
```

O arquivo `examples/trilhas.json` contém **percursos fictícios** sem latitude, longitude ou instruções de navegação. Não são recomendações reais para caminhada.

## Escopo atual

É um catálogo de domínio com CLI e testes, **com persistência local de favoritos por exportação de JSON**. Ainda não há Flutter, mapa ou sincronização automática. Não monitora a posição do usuário. Rotas reais, mapas offline e interface móvel acessível são evoluções futuras.


## Planejador de tempo de caminhada

É possível combinar limite de tempo e ritmo médio estimado, além dos filtros existentes:

```bash
dart run test/pace_test.dart
dart run bin/trilhas.dart examples/trilhas.json --minutos=90 --ritmo=4
dart run bin/trilhas.dart examples/trilhas.json --minutos=90 --ritmo=5 --dificuldade=facil --favoritas
```

O planejador calcula `ceil(distância_km / ritmo_km_h × 60)` minutos. Apenas percursos que cabem no tempo informado aparecem no resultado. O ritmo deve estar entre 1 e 12 km/h e o limite entre 1 e 720 minutos. As estimativas **não consideram elevação, terreno, clima, descanso, trânsito ou segurança**. Não são rotas reais nem orientações de navegação.

## Salvar favoritos localmente

O comando de consulta não altera arquivos. Para incluir ou retirar um favorito, informe **um novo caminho de saída**. Isso preserva o arquivo original e permite usar o exportado em consultas futuras.

```bash
dart run bin/trilhas.dart examples/trilhas.json --favoritar=trilha-demo --salvar=trilhas-atualizadas.json
dart run bin/trilhas.dart trilhas-atualizadas.json --favoritas
dart run bin/trilhas.dart trilhas-atualizadas.json --desfavoritar=parque-demo --salvar=trilhas-revisadas.json
```

O programa recusa sobrescrever arquivos existentes, inclusive o próprio catálogo de entrada. Também rejeita IDs de favoritos inexistentes, IDs repetidos no JSON, campos inválidos e arquivos de entrada acima de **1 MiB**. Não use catálogos pessoais como exemplos versionados no Git.

A implementação da persistência e os testes estão em `lib/storage.dart` e `test/storage_test.dart`. Os testes do projeto podem ser executados com:

```bash
dart analyze --fatal-infos
dart run test/catalog_test.dart
dart run test/pace_test.dart
dart run test/storage_test.dart
```
