import 'dart:async';

import 'package:flutter/material.dart';

import '../shared/di/locator.dart';
import 'models/filme_list_viewmodel.dart';
import 'widgets/filme_list.dart';
import '../filme_detail/filme_detail_screen.dart';

/// Home: busca com debounce e lista de filmes com paginação.
///
/// ## Animação para o detalhe ([FilmeDetailScreen])
///
/// O “voo” da imagem do cartaz usa o widget [Hero] do Flutter (*shared element
/// transition*):
///
/// 1. Em cada cartão, [FilmeCard] envolve o poster num [Hero] com
///    `tag: 'filme-poster-${filme.id}'`, mas **só se** existir `urlImage`
///    (sem URL não há Hero na origem).
/// 2. Ao tocar, esta ecrã faz [Navigator.push] com uma nova rota que constrói
///    [FilmeDetailScreen(filmeId: filme.id)]. O detalhe carrega o mesmo filme
///    pela API e coloca outro [Hero] no fundo do [SliverAppBar] com a **mesma
///    tag** e a mesma URL.
/// 3. O motor de rotas do Flutter associa os dois Heroes pela tag e anima a
///    transição entre retângulos de origem e destino (escala/posição durante o
///    push). `transitionOnUserGestures: true` permite continuar a animação ao
///    arrastar para voltar (no iOS sobretudo).
///
/// Se não houver imagem na lista, não há par Hero na origem: o push é uma
/// transição normal de rota, sem elemento partilhado.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Debounce: só envia para o ViewModel após 500ms sem typing.
  void _scheduleSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      getIt<FilmeListViewModel>().setSearchQuery(_searchController.text);
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    getIt<FilmeListViewModel>().setSearchQuery('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lista de Filmes',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Descubra e comente',
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, _) {
                return TextField(
                  controller: _searchController,
                  onChanged: (_) => _scheduleSearch(),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Buscar por título ou gênero…',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: scheme.primary,
                    ),
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: _clearSearch,
                            tooltip: 'Limpar busca',
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.primary.withValues(alpha: 0.06),
                    scheme.surface,
                  ],
                ),
              ),
              child: FilmeList(
                onFilmeTap: (filme) {
                  // Nova rota full-screen; o Hero em FilmeCard + FilmeDetailScreen
                  // (mesma tag) é interpolado pelo Navigator durante o push.
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          FilmeDetailScreen(filmeId: filme.id),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
