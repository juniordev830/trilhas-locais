# Trilhas Locais — Flutter MVP

Aplicativo de catálogo manual de trilhas em **Dart + Flutter**, sem uso automático da localização.

## Entregue
- Cadastro de percurso (nome, distância, dificuldade e observações).
- Filtro por distância máxima e dificuldade.
- Marcar/desmarcar favoritos e visualizar somente os favoritos.
- Regras isoladas e testes; filtro de 5 km exclui trilhas mais longas.

## Executar
Requer Flutter estável com Dart 3.3+:
```bash
flutter pub get
flutter run -d chrome
```
Também pode ser executado nos dispositivos para os quais você instalar a plataforma Flutter correspondente.

## Validar
```bash
flutter analyze
flutter test
flutter build web
```

## Limites
Os dados ficam apenas em memória durante a sessão: não há conta, persistência, mapas ou GPS. Recomendado preparar armazenamento local e uma versão mobile numa próxima etapa.
