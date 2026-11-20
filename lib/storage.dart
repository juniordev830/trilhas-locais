import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'persistent_trails.dart';

/// Dados manuais locais: nunca consulta GPS, mapas ou serviços remotos.
class TrailCatalogStorage {
  static const int maxInputBytes = 1024 * 1024;

  static TrailCatalog load(File source) {
    final input = source.openSync(mode: FileMode.read);
    late final Object? decoded;
    try {
      final bytes = BytesBuilder(copy: false);
      while (true) {
        final remaining = maxInputBytes + 1 - bytes.length;
        if (remaining <= 0) {
          throw FormatException('Catalogo excede o limite de 1 MiB');
        }
        final chunk = input.readSync(remaining > 8192 ? 8192 : remaining);
        if (chunk.isEmpty) break;
        bytes.add(chunk);
        if (bytes.length > maxInputBytes) {
          throw FormatException('Catalogo excede o limite de 1 MiB');
        }
      }
      decoded = jsonDecode(utf8.decode(bytes.takeBytes(), allowMalformed: false));
    } finally {
      input.closeSync();
    }
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
    final bytes = utf8.encode(encode(catalog));
    if (bytes.length > maxInputBytes) {
      throw FormatException('Catalogo excede o limite de 1 MiB');
    }
    destination.createSync(exclusive: true);
    try {
      destination.writeAsBytesSync(bytes, flush: true);
    } catch (_) {
      if (destination.existsSync()) destination.deleteSync();
      rethrow;
    }
  }
}
