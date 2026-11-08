import 'dart:convert';

enum Difficulty { facil, moderada, dificil }

class Trail {
  final String id;
  final String name;
  final double kilometers;
  final Difficulty difficulty;
  final String notes;

  Trail({
    required this.id,
    required this.name,
    required this.kilometers,
    required this.difficulty,
    this.notes = '',
  }) {
    if (!RegExp(r'^[a-z0-9-]{1,60}$').hasMatch(id)) {
      throw ArgumentError('ID da trilha invalido');
    }
    if (name.trim().isEmpty || name.length > 120) {
      throw ArgumentError('Nome invalido');
    }
    if (!kilometers.isFinite || kilometers <= 0 || kilometers > 500) {
      throw ArgumentError('Distancia precisa ser positiva, ate 500 km');
    }
    if (notes.length > 1000) throw ArgumentError('Observacoes muito extensas');
  }

  factory Trail.fromJson(Object? input) {
    if (input is! Map<String, dynamic>) {
      throw FormatException('Trilha deve ser um objeto JSON');
    }
    final id = input['id'];
    final name = input['nome'];
    final km = input['distancia_km'];
    final difficulty = input['dificuldade'];
    final notes = input['observacoes'] ?? '';
    if (id is! String || name is! String || km is! num ||
        difficulty is! String || notes is! String) {
      throw FormatException('Campos de trilha invalidos');
    }
    final level = Difficulty.values.where((e) => e.name == difficulty).toList();
    if (level.isEmpty) throw FormatException('Dificuldade invalida');
    return Trail(
      id: id, name: name, kilometers: km.toDouble(),
      difficulty: level.single, notes: notes,
    );
  }

  Map<String, Object> toJson({bool favorite = false}) => {
    'id': id,
    'nome': name,
    'distancia_km': kilometers,
    'dificuldade': difficulty.name,
    'observacoes': notes,
    'favorita': favorite,
  };
}

class TrailCatalog {
  final List<Trail> trails;
  final Set<String> favorites;

  TrailCatalog(List<Trail> source, {Set<String>? favorites})
      : trails = List.unmodifiable(source),
        favorites = Set.unmodifiable(favorites ?? <String>{}) {
    if (trails.map((trail) => trail.id).toSet().length != trails.length) {
      throw ArgumentError('ID de trilha duplicado');
    }
    if (!this.favorites.every((id) => trails.any((trail) => trail.id == id))) {
      throw ArgumentError('Favorita referencia trilha inexistente');
    }
  }

  TrailCatalog withFavorite(String id, bool selected) {
    if (!trails.any((trail) => trail.id == id)) {
      throw ArgumentError('Trilha nao encontrada: $id');
    }
    final updated = Set<String>.from(favorites);
    if (selected) {
      updated.add(id);
    } else {
      updated.remove(id);
    }
    return TrailCatalog(trails, favorites: updated);
  }

  List<Trail> find({
    double? maxKilometers,
    Difficulty? difficulty,
    bool favoritesOnly = false,
  }) {
    if (maxKilometers != null &&
        (!maxKilometers.isFinite || maxKilometers <= 0)) {
      throw ArgumentError('Distancia maxima invalida');
    }
    final filtered = trails.where((trail) =>
      (maxKilometers == null || trail.kilometers <= maxKilometers) &&
      (difficulty == null || trail.difficulty == difficulty) &&
      (!favoritesOnly || favorites.contains(trail.id))
    ).toList();
    filtered.sort((a, b) {
      final distance = a.kilometers.compareTo(b.kilometers);
      return distance == 0 ? a.name.compareTo(b.name) : distance;
    });
    return List.unmodifiable(filtered);
  }

  String report({
    double? maxKilometers,
    Difficulty? difficulty,
    bool favoritesOnly = false,
  }) {
    final results = find(
      maxKilometers: maxKilometers,
      difficulty: difficulty,
      favoritesOnly: favoritesOnly,
    );
    return const JsonEncoder.withIndent('  ').convert(
      results.map((trail) =>
        trail.toJson(favorite: favorites.contains(trail.id))).toList()
    );
  }
}
