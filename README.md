# Trilhas Locais

Catálogo local de percursos em Dart, com filtros, favoritos e exportação JSON. O núcleo e a demonstração no terminal estão implementados. A interface Flutter continua planejada.

## Recursos implementados

- Cadastro manual de trilhas com identificador, nome, distância, dificuldade e observações.
- Filtros por distância máxima e dificuldade: `facil`, `moderada` ou `dificil`.
- Ordenação por distância e identificador para desempate.
- Marcação e remoção de favoritos pela biblioteca.
- Exportação e restauração de catálogo JSON com favoritos.
- Rejeição de identificadores duplicados, distâncias inválidas e backups incompatíveis.

## Executar

Com o SDK Dart instalado, execute na raiz:

```bash
dart run bin/main.dart
dart run bin/main.dart 5 facil
dart run bin/main.dart --self-test
```

A demonstração cadastra dois percursos fictícios: um fácil de 2,8 km e outro moderado de 6,4 km. O filtro `5 facil` retorna somente o primeiro. A saída é um array JSON.

Os testes existentes verificam o filtro de 5 km, favoritos, restauração do backup e rejeição de IDs duplicados.

## Biblioteca

O código de domínio está em `lib/trails.dart`:

```dart
import 'lib/trails.dart';

void main() {
  final catalog = TrailCatalog();
  catalog.add(Trail('exemplo', 'Percurso fictício', 3.5, 'facil'));
  catalog.favorite('exemplo');
  final backup = catalog.exportJson();
  final restored = TrailCatalog.fromJson(backup);
  print(restored.favorites().single.name);
}
```

## Limites

Os dados ficam em memória. A exportação devolve texto JSON; não grava arquivos automaticamente. A demonstração reinicia o catálogo a cada execução e não oferece edição persistente. Não há interface Flutter, GPS, mapas ou coleta automática de localização.

Os percursos de exemplo são inventados e não devem ser usados para navegação. O catálogo valida distâncias maiores que zero e de até 1.000 km. Esses limites técnicos não avaliam a segurança de um percurso.

O [roteiro do primeiro incremento](docs/PRIMEIRO_INCREMENTO.md) preserva os requisitos de planejamento. A lista acima descreve o que já está implementado.
