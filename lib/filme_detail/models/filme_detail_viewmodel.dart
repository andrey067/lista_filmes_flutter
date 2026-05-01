import 'package:flutter/foundation.dart';

import '../../shared/models/filme.dart';
import '../../shared/services/filme_service.dart';

/// ViewModel do detalhe de um filme e comentários.
///
/// Instâncias criadas por factory (GetIt.registerFactoryParam) — cada ecrã
/// de detalhe recebe a sua própria instância identificada por [filmeId].
/// O método `.load()` é chamado no final do construtor.
class FilmeDetailViewModel extends ChangeNotifier {
  FilmeDetailViewModel(this._service, this.filmeId);

  final FilmeService _service;
  final int filmeId;

  Filme? filme;
  bool isLoading = false;
  bool isSavingComment = false;
  String? errorMessage;

  /// Carrega o filme e comentários do servidor.
  /// Chamado automaticamente no construtor e no "Tentar novamente" do UI.
  Future<void> load() async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      filme = await _service.getFilmeById(filmeId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona comentário com validação 3–300 caracteres (alineado à API).
  /// Após POST bem-sucedido faz `load()` para refletir comentários atualizados.
  Future<void> addComentario(String text) async {
    final trimmed = text.trim();
    // Validação alinhada com a API: 3–300 caracteres.
    if (trimmed.length < 3 || trimmed.length > 300) {
      errorMessage = 'O comentário deve ter entre 3 e 300 caracteres.';
      notifyListeners();
      return;
    }

    isSavingComment = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.addComentario(filmeId, trimmed);
      await load();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isSavingComment = false;
      notifyListeners();
    }
  }

  /// Elimina comentário por id. Recarrega o filme depois para
  /// garantir que a UI reflete o estado real (comentários atualizados).
  Future<void> deleteComentario(int comentarioId) async {
    errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteComentario(filmeId, comentarioId);
      await load();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}