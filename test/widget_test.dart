import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:lista_filmes/app.dart';
import 'package:lista_filmes/shared/di/locator.dart';

void main() {
  final getIt = GetIt.instance;

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('ListaFilmesApp smoke test', (WidgetTester tester) async {
    setupLocator();
    await tester.pumpWidget(const ListaFilmesApp());
    await tester.pump();

    expect(find.text('Lista de Filmes'), findsWidgets);
  });
}