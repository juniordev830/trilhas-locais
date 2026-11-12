import 'dart:convert';
import 'dart:io';

import 'trails.dart';

/// Dados manuais locais: nunca consulta GPS, mapas ou serviços remotos.
class TrailCatalogStorage {
  static const int maxInputBytes = 1024 * 1024;

  static TrailCatalog load(File source) {
    if (source.lengthSync() > maxInputBytes) {
      throw FormatException('Catalogo excede o limite de 1 MiB');
    }
    final decoded = jsonDecode(source.readAsStringSync());
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Catalogo deve ser um objeto JSON');
    }
    final trails = decoded['trilhas'];
    final favorites = decoded['favoritas'];
    if (trails is! List || favorites is! List) {
      throw FormatException('Esperadas listas trilhas e favoritas');
    }
    if (favorites.any((item) => item is! String)) {
      throw FormatException('Favoritas precisam ser identificadores de texto');
    }
    final ids = favorites.cast<String>();
    if (ids.toSet().length != ids.length) {
      throw FormatException('Favoritas contem IDs duplicados');
    }

    return TrailCatalog(
      trails.map((item) => Trail.fromJson(item)).toList(),
      favorites: ids.toSet(),
    );
  }

  /// Formato persistido e legível de volta pelo parser do catálogo.
  static String encode(TrailCatalog catalog) {
    final favorites = catalog.favorites.toList()..sort();
    final document = <String, Object>{
      'trilhas': catalog.trails
          .map((trail) => <String, Object>{
                'id': trail.id,
                'nome': trail.name,
                'distancia_km': trail.kilometers,
                'dificuldade': trail.difficulty.name,
                'observacoes': trail.notes,
              })
          .toList(),
      'favoritas': favorites,
    };
    return const JsonEncoder.withIndent('  ').convert(document) + '\n';
  }

  /// Grava em arquivo NOVO. Jamais sobrescreve o catálogo de origem.
  static void saveNew(File destination, TrailCatalog catalog) {
    if (destination.existsSync()) {
      throw FileSystemException('Arquivo de saida ja existe', destination.path);
    }
    destination.writeAsStringSync(encode(catalog), flush: true);
  }
}
