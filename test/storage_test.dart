import 'dart:convert';
import 'dart:io';

import 'package:trilhas_locais/storage.dart';
import 'package:trilhas_locais/trails.dart';

void check(bool condition, String message) {
  if (!condition) throw StateError('Teste falhou: $message');
}

void rejects(void Function() operation) {
  try {
    operation();
  } on FormatException {
    return;
  } on ArgumentError {
    return;
  } on FileSystemException {
    return;
  }
  throw StateError('Era esperado um erro de validacao');
}

void main() {
  final directory = Directory.systemTemp.createTempSync('trilhas-test-');
  try {
    final source = File('${directory.path}/entrada.json');
    source.writeAsStringSync(jsonEncode({
      'trilhas': [
        {
          'id': 'curta', 'nome': 'Percurso curto',
          'distancia_km': 2.5, 'dificuldade': 'facil',
          'observacoes': 'Ficticio',
        },
        {
          'id': 'media', 'nome': 'Percurso medio',
          'distancia_km': 5.0, 'dificuldade': 'facil',
          'observacoes': '',
        },
        {
          'id': 'longa', 'nome': 'Percurso longo',
          'distancia_km': 8.2, 'dificuldade': 'moderada',
          'observacoes': '',
        },
      ],
      'favoritas': ['curta'],
    }));

    final original = source.readAsStringSync();
    final catalog = TrailCatalogStorage.load(source);
    check(catalog.find(maxKilometers: 5).length == 2,
        '5 km excluem percurso de 8.2 km');
    check(catalog.find(difficulty: Difficulty.facil).length == 2,
        'filtro de dificuldade');
    check(catalog.find(favoritesOnly: true).single.id == 'curta',
        'favorita importada');

    final updated = catalog.withFavorite('media', true);
    final output = File('${directory.path}/exportado.json');
    TrailCatalogStorage.saveNew(output, updated);
    check(source.readAsStringSync() == original,
        'exportacao nao modifica catalogo original');
    final reloaded = TrailCatalogStorage.load(output);
    check(reloaded.favorites.containsAll(['curta', 'media']),
        'favoritos salvos e carregados novamente');
    check(reloaded.favorites.length == 2,
        'sem entradas duplicadas na exportacao');
    check(reloaded.find(maxKilometers: 5).length == 2,
        'filtros preservados apos exportacao');
    check(jsonDecode(output.readAsStringSync())['favoritas'].join(',') ==
        'curta,media', 'ordem estavel dos favoritos');
    rejects(() => TrailCatalogStorage.saveNew(output, catalog));
    check(TrailCatalogStorage.load(output).favorites.length == 2,
        'saida existente preservada');

    final invalid = File('${directory.path}/invalido.json');
    invalid.writeAsStringSync('{"trilhas":[],"favoritas":["x","x"]}');
    rejects(() => TrailCatalogStorage.load(invalid));
    invalid.writeAsStringSync('{"trilhas":[],"favoritas":["x"]}');
    rejects(() => TrailCatalogStorage.load(invalid));
    invalid.writeAsStringSync('{"trilhas":[],"favoritas":{}}');
    rejects(() => TrailCatalogStorage.load(invalid));
    invalid.writeAsStringSync('{"trilhas":[]}');
    rejects(() => TrailCatalogStorage.load(invalid));
    invalid.writeAsStringSync('[1,2]');
    rejects(() => TrailCatalogStorage.load(invalid));
    invalid.writeAsStringSync('invalido');
    rejects(() => TrailCatalogStorage.load(invalid));
    invalid.writeAsStringSync(' ' * (TrailCatalogStorage.maxInputBytes + 1));
    rejects(() => TrailCatalogStorage.load(invalid));

    final cliSaved = File('${directory.path}/via-cli.json');
    final result = Process.runSync(
      Platform.resolvedExecutable,
      ['run', 'bin/trilhas.dart', source.path,
       '--favoritar=media', '--salvar=${cliSaved.path}', '--favoritas'],
    );
    check(result.exitCode == 0, 'CLI salva favorito: ${result.stderr}');
    check(TrailCatalogStorage.load(cliSaved).favorites.contains('media'),
        'CLI persistiu o favorito');
    check(jsonDecode(result.stdout as String).length == 2,
        'filtro por favoritas considera alteracao');
    check(source.readAsStringSync() == original,
        'CLI preserva entrada de origem');

    final duplicate = Process.runSync(
      Platform.resolvedExecutable,
      ['run', 'bin/trilhas.dart', source.path,
       '--favoritar=media', '--salvar=${cliSaved.path}'],
    );
    check(duplicate.exitCode == 2, 'CLI bloqueia sobrescrita');

    final missingOutput = Process.runSync(
      Platform.resolvedExecutable,
      ['run', 'bin/trilhas.dart', source.path, '--favoritar=media'],
    );
    check(missingOutput.exitCode == 2,
        'alteracao sem destino explicito e rejeitada');

    print('PASS: persistencia, filtros, validacao, CLI e protecao do arquivo original');
  } finally {
    directory.deleteSync(recursive: true);
  }
}
