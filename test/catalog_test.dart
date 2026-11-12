import 'package:trilhas_locais/trails.dart';

void check(bool condition, String description) {
  if (!condition) throw StateError('Teste falhou: $description');
}

void fails(void Function() action) {
  try {
    action();
  } on ArgumentError {
    return;
  } on FormatException {
    return;
  }
  throw StateError('Era esperado erro de validacao');
}

void main() {
  final catalog = TrailCatalog([
    Trail(id: 'longo', name: 'Percurso demonstrativo longo', kilometers: 7.2, difficulty: Difficulty.moderada),
    Trail(id: 'curto', name: 'Percurso demonstrativo curto', kilometers: 4.5, difficulty: Difficulty.facil),
    Trail(id: 'medio', name: 'Percurso demonstrativo medio', kilometers: 5.0, difficulty: Difficulty.facil),
  ]);

  check(catalog.find(maxKilometers: 5).length == 2, '5 km deve excluir 7.2 km');
  check(catalog.find(maxKilometers: 5).every((trail) => trail.kilometers <= 5), 'distancias validas');
  check(catalog.find(difficulty: Difficulty.facil).length == 2, 'filtro de dificuldade');
  check(catalog.find().first.id == 'curto', 'ordenar por distancia');

  final marked = catalog.withFavorite('medio', true);
  check(marked.find(favoritesOnly: true).single.id == 'medio', 'favoritos');
  check(catalog.find(favoritesOnly: true).isEmpty, 'imutabilidade');
  check(marked.withFavorite('medio', false).favorites.isEmpty, 'remover favorito');

  fails(() => catalog.withFavorite('desconhecido', true));
  fails(() => catalog.find(maxKilometers: -1));
  fails(() => TrailCatalog([catalog.trails[0], catalog.trails[0]]));
  fails(() => Trail(id: 'x', name: 'Ruim', kilometers: double.nan, difficulty: Difficulty.facil));
  fails(() => Trail.fromJson({'id': 'x', 'nome': 'x', 'distancia_km': 2, 'dificuldade': 'invalida'}));
  check(marked.report(favoritesOnly: true).contains('"favorita": true'), 'relatorio preserva favorito');
  print('PASS: distance, difficulty, favorites, ordering, validation and JSON report');
}
