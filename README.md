# Trilhas Locais

MVP demonstrativo em **Dart 3**, para catalogar percursos cadastrados manualmente, filtrando por distância, dificuldade e favoritos — **sem coletar geolocalização**.

## Funcionalidades

- Cadastrar percursos no catálogo JSON (ID, nome, distância, dificuldade e observações).
- Validar nomes, IDs e distâncias positivas e finitas.
- Filtrar até a distância máxima informada e por dificuldade (`facil`, `moderada`, `dificil`).
- Gerenciar favoritos no domínio Dart com estado imutável e exportar JSON de resultado.
- Ordenar resultados por distância e nome.
- Testar que filtro de até 5 km exclui percurso de 7,2 km.

## Executar

Requer SDK Dart 3.3 ou superior:

```bash
dart pub get
dart analyze
dart run test/catalog_test.dart
dart run bin/trilhas.dart examples/trilhas.json --max=5
dart run bin/trilhas.dart examples/trilhas.json --max=5 --dificuldade=facil --favoritas
```

O arquivo `examples/trilhas.json` contém **percursos fictícios** sem latitude, longitude ou instruções de navegação. Não são recomendações reais para caminhada.

## Escopo atual

É um catálogo de domínio com CLI e testes, **ainda sem Flutter, mapa ou persistência de favoritos**. Não monitora a posição do usuário. Dados reais, mapas offline, interface acessível e salvamento local são evoluções futuras.


## Planejador de tempo de caminhada

É possível combinar limite de tempo e ritmo médio estimado, além dos filtros existentes:

```bash
dart run test/pace_test.dart
dart run bin/trilhas.dart examples/trilhas.json --minutos=90 --ritmo=4
dart run bin/trilhas.dart examples/trilhas.json --minutos=90 --ritmo=5 --dificuldade=facil --favoritas
```

O planejador calcula `ceil(distância_km / ritmo_km_h × 60)` minutos. Apenas percursos que cabem no tempo informado aparecem no resultado. O ritmo deve estar entre 1 e 12 km/h e o limite entre 1 e 720 minutos. As estimativas **não consideram elevação, terreno, clima, descanso, trânsito ou segurança**. Não são rotas reais nem orientações de navegação.
