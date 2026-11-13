import 'dart:convert';

/// Curated trail data only: no GPS, tracking or automatic location access.
class Trail {
  final String id;
  final String name;
  final double distanceKm;
  final String difficulty;
  final String notes;

  Trail(this.id, this.name, this.distanceKm, this.difficulty, {this.notes = ''}) {
    if (!RegExp(r'^[A-Za-z0-9_-]{1,64}$').hasMatch(id) ||
        name.trim().isEmpty || name.length > 120 ||
        !distanceKm.isFinite || distanceKm <= 0 || distanceKm > 1000 ||
        !const {'facil', 'moderada', 'dificil'}.contains(difficulty) ||
        notes.length > 500) {
      throw const FormatException('Dados da trilha inválidos');
    }
  }

  Map<String, Object> toJson() => {
    'id': id, 'nome': name, 'distancia_km': distanceKm,
    'dificuldade': difficulty, 'observacoes': notes
  };
}

class TrailCatalog {
  final Map<String, Trail> _trails = {};
  final Set<String> _favorites = {};

  void add(Trail trail) {
    if (_trails.containsKey(trail.id)) {
      throw const FormatException('ID de trilha duplicado');
    }
    _trails[trail.id] = trail;
  }

  List<Trail> filter({double? maxKm, String? difficulty}) {
    if (maxKm != null && (!maxKm.isFinite || maxKm <= 0)) {
      throw const FormatException('Distância máxima inválida');
    }
    if (difficulty != null &&
        !const {'facil', 'moderada', 'dificil'}.contains(difficulty)) {
      throw const FormatException('Dificuldade inválida');
    }
    final result = _trails.values.where((trail) =>
      (maxKm == null || trail.distanceKm <= maxKm) &&
      (difficulty == null || trail.difficulty == difficulty)
    ).toList();
    result.sort((a, b) {
      final distance = a.distanceKm.compareTo(b.distanceKm);
      return distance == 0 ? a.id.compareTo(b.id) : distance;
    });
    return result;
  }

  void favorite(String id, {bool value = true}) {
    if (!_trails.containsKey(id)) throw const FormatException('Trilha inexistente');
    if (value) {
      _favorites.add(id);
    } else {
      _favorites.remove(id);
    }
  }

  List<Trail> favorites() =>
    filter().where((trail) => _favorites.contains(trail.id)).toList();

  String exportJson() => const JsonEncoder.withIndent('  ').convert({
    'schema_version': 1,
    'trilhas': filter().map((t) => t.toJson()).toList(),
    'favoritos': (_favorites.toList()..sort()),
  });

  factory TrailCatalog.fromJson(String input) {
    final data = jsonDecode(input);
    if (data is! Map || data['schema_version'] != 1 ||
        data['trilhas'] is! List || data['favoritos'] is! List) {
      throw const FormatException('Catálogo inválido');
    }
    final catalog = TrailCatalog();
    if ((data['trilhas'] as List).length > 10000) {
      throw const FormatException('Catálogo muito grande');
    }
    for (final item in data['trilhas']) {
      if (item is! Map || item['id'] is! String ||
          item['nome'] is! String || item['distancia_km'] is! num ||
          item['dificuldade'] is! String || item['observacoes'] is! String) {
        throw const FormatException('Registro de trilha inválido');
      }
      catalog.add(Trail(item['id'], item['nome'],
        (item['distancia_km'] as num).toDouble(), item['dificuldade'],
        notes: item['observacoes']));
    }
    final favorites = data['favoritos'] as List;
    if (favorites.any((id) => id is! String) || favorites.toSet().length != favorites.length) {
      throw const FormatException('Favoritos inválidos');
    }
    for (final id in favorites) {
      catalog.favorite(id as String);
    }
    return catalog;
  }
}
