import 'comentario.dart';

/// ReadFilmeDto da API (lista e detalhe; detalhe inclui `comments`).
class Filme {
  const Filme({
    required this.id,
    this.name,
    required this.year,
    required this.duration,
    this.description,
    this.gender,
    this.urlImage,
    required this.dateCreated,
    this.dateUpdated,
    this.comments = const [],
  });

  final int id;
  final String? name;
  final int year;
  final int duration;
  final String? description;
  final String? gender;
  final String? urlImage;
  final DateTime dateCreated;
  final DateTime? dateUpdated;
  final List<Comentario> comments;

  factory Filme.fromJson(Map<String, dynamic> json) {
    final commentsJson = json['comments'] as List<dynamic>?;
    return Filme(
      id: json['id'] as int,
      name: json['name'] as String?,
      year: json['year'] as int,
      duration: json['duration'] as int,
      description: json['description'] as String?,
      gender: json['gender'] as String?,
      urlImage: json['url_image'] as String?,
      dateCreated: DateTime.parse(json['date_created'] as String),
      dateUpdated: json['date_updated'] != null
          ? DateTime.parse(json['date_updated'] as String)
          : null,
      comments: commentsJson == null
          ? const []
          : commentsJson
              .map((e) => Comentario.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Filme copyWith({
    int? id,
    String? name,
    int? year,
    int? duration,
    String? description,
    String? gender,
    String? urlImage,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    List<Comentario>? comments,
  }) {
    return Filme(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      gender: gender ?? this.gender,
      urlImage: urlImage ?? this.urlImage,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      comments: comments ?? this.comments,
    );
  }
}