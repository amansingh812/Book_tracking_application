import 'package:equatable/equatable.dart';
import 'package:readora/features/notes/data/models/note_models.dart';

class Note extends Equatable {
  const Note({
    required this.id,
    required this.userBookId,
    required this.kind,
    required this.content,
    required this.createdAt,
    this.page,
    this.chapter,
    this.color,
    this.tags = const [],
    this.isFavorite = false,
  });

  final String id;
  final String userBookId;
  final NoteKind kind;
  final String content;
  final int? page;
  final String? chapter;
  final String? color;
  final List<String> tags;
  final bool isFavorite;
  final DateTime createdAt;

  Note copyWith({
    NoteKind? kind,
    String? content,
    int? page,
    String? chapter,
    String? color,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return Note(
      id: id,
      userBookId: userBookId,
      kind: kind ?? this.kind,
      content: content ?? this.content,
      page: page ?? this.page,
      chapter: chapter ?? this.chapter,
      color: color ?? this.color,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, userBookId, kind, content, page, chapter, color, tags, isFavorite, createdAt];
}
