import 'dart:convert';
import 'package:trilhas_locais/trails.dart';
import 'package:trilhas_locais/pace.dart';

void check(bool condition, String explanation) {
  if (!condition) throw StateError('Teste falhou: $explanation');
}

void invalid(void Function() operation) {
  try {
    operation();
  } on ArgumentError {
    return;
  }
  throw StateError('Esperado erro de argumento');
}

TrailCatalog catalog() => TrailCatalog([
  Trail(id: 'curta', name: 'Caminhada curta', kilometers: 2, difficulty: Difficulty.facil),
  Trail(id: 'media', name: 'Caminhada media', kilometers: 5, difficulty: Difficulty.facil),
  Trail(id: 'longa', name: 'Caminhada longa', kilometers: 8, difficulty: Difficulty.moderada),
]);

void main() {
  final source = catalog();
  final suggestions = TrailTimePlanner.plan(source, availableMinutes: 90);
  check(suggestions.length == 2, '90 minutos excluem 8 km a 4 km/h');
  check(suggestions.map((e) => e.trail.id).join(',') == 'curta,media',
    'ordem por tempo estimado');
  check(suggestions.first.estimatedMinutes == 30, '2 km a 4 km/h = 30 min');
  check(suggestions.last.estimatedMinutes == 75, '5 km a 4 km/h = 75 min');

  final fast = TrailTimePlanner.plan(source, availableMinutes: 90, speedKmH: 6);
  check(fast.length == 3, '8 km a 6 km/h cabem em 90 min');
  check(fast.last.estimatedMinutes == 80, '8 km a 6 km/h = 80 min');

  final marked = source.withFavorite('media', true);
  final filtered = TrailTimePlanner.plan(
    marked, availableMinutes: 90,
    difficulty: Difficulty.facil, favoritesOnly: true,
  );
  check(filtered.length == 1 && filtered.single.trail.id == 'media',
    'respeita favorito e dificuldade');
  check(filtered.single.favorite, 'preserva atributo de favorito');
  check(source.favorites.isEmpty, 'nao modifica catalogo de origem');

  final decoded = jsonDecode(TrailTimePlanner.report(
    marked, availableMinutes: 90, maxKilometers: 3,
  ));
  check(decoded is List && decoded.length == 1, 'JSON filtra distancia');
  check(decoded[0]['tempo_estimado_min'] == 30, 'JSON inclui tempo');

  invalid(() => TrailTimePlanner.plan(source, availableMinutes: 0));
  invalid(() => TrailTimePlanner.plan(source, availableMinutes: 721));
  invalid(() => TrailTimePlanner.plan(source, availableMinutes: 90, speedKmH: 0));
  invalid(() => TrailTimePlanner.plan(source, availableMinutes: 90, speedKmH: double.nan));
  invalid(() => TrailTimePlanner.plan(source, availableMinutes: 90, maxKilometers: -1));
  invalid(() => TrailTimePlanner.estimateMinutes(-2));
  check(TrailTimePlanner.estimateMinutes(0.1, speedKmH: 4) == 2,
    'arredonda minutos para cima');
  print('PASS: time budget, speed, filters, favorites, immutable output, argument validation');
}
