import 'package:flutter/material.dart';

import 'app.dart';
import 'shared/di/locator.dart';

void main() {
  // Inicializa o binding antes de qualquer outra coisa.
  WidgetsFlutterBinding.ensureInitialized();
  // Regista todos os serviços e ViewModels no GetIt.
  setupLocator();
  runApp(const ListaFilmesApp());
}
