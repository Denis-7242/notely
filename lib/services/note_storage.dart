import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import '../models/category.dart';

class NoteStorage {
  static const String _notesBoxName = 'notes';
  static const String _categoriesBoxName = 'categories';

  Box<Note> get _notesBox => Hive.box<Note>(_notesBoxName);
  Box<Category> get _categoriesBox => Hive.box<Category>(_categoriesBoxName);

  static Future<void> init() async {
    await Hive.initFlutter(); // Initialize Hive with Flutter path
    Hive.registerAdapter(NoteAdapter()); // Register our Note model
    Hive.registerAdapter(CategoryAdapter()); // Register our Category model
    await Hive.openBox<Note>(_notesBoxName); // Open (or create) the box
    await Hive.openBox<Category>(_categoriesBoxName); // Open (or create) the box
  }

  Future<void> addNote(Note note) async {
    await _notesBox.put(note.id, note);
  }

  List<Note> getAllNotes() {
    final notes = _notesBox.values.toList();
    // Sort so the most recently edited note appears first
    notes.sort((a, b) => b.updatedDate.compareTo(a.updatedDate));
    return notes;
  }

  Future<void> updateNote(Note note) async {
    await _notesBox.put(note.id, note); // put() overwrites if key exists
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }

  List<Note> searchNotes(String query) {
    if (query.trim().isEmpty) return getAllNotes();

    final lowerQuery = query.toLowerCase();
    return getAllNotes().where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // --- Category Management ---

  Future<void> addCategory(Category category) async {
    await _categoriesBox.put(category.id, category);
  }

  List<Category> getAllCategories() {
    return _categoriesBox.values.toList();
  }

  Future<void> updateCategory(Category category) async {
    await _categoriesBox.put(category.id, category);
  }

  Future<void> deleteCategory(String id) async {
    await _categoriesBox.delete(id);
  }

  Category? getCategory(String id) {
    return _categoriesBox.get(id);
  }
}
