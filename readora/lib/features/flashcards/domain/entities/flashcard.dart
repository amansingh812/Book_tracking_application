import 'package:equatable/equatable.dart';

/// The four grades a reader can give a card on review, matching Anki's
/// convention. Mapped to an SM-2-lite ease/interval update in the repository.
enum ReviewGrade { again, hard, good, easy }

class Flashcard extends Equatable {
  const Flashcard({
    required this.id,
    required this.front,
    required this.back,
    required this.ease,
    required this.intervalDays,
    required this.reps,
    required this.lapses,
    required this.dueAt,
    this.userBookId,
    this.noteId,
  });

  final String id;
  final String? userBookId;
  final String? noteId;
  final String front;
  final String back;
  final double ease;
  final int intervalDays;
  final int reps;
  final int lapses;
  final DateTime dueAt;

  bool get isDue => !dueAt.isAfter(DateTime.now());

  @override
  List<Object?> get props =>
      [id, userBookId, noteId, front, back, ease, intervalDays, reps, lapses, dueAt];
}
