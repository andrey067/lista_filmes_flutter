import 'package:flutter/material.dart';

import '../../shared/di/locator.dart';
import '../../shared/models/filme.dart';
import '../models/filme_list_viewmodel.dart';
import 'filme_card.dart';
import '../../shared/widgets/loading_indicator.dart';

/// Lista em grelha responsiva com scroll infinito e estados ricos.
///
/// Padrao: [ChangeNotifier] — estado reativo PULL-BASED.
///
/// PULL-BASED (ChangeNotifier):
///   1. initState: `addListener(_onVmChanged)` — se inscreve no ViewModel
///   2. ViewModel muda estado e chama `notifyListeners()`
///   3. Callback `_onVmChanged()` executa `setState(() {})`
///   4. Widget rebuilda e LÊ `vm.filmes`, `vm.isLoading`, etc.
///
/// Esta classe usa o padrao PULL-BASED (ChangeNotifier).
///
/// Estados geridos:
/// - Loading inicial → LoadingIndicator
/// - Erro → UI de erro com "Tentar novamente"
/// - Lista vazia → UI dedicada
/// - Sucesso → GridView.builder com scroll infinito (loadMore a -400 px do fim)
class FilmeList extends StatefulWidget {
  const FilmeList({super.key, required this.onFilmeTap});

  final void Function(Filme filme) onFilmeTap;

  @override
  State<FilmeList> createState() => _FilmeListState();
}

class _FilmeListState extends State<FilmeList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    getIt<FilmeListViewModel>().addListener(_onVmChanged);
  }

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  // Scroll threshold: carrega mais quando faltam 400 px para o fim.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    if (offset >= max - 400) {
      getIt<FilmeListViewModel>().loadMore();
    }
  }

  @override
  void dispose() {
    getIt<FilmeListViewModel>().removeListener(_onVmChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = getIt<FilmeListViewModel>();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (vm.isLoading && vm.filmes.isEmpty) {
      return const LoadingIndicator(message: 'Carregando filmes…');
    }

    // Loading durante busca: mantém grid visível + indicador discreto no topo.
    if (vm.isLoading) {
      return Column(
        children: [
          LinearProgressIndicator(
            minHeight: 2,
            color: scheme.primary,
            backgroundColor: scheme.primary.withValues(alpha: 0.2),
          ),
          Expanded(child: _buildGrid(vm, scheme)),
        ],
      );
    }

    // Erro ao carregar os filmes
    if (vm.errorMessage != null && vm.filmes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded, size: 56, color: scheme.error),
                const SizedBox(height: 16),
                Text(
                  'Algo deu errado',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  vm.errorMessage!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => vm.refresh(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Lista vazia
    if (vm.filmes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 52,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum filme encontrado',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ajuste o termo de busca ou limpe o campo para ver todos.',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return _buildGrid(vm, scheme);
  }

  // Grid de filmes
  Widget _buildGrid(FilmeListViewModel vm, ColorScheme scheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final crossAxisCount = w >= 900 ? 4 : (w >= 600 ? 3 : 2);

        return RefreshIndicator(
          onRefresh: vm.refresh,
          color: scheme.primary,
          edgeOffset: 8,
          child: GridView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.58,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: vm.filmes.length + (vm.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= vm.filmes.length) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.primary,
                    ),
                  ),
                );
              }
              final filme = vm.filmes[index];
              return FilmeCard(
                filme: filme,
                onTap: () => widget.onFilmeTap(filme),
              );
            },
          ),
        );
      },
    );
  }
}
