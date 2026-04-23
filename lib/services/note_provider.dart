import 'package:flutter/foundation.dart' hide Category;
import '../models/note.dart';
import '../models/category.dart';
import 'note_storage.dart';
import 'package:uuid/uuid.dart';

class NoteProvider extends ChangeNotifier {
  final NoteStorage _storage = NoteStorage();
  final Uuid _uuid = const Uuid(); // Used to generate unique IDs

  List<Note> _notes = []; // The in-memory list of notes
  String _searchQuery = ''; // Current search text
  String? _selectedCategoryId; // Currently filtered category
  String? _selectedTag; // Currently filtered tag

  // Returns filtered notes based on search, category, and tag
  List<Note> get notes {
    List<Note> result = _notes;

    // 1. Search Query Filter
    if (_searchQuery.isNotEmpty) {
      result = _storage.searchNotes(_searchQuery);
    }

    // 2. Category Filter
    if (_selectedCategoryId != null) {
      result = result.where((note) => note.categoryId == _selectedCategoryId).toList();
    }

    // 3. Tag Filter
    if (_selectedTag != null) {
      result = result.where((note) => note.tags.contains(_selectedTag)).toList();
    }

    return result;
  }

  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  String? get selectedTag => _selectedTag;

  void loadNotes() {
    _notes = _storage.getAllNotes();
    notifyListeners(); // Tell the UI to rebuild
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryId(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSelectedTag(String? tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  Future<void> addNote({
    required String title,
    required String content,
    List<String> tags = const [],
    String? categoryId,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(), // Generate a universally unique ID
      title: title.trim().isEmpty ? 'Untitled' : title.trim(),
      content: content.trim(),
      createdDate: now,
      updatedDate: now,
      tags: tags,
      categoryId: categoryId,
    );

    await _storage.addNote(note);
    loadNotes(); // Refresh the list
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
    List<String> tags = const [],
    String? categoryId,
  }) async {
    // Find the old note so we can keep its createdDate
    final oldNote = _notes.firstWhere((n) => n.id == id);

    final updatedNote = oldNote.copyWith(
      title: title.trim().isEmpty ? 'Untitled' : title.trim(),
      content: content.trim(),
      updatedDate: DateTime.now(), // Update the timestamp
      tags: tags,
      categoryId: categoryId,
    );

    await _storage.updateNote(updatedNote);
    loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _storage.deleteNote(id);
    loadNotes();
  }

  // --- Category Management ---

  List<Category> get categories {
    return _storage.getAllCategories();
  }

  Future<void> addCategory({
    required String name,
    required int colorValue,
  }) async {
    final category = Category(
      id: _uuid.v4(),
      name: name,
      colorValue: colorValue,
    );
    await _storage.addCategory(category);
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    await _storage.deleteCategory(id);
    if (_selectedCategoryId == id) {
      _selectedCategoryId = null;
    }
    notifyListeners();
  }
}
