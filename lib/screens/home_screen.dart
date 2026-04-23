import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/note_provider.dart';
import '../services/theme_provider.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';
import '../models/category.dart';

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
    return Consumer2<NoteProvider, ThemeProvider>(
      builder: (context, noteProvider, themeProvider, _) {
        final notes = noteProvider.notes;
        final colorScheme = Theme.of(context).colorScheme;
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            backgroundColor: colorScheme.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Notely',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            actions: [
              if (notes.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                  ),
                  child: Text(
                    '${notes.length} notes',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    key: ValueKey(themeProvider.isDarkMode),
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                tooltip: 'Toggle theme',
                onPressed: () => themeProvider.toggleTheme(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    SearchBar(
                      controller: _searchController,
                      hintText: 'Search your notes...',
                      leading: Icon(
                        Icons.search_rounded,
                        color: colorScheme.onSurface.withOpacity(0.4),
                      ),
                      trailing: [
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
                      elevation: WidgetStatePropertyAll(0),
                      backgroundColor: WidgetStatePropertyAll(
                        colorScheme.surface.withOpacity(0.7),
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
                        ),
                      ),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ---- Filter Bar ----
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: noteProvider.selectedCategoryId == null &&
                                        noteProvider.selectedTag == null,
                            onSelected: (_) {
                              noteProvider.setCategoryId(null);
                              noteProvider.setSelectedTag(null);
                            },
                            selectedColor: colorScheme.primary.withOpacity(0.2),
                            checkmarkColor: colorScheme.primary,
                            backgroundColor: colorScheme.surfaceVariant,
                            labelStyle: TextStyle(
                              color: noteProvider.selectedCategoryId == null &&
                                      noteProvider.selectedTag == null
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ...noteProvider.categories.map((cat) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(cat.name),
                              selected: noteProvider.selectedCategoryId == cat.id,
                              onSelected: (_) => noteProvider.setCategoryId(
                                noteProvider.selectedCategoryId == cat.id ? null : cat.id,
                              ),
                              selectedColor: Color(cat.colorValue).withOpacity(0.2),
                              checkmarkColor: Color(cat.colorValue),
                              backgroundColor: colorScheme.surfaceVariant,
                              labelStyle: TextStyle(
                                color: noteProvider.selectedCategoryId == cat.id
                                    ? Color(cat.colorValue)
                                    : colorScheme.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: notes.isEmpty
                    ? _buildEmptyState(context, noteProvider.searchQuery)
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 100),
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
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openEditor(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'New Note',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.note_add_outlined,
                size: 64,
                color: colorScheme.primary.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              isSearching ? 'No results found' : 'No notes yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isSearching
                  ? 'We couldn\'t find any notes matching your search'
                  : 'Your thoughts will appear here. Tap the button to create your first note',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
