import 'package:flutter/foundation.dart';

import '../../shared/models/filme.dart';
import '../../shared/services/filme_service.dart';

/// ViewModel da lista de filmes (busca + paginação + pull-to-refresh).
///
/// Padrao: [ChangeNotifier] — estado reativo PULL-BASED.
///
/// PULL-BASED (ChangeNotifier):
///   O widget se inscreve com addListener no initState.
///   Quando o ViewModel muda algo, chama notifyListeners().
///   O widget rebuilda e LÊ os valores atuais do ViewModel (PULL).
///
/// Esta classe usa Provider/ChangeNotifier (nao Stream).
/// Ciclo de vida:
/// - Singleton: vive durante toda a sessão da app (recalcula ao buscar).
/// - `loadInitial`: busca da primeira página com ou sem filtro `q`.
/// - `loadMore`: acrescent a páginas ao aproximar-se do fim do scroll.
/// - `refresh`: volta à primeira página mantendo o filtro atual.
class FilmeListViewModel extends ChangeNotifier {
  FilmeListViewModel(this._service);

  final FilmeService _service;

  List<Filme> filmes = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  String? errorMessage;
  String? _query;
  int _skip = 0;
  static const int _pageSize = 20;
  bool hasMore = true;

  String? get query => _query;

  /// Atualiza o filtro de busca — chamado pela UI após debounce de 500 ms.
  void setSearchQuery(String q) {
    final trimmed = q.trim();
    // Passa null se vazio para listar tudo.
    loadInitial(q: trimmed.isEmpty ? null : trimmed);
  }

  /// Busca a primeira página (reset do cursor `_skip`).
  Future<void> loadInitial({String? q}) async {
    final previousFilmes = filmes;
    _query = q;
    _skip = 0;
    hasMore = true;
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      final list = await _service.getFilmes(
        skip: 0,
        take: _pageSize,
        q: _query,
      );
      filmes = list;
      _skip = filmes.length;
      hasMore = list.length >= _pageSize;
    } catch (e) {
      errorMessage = e.toString();
      filmes = previousFilmes;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega a próxima página — ignora se já está carregando ou não há mais.
  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isLoading) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final list = await _service.getFilmes(
        skip: _skip,
        take: _pageSize,
        q: _query,
      );
      if (list.isEmpty) {
        hasMore = false;
      } else {
        filmes = [...filmes, ...list];
        _skip = filmes.length;
        hasMore = list.length >= _pageSize;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Pull-to-refresh: mantém o filtro actual.
  Future<void> refresh() => loadInitial(q: _query);
}