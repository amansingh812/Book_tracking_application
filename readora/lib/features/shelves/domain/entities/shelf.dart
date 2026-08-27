import 'package:equatable/equatable.dart';

class Shelf extends Equatable {
  const Shelf({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int sortOrder;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, name, sortOrder, createdAt];
}
