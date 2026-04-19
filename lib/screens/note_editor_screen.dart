import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/note_provider.dart';

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

  // Key to validate the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isSaving = false; // Show loading indicator while saving
  bool _hasChanges = false; // Track unsaved changes for the back button

  // Is this an edit session? (true = editing, false = creating)
  bool get _isEditing => widget.noteId != null;

  @override
  void initState() {
    super.initState();

    // If editing, pre-fill the fields with the existing note's data
    if (_isEditing) {
      final noteProvider = context.read<NoteProvider>();
      // Find the note by ID
      final note = noteProvider.notes.firstWhere((n) => n.id == widget.noteId);
      _titleController.text = note.title;
      _contentController.text = note.content;
    }

    // Listen for any changes so we can warn the user before discarding
    _titleController.addListener(_onChanged);
    _contentController.addListener(_onChanged);
  }

  void _onChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  void dispose() {
    // IMPORTANT: Always dispose controllers to prevent memory leaks
    _titleController.dispose();
    _contentController.dispose();
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
      );
    } else {
      // Create a brand new note
      await noteProvider.addNote(
        title: _titleController.text,
        content: _contentController.text,
      );
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

                      // ---- Content Field ----
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
