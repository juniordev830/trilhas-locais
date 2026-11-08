import 'dart:convert';
import 'trails.dart';

/// Time estimates are arithmetic only: no GPS, elevation or safety assessment.
class TrailEstimate {
  final Trail trail;
  final int estimatedMinutes;
  final bool favorite;

  const TrailEstimate({
    required this.trail,
    required this.estimatedMinutes,
    required this.favorite,
  });

  Map<String, Object> toJson() => {
    ...trail.toJson(favorite: favorite),
    'tempo_estimado_min': estimatedMinutes,
  };
}

class TrailTimePlanner {
  static int estimateMinutes(double kilometers, {double speedKmH = 4}) {
    if (!kilometers.isFinite || kilometers <= 0 || kilometers > 500) {
      throw ArgumentError('Distancia precisa estar entre 0 e 500 km');
    }
    if (!speedKmH.isFinite || speedKmH < 1 || speedKmH > 12) {
      throw ArgumentError('Ritmo deve estar entre 1 e 12 km/h');
    }
    return (kilometers / speedKmH * 60).ceil();
  }

  static List<TrailEstimate> plan(
    TrailCatalog catalog, {
    required int availableMinutes,
    double speedKmH = 4,
    double? maxKilometers,
    Difficulty? difficulty,
    bool favoritesOnly = false,
  }) {
    if (availableMinutes < 1 || availableMinutes > 720) {
      throw ArgumentError('Tempo disponivel deve estar entre 1 e 720 minutos');
    }
    if (!speedKmH.isFinite || speedKmH < 1 || speedKmH > 12) {
      throw ArgumentError('Ritmo deve estar entre 1 e 12 km/h');
    }
    final estimated = catalog.find(
      maxKilometers: maxKilometers,
      difficulty: difficulty,
      favoritesOnly: favoritesOnly,
    ).map((trail) => TrailEstimate(
      trail: trail,
      estimatedMinutes: estimateMinutes(trail.kilometers, speedKmH: speedKmH),
      favorite: catalog.favorites.contains(trail.id),
    )).where((entry) => entry.estimatedMinutes <= availableMinutes).toList();

    estimated.sort((a, b) {
      final byTime = a.estimatedMinutes.compareTo(b.estimatedMinutes);
      return byTime != 0 ? byTime : a.trail.id.compareTo(b.trail.id);
    });
    return List.unmodifiable(estimated);
  }

  static String report(
    TrailCatalog catalog, {
    required int availableMinutes,
    double speedKmH = 4,
    double? maxKilometers,
    Difficulty? difficulty,
    bool favoritesOnly = false,
  }) {
    final entries = plan(
      catalog,
      availableMinutes: availableMinutes,
      speedKmH: speedKmH,
      maxKilometers: maxKilometers,
      difficulty: difficulty,
      favoritesOnly: favoritesOnly,
    );
    return const JsonEncoder.withIndent('  ')
      .convert(entries.map((entry) => entry.toJson()).toList());
  }
}
