import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/filme.dart';

/// Cliente HTTP para [API Filmes](https://apifilmes.webevolui.com/swagger/index.html).
class FilmeService {
  FilmeService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'https://apifilmes.webevolui.com';

  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: query);
  }

  /// GET /Filme — lista com paginação e busca opcional [q].
  Future<List<Filme>> getFilmes({
    int skip = 0,
    int take = 20,
    String? q,
  }) async {
    final query = <String, String>{
      'skip': '$skip',
      'take': '$take',
      if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
    };
    final response = await _client.get(_uri('/Filme', query));
    if (response.statusCode != 200) {
      throw FilmeApiException(
        'Falha ao listar filmes (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => Filme.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /Filme/{id} — detalhe com comentários.
  Future<Filme> getFilmeById(int id) async {
    final response = await _client.get(_uri('/Filme/$id'));
    if (response.statusCode != 200) {
      throw FilmeApiException(
        'Falha ao carregar filme (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return Filme.fromJson(map);
  }

  /// POST /Filme/{idfilme}/Comentario — corpo: `{ "comment": "..." }`.
  Future<void> addComentario(int idFilme, String comment) async {
    final response = await _client.post(
      _uri('/Filme/$idFilme/Comentario'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'comment': comment}),
    );
    if (response.statusCode != 201) {
      throw FilmeApiException(
        'Não foi possível adicionar o comentário (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
  }

  /// DELETE /Filme/{idfilme}/Comentario/{id}.
  Future<void> deleteComentario(int idFilme, int comentarioId) async {
    final response = await _client.delete(
      _uri('/Filme/$idFilme/Comentario/$comentarioId'),
    );
    if (response.statusCode != 204) {
      throw FilmeApiException(
        'Não foi possível excluir o comentário (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
  }
}

/// Exceção HTTP para falhas da API de filmes.
class FilmeApiException implements Exception {
  FilmeApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}