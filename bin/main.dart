import 'dart:convert';
import 'dart:io';
import '../lib/trails.dart';

void check(bool result, String label) {
  if (!result) throw StateError(label);
}

void runTests() {
  final trails = TrailCatalog();
  trails.add(Trail('curta', 'Trilha fictícia curta', 3.5, 'facil'));
  trails.add(Trail('longa', 'Trilha fictícia longa', 7.2, 'moderada'));
  check(trails.filter(maxKm: 5).map((t) => t.id).join() == 'curta',
    'Filtro deve excluir percursos acima de 5 km');
  trails.favorite('curta');
  check(trails.favorites().single.id == 'curta', 'Favorito não persistiu');
  final restored = TrailCatalog.fromJson(trails.exportJson());
  check(restored.favorites().single.id == 'curta', 'Backup não restaurou favorito');
  var rejected = false;
  try { trails.add(Trail('curta', 'Repetida', 1, 'facil')); }
  on FormatException { rejected = true; }
  check(rejected, 'Duplicação deve ser rejeitada');
  print('4 verificações concluídas');
}

void main(List<String> args) {
  try {
    if (args.length == 1 && args.first == '--self-test') {
      runTests();
      return;
    }
    if (args.length > 2 || args.any((arg) => arg.startsWith('--'))) {
      throw const FormatException('Uso: dart run bin/main.dart [MAX_KM [DIFICULDADE]]');
    }
    final catalog = TrailCatalog()
      ..add(Trail('parque', 'Parque fictício', 2.8, 'facil', notes: 'Exemplo, não usar para navegação'))
      ..add(Trail('serra', 'Serra fictícia', 6.4, 'moderada'));
    final distance = args.isEmpty ? null : double.parse(args.first);
    final difficulty = args.length == 2 ? args[1] : null;
    final data = catalog.filter(maxKm: distance, difficulty: difficulty);
    print(const JsonEncoder.withIndent('  ').convert(data.map((t) => t.toJson()).toList()));
  } catch (error) {
    stderr.writeln('Erro: $error');
    exitCode = 2;
  }
}
