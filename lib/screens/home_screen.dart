import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/note_provider.dart';
import '../services/theme_provider.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose(); // Always clean up controllers!
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, String noteId) async {
    final noteProvider = context.read<NoteProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    // showDialog returns the value passed to Navigator.pop()
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Note'),
        content: const Text(
          'Are you sure you want to delete this note?\nThis action cannot be undone.',
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          // Confirm delete button
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // Only delete if user tapped "Delete"
    if (confirmed == true) {
      await noteProvider.deleteNote(noteId);
    }
  }

  void _openEditor(BuildContext context, {String? noteId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(noteId: noteId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Consumer<NoteProvider> rebuilds this widget when notes change
    return Consumer2<NoteProvider, ThemeProvider>(
      builder: (context, noteProvider, themeProvider, _) {
        final notes = noteProvider.notes;
        final colorScheme = Theme.of(context).colorScheme;
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Row(
              children: [
                // App logo / icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Notely',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            actions: [
              // Note count badge
              if (notes.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${notes.length} note${notes.length == 1 ? '' : 's'}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              // Dark/Light mode toggle
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    key: ValueKey(themeProvider.isDarkMode),
                    color: colorScheme.primary,
                  ),
                ),
                tooltip: 'Toggle theme',
                onPressed: () => themeProvider.toggleTheme(),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: Column(
            children: [
              // ---- Search Bar ----
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Search notes...',
                  leading: Icon(
                    Icons.search_rounded,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  trailing: [
                    // Show clear button only when there's text
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          noteProvider.setSearchQuery('');
                        },
                      ),
                  ],
                  onChanged: (query) {
                    noteProvider.setSearchQuery(query);
                  },
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(
                    colorScheme.surfaceContainerHighest.withOpacity(0.6),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),

              // ---- Notes List or Empty State ----
              Expanded(
                child: notes.isEmpty
                    ? _buildEmptyState(context, noteProvider.searchQuery)
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return NoteCard(
                            note: note,
                            onTap: () => _openEditor(
                              context,
                              noteId: note.id,
                            ),
                            onDelete: () => _confirmDelete(context, note.id),
                          );
                        },
                      ),
              ),
            ],
          ),

          // ---- Floating Action Button ----
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openEditor(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'New Note',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String searchQuery) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSearching = searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.note_add_outlined,
                size: 56,
                color: colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching ? 'No results found' : 'No notes yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try a different search term'
                  : 'Tap the + button below to create your first note',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.55),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
