import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';

class NoteStorage {
  static const String _boxName = 'notes';

  Box<Note> get _box => Hive.box<Note>(_boxName);
  static Future<void> init() async {
    await Hive.initFlutter(); // Initialize Hive with Flutter path
    Hive.registerAdapter(NoteAdapter()); // Register our Note model
    await Hive.openBox<Note>(_boxName); // Open (or create) the box
  }
  Future<void> addNote(Note note) async {
    await _box.put(note.id, note);
  }

  List<Note> getAllNotes() {
    final notes = _box.values.toList();
    // Sort so the most recently edited note appears first
    notes.sort((a, b) => b.updatedDate.compareTo(a.updatedDate));
    return notes;
  }

  Future<void> updateNote(Note note) async {
    await _box.put(note.id, note); // put() overwrites if key exists
  }

  Future<void> deleteNote(String id) async {
    await _box.delete(id);
  }

  List<Note> searchNotes(String query) {
    if (query.trim().isEmpty) return getAllNotes();

    final lowerQuery = query.toLowerCase();
    return getAllNotes().where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}