import 'package:get_it/get_it.dart';

import 'package:lista_filmes/filme_detail/models/filme_detail_viewmodel.dart';
import 'package:lista_filmes/home/models/filme_list_viewmodel.dart';
import 'package:lista_filmes/shared/services/filme_service.dart';

final GetIt getIt = GetIt.instance;

/// Configura a injeção de dependências.
///
/// FilmeService: singleton porque é o único cliente HTTP para a API.
/// FilmeListViewModel: singleton — estado partilhado entre todo o app para a lista.
/// FilmeDetailViewModel: factory com param1=filmeId — cada tela de detalhe
///   cria a sua própria instância (reset ao voltar e reentrar).
void setupLocator() {
  // Cliente HTTP único (uma conexão com a API de filmes).
  getIt.registerLazySingleton<FilmeService>(() => FilmeService());

  // ViewModel da lista: singleton para manter estado da busca/paginação
  // acessível globalmente (HomeScreen + FilmeListWidget).
  getIt.registerLazySingleton<FilmeListViewModel>(
    () => FilmeListViewModel(getIt<FilmeService>())..loadInitial(),
  );

  // ViewModel do detalhe: factory por filmeId — cada navegação cria
  // uma instância nova via param1. O .load() é chamado no construtor.
  getIt.registerFactoryParam<FilmeDetailViewModel, int, void>(
    (filmeId, _) =>
        FilmeDetailViewModel(getIt<FilmeService>(), filmeId)..load(),
  );
}