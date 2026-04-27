import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/note_provider.dart';
import '../models/category.dart';
import '../widgets/markdown_toolbar.dart';

class NoteEditorScreen extends StatefulWidget {
  // null means "create new", a string ID means "edit existing"
  final String? noteId;

  const NoteEditorScreen({super.key, this.noteId});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  // Controllers to read/write text field values
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  // Key to validate the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isSaving = false; // Show loading indicator while saving
  bool _hasChanges = false; // Track unsaved changes for the back button
  bool _isPinned = false; // Track pin status

  String? _selectedCategoryId;
  List<String> _tags = [];

  // Is this an edit session? (true = editing, false = creating)
  bool get _isEditing => widget.noteId != null;

  @override
  void initState() {
    super.initState();

    // If editing, pre-fill the fields with the existing note's data
    if (_isEditing) {
      final noteProvider = context.read<NoteProvider>();
      // Find the note by ID
      final note = noteProvider.notes.firstWhere((n) => n.id == widget.noteId!);
      _titleController.text = note.title;
      _contentController.text = note.content;
      _selectedCategoryId = note.categoryId;
      _tags = List<String>.from(note.tags);
      _isPinned = note.isPinned;
    }

    // Listen for any changes so we can warn the user before discarding
    _titleController.addListener(_onChanged);
    _contentController.addListener(_onChanged);
  }

  void _onChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  void _applyFormatting(String action) {
    final text = _contentController.text;
    final selection = _contentController.selection;

    if (selection.isCollapsed) return;

    final selectedText = selection.textInside(text);
    String replacement = '';

    if (action == 'bold') {
      replacement = '**$selectedText**';
    } else if (action == 'italic') {
      replacement = '*$selectedText*';
    } else if (action == 'bullet') {
      // For bullets, we just insert at the beginning of the line or selection
      // Simplified: wrap selection with a newline and bullet if not already there
      replacement = '\n- $selectedText';
    }

    if (replacement.isNotEmpty) {
      final newText = text.replaceRange(selection.start, selection.end, replacement);
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + replacement.length,
        ),
      );
      setState(() => _hasChanges = true);
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _hasChanges = true;
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      _hasChanges = true;
    });
  }

  @override
  void dispose() {
    // IMPORTANT: Always dispose controllers to prevent memory leaks
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    // Validate: title must not be empty
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final noteProvider = context.read<NoteProvider>();

    if (_isEditing) {
      // Update the existing note
      await noteProvider.updateNote(
        id: widget.noteId!,
        title: _titleController.text,
        content: _contentController.text,
        tags: _tags,
        categoryId: _selectedCategoryId,
      );
      // Also handle pinning if it changed
      final note = noteProvider.notes.firstWhere((n) => n.id == widget.noteId!);
      if (note.isPinned != _isPinned) {
        await noteProvider.togglePin(widget.noteId!);
      }
    } else {
      // Create a brand new note
      await noteProvider.addNote(
        title: _titleController.text,
        content: _contentController.text,
        tags: _tags,
        categoryId: _selectedCategoryId,
      );
      // If the new note was pinned in the editor, pin it now
      if (_isPinned) {
        // Note: addNote doesn't return the ID, so we need to find the latest note
        // or update addNote to accept isPinned.
        // For now, since we just added it, the last note in the list is likely it.
        final latestNote = noteProvider.notes.last;
        await noteProvider.togglePin(latestNote.id);
      }
    }

    setState(() => _isSaving = false);

    // Go back to the HomeScreen
    if (mounted) Navigator.pop(context);
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true; // No changes — safe to go back

    // Ask the user if they want to discard changes
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to go back?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final noteProvider = context.read<NoteProvider>();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          backgroundColor: colorScheme.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () async {
              if (await _onWillPop()) Navigator.pop(context);
            },
          ),
          title: Text(
            _isEditing ? 'Edit Note' : 'New Note',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                color: _isPinned ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
              ),
              onPressed: () {
                setState(() {
                  _isPinned = !_isPinned;
                  _hasChanges = true;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveNote,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                label: Text(_isSaving ? 'Saving...' : 'Save'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- Title Field ----
                      TextFormField(
                        controller: _titleController,
                        autofocus: !_isEditing,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Note title...',
                          hintStyle: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.3),
                            fontWeight: FontWeight.w800,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title for your note';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // ---- Metadata row ----
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: colorScheme.onSurface.withOpacity(0.4),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isEditing ? 'Editing note' : 'New note',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.4),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ---- Category Selection ----
                      Text(
                        'Category',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // No Category option
                            GestureDetector(
                              onTap: () => setState(() {
                                _selectedCategoryId = null;
                                _hasChanges = true;
                              }),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: _selectedCategoryId == null
                                      ? colorScheme.primary.withOpacity(0.2)
                                      : colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _selectedCategoryId == null
                                        ? colorScheme.primary
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'None',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _selectedCategoryId == null
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ...noteProvider.categories.map((cat) => GestureDetector(
                              onTap: () => setState(() {
                                _selectedCategoryId = cat.id;
                                _hasChanges = true;
                              }),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: _selectedCategoryId == cat.id
                                      ? Color(cat.colorValue).withOpacity(0.2)
                                      : colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _selectedCategoryId == cat.id
                                        ? Color(cat.colorValue)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    cat.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _selectedCategoryId == cat.id
                                          ? Color(cat.colorValue)
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ---- Tag Management ----
                      Text(
                        'Tags',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tagController,
                              style: theme.textTheme.bodyMedium,
                              decoration: InputDecoration(
                                hintText: 'Add a tag...',
                                prefixIcon: const Icon(Icons.tag, size: 16),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onFieldSubmitted: (_) => _addTag(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _addTag,
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) => Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 12)),
                          onDeleted: () => _removeTag(tag),
                          backgroundColor: colorScheme.surfaceVariant,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        )).toList(),
                      ),

                      const SizedBox(height: 24),

                      // ---- Content Field ----
                      MarkdownToolbar(onAction: (action) => _applyFormatting(action)),
                      TextFormField(
                        controller: _contentController,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.7,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Start writing your note here...',
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.3),
                            height: 1.7,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 300),
                    ],
                  ),
                ),
              ),

              // ---- Bottom action bar ----
              Container(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 20,
                  bottom: MediaQuery.of(context).padding.bottom + 20,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.background,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outlineVariant.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          if (await _onWillPop()) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _saveNote,
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: const Text(
                          'Save Note',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
