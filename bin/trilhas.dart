import 'dart:io';

import 'package:trilhas_locais/pace.dart';
import 'package:trilhas_locais/storage.dart';
import 'package:trilhas_locais/trails.dart';

void main(List<String> args) {
  try {
    if (args.isEmpty) {
      throw FormatException(
        'Uso: dart run bin/trilhas.dart catalogo.json '
        '[--max=5] [--dificuldade=facil] [--favoritas] '
        '[--minutos=90] [--ritmo=4] '
        '[--favoritar=id | --desfavoritar=id] [--salvar=novo.json]'
      );
    }

    double? maxKm;
    Difficulty? difficulty;
    bool onlyFavorites = false;
    int? availableMinutes;
    double? speedKmH;
    String? favoriteToAdd;
    String? favoriteToRemove;
    String? destination;
    final seen = <String>{};

    for (final arg in args.skip(1)) {
      final option = arg.split('=').first;
      if (!seen.add(option)) {
        throw FormatException('Opcao duplicada: $option');
      }
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
      } else if (arg.startsWith('--favoritar=')) {
        favoriteToAdd = arg.substring('--favoritar='.length);
      } else if (arg.startsWith('--desfavoritar=')) {
        favoriteToRemove = arg.substring('--desfavoritar='.length);
      } else if (arg.startsWith('--salvar=')) {
        destination = arg.substring('--salvar='.length);
        if (destination.isEmpty) {
          throw FormatException('Informe um arquivo de saida');
        }
      } else {
        throw FormatException('Parametro desconhecido: $arg');
      }
    }

    if (speedKmH != null && availableMinutes == null) {
      throw FormatException('--ritmo exige --minutos');
    }
    if (favoriteToAdd != null && favoriteToRemove != null) {
      throw FormatException('Escolha somente uma alteracao de favorito');
    }
    final changingFavorite = favoriteToAdd != null || favoriteToRemove != null;
    if (changingFavorite != (destination != null)) {
      throw FormatException('Alterar favorito exige --salvar=novo.json, e vice-versa');
    }

    final source = File(args.first);
    var catalog = TrailCatalogStorage.load(source);
    if (favoriteToAdd != null) {
      catalog = catalog.withFavorite(favoriteToAdd, true);
    } else if (favoriteToRemove != null) {
      catalog = catalog.withFavorite(favoriteToRemove, false);
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

    if (destination != null) {
      final file = File(destination);
      if (file.absolute.path == source.absolute.path) {
        throw FormatException('Use arquivo de saida diferente do catalogo original');
      }
      TrailCatalogStorage.saveNew(file, catalog);
      stderr.writeln('Catalogo salvo: ${file.path}');
    }
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
