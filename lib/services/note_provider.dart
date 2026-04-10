import 'package:flutter/foundation.dart';
import '../models/note.dart';
import 'note_storage.dart';
import 'package:uuid/uuid.dart';

class NoteProvider extends ChangeNotifier {
  final NoteStorage _storage = NoteStorage();
  final Uuid _uuid = const Uuid(); // Used to generate unique IDs

  List<Note> _notes = []; // The in-memory list of notes
  String _searchQuery = ''; // Current search text

  // Returns filtered notes if searching, otherwise all notes
  List<Note> get notes {
    if (_searchQuery.isEmpty) return _notes;
    return _storage.searchNotes(_searchQuery);
  }

  String get searchQuery => _searchQuery;
  void loadNotes() {
    _notes = _storage.getAllNotes();
    notifyListeners(); // Tell the UI to rebuild
  }
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addNote({
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(), // Generate a universally unique ID
      title: title.trim().isEmpty ? 'Untitled' : title.trim(),
      content: content.trim(),
      createdDate: now,
      updatedDate: now,
    );

    await _storage.addNote(note);
    loadNotes(); // Refresh the list
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    // Find the old note so we can keep its createdDate
    final oldNote = _notes.firstWhere((n) => n.id == id);

    final updatedNote = oldNote.copyWith(
      title: title.trim().isEmpty ? 'Untitled' : title.trim(),
      content: content.trim(),
      updatedDate: DateTime.now(), // Update the timestamp
    );

    await _storage.updateNote(updatedNote);
    loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _storage.deleteNote(id);
    loadNotes();
  }
}