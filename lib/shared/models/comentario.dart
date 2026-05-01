/// Comentário retornado pela API em detalhes do filme.
class Comentario {
  const Comentario({
    required this.id,
    required this.comment,
    required this.filmeId,
    required this.dateCreated,
  });

  final int id;
  final String comment;
  final int filmeId;
  final DateTime dateCreated;

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['id'] as int,
      comment: json['comment'] as String,
      filmeId: json['filme_id'] as int,
      dateCreated: DateTime.parse(json['date_created'] as String),
    );
  }
}