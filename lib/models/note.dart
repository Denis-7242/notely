
// This file defines the Note data model.
// We use Hive annotations so Hive can automatically
// serialize/deserialize Note objects to/from disk.

import 'package:hive/hive.dart';

// Tell Hive this class can be stored. typeId must be unique across your app.
part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  // HiveField assigns a unique index to each field.
  // NEVER change these numbers once the app is shipped — it breaks saved data.

  @HiveField(0)
  late String id; // Unique identifier (UUID)

  @HiveField(1)
  late String title; // Note title

  @HiveField(2)
  late String content; // Note body text

  @HiveField(3)
  late DateTime createdDate; // When the note was first created

  @HiveField(4)
  late DateTime updatedDate; // When the note was last edited

  @HiveField(5)
  List<String> tags = []; // Tags for categorization

  @HiveField(6)
  String? categoryId; // Reference to Category model

  // Named constructor for convenience
  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdDate,
    required this.updatedDate,
    this.tags = const [],
    this.categoryId,
  });

  // Creates a copy of this note with optional overrides.
  // Useful when editing a note without mutating the original.
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdDate,
    DateTime? updatedDate,
    List<String>? tags,
    String? categoryId,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      tags: tags ?? this.tags,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}