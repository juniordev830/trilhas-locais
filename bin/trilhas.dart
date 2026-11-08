import 'dart:convert';
import 'dart:io';
import 'package:trilhas_locais/trails.dart';

void main(List<String> args) {
  try {
    if (args.isEmpty || args.length > 4) {
      throw FormatException(
        'Uso: dart run bin/trilhas.dart examples/trilhas.json [--max=5] [--dificuldade=facil] [--favoritas]'
      );
    }
    final decoded = jsonDecode(File(args.first).readAsStringSync());
    if (decoded is! Map<String, dynamic> ||
        decoded['trilhas'] is! List ||
        decoded['favoritas'] is! List) {
      throw FormatException('Esperados campos trilhas e favoritas em listas');
    }
    final rawTrails = decoded['trilhas'] as List;
    final rawFavorites = decoded['favoritas'] as List;
    if (rawFavorites.any((item) => item is! String)) {
      throw FormatException('Favoritas precisam ser IDs de trilha');
    }
    final catalog = TrailCatalog(
      rawTrails.map((input) => Trail.fromJson(input)).toList(),
      favorites: rawFavorites.cast<String>().toSet(),
    );
    double? maxKm;
    Difficulty? difficulty;
    bool onlyFavorites = false;
    for (final arg in args.skip(1)) {
      if (arg.startsWith('--max=')) {
        maxKm = double.parse(arg.substring('--max='.length));
      } else if (arg.startsWith('--dificuldade=')) {
        final name = arg.substring('--dificuldade='.length);
        final options = Difficulty.values.where((value) => value.name == name);
        if (options.isEmpty) throw FormatException('Dificuldade invalida');
        difficulty = options.single;
      } else if (arg == '--favoritas') {
        onlyFavorites = true;
      } else {
        throw FormatException('Parametro desconhecido: $arg');
      }
    }
    stdout.writeln(catalog.report(
      maxKilometers: maxKm,
      difficulty: difficulty,
      favoritesOnly: onlyFavorites,
    ));
  } on FormatException catch (error) {
    stderr.writeln('Erro: $error');
    exitCode = 2;
  } on ArgumentError catch (error) {
    stderr.writeln('Erro: $error');
    exitCode = 2;
  } on FileSystemException catch (error) {
    stderr.writeln('Erro: $error');
    exitCode = 2;
  }
}
