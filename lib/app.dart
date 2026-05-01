import 'package:flutter/material.dart';

import 'home/home_screen.dart';
import 'shared/theme/app_theme.dart';

/// Raiz do app: [MaterialApp] com tema claro/escuro partilhado ([AppTheme]).
/// Modo escuro por defeito — paleta tipo streaming (Inter + índigo).
class ListaFilmesApp extends StatelessWidget {
  const ListaFilmesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Filmes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}