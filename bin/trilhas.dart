import 'dart:convert';
import 'dart:io';
import 'package:trilhas_locais/trails.dart';
import 'package:trilhas_locais/pace.dart';

void main(List<String> args) {
  try {
    if (args.isEmpty || args.length > 6) {
      throw FormatException(
        'Uso: dart run bin/trilhas.dart examples/trilhas.json '
        '[--max=5] [--dificuldade=facil] [--favoritas] [--minutos=90] [--ritmo=4]'
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
    int? availableMinutes;
    double? speedKmH;
    final seen = <String>{};

    for (final arg in args.skip(1)) {
      final option = arg.split('=').first;
      if (!seen.add(option)) throw FormatException('Opcao duplicada: $option');
      if (arg.startsWith('--max=')) {
        maxKm = double.parse(arg.substring('--max='.length));
      } else if (arg.startsWith('--dificuldade=')) {
        final name = arg.substring('--dificuldade='.length);
        final options = Difficulty.values.where((value) => value.name == name);
        if (options.isEmpty) throw FormatException('Dificuldade invalida');
        difficulty = options.single;
      } else if (arg == '--favoritas') {
        onlyFavorites = true;
      } else if (arg.startsWith('--minutos=')) {
        availableMinutes = int.parse(arg.substring('--minutos='.length));
      } else if (arg.startsWith('--ritmo=')) {
        speedKmH = double.parse(arg.substring('--ritmo='.length));
      } else {
        throw FormatException('Parametro desconhecido: $arg');
      }
    }

    if (speedKmH != null && availableMinutes == null) {
      throw FormatException('--ritmo exige --minutos');
    }
    final output = availableMinutes == null
      ? catalog.report(
          maxKilometers: maxKm,
          difficulty: difficulty,
          favoritesOnly: onlyFavorites,
        )
      : TrailTimePlanner.report(
          catalog,
          availableMinutes: availableMinutes,
          speedKmH: speedKmH ?? 4,
          maxKilometers: maxKm,
          difficulty: difficulty,
          favoritesOnly: onlyFavorites,
        );
    stdout.writeln(output);
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
