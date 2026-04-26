import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../models/category.dart';
import '../services/note_provider.dart';
import 'package:provider/provider.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap; // Called when the card is tapped (edit)
  final VoidCallback onDelete; // Called when delete is requested

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  // Format the date nicely: "Apr 10, 2026 • 14:30"
  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y • HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    Color categoryColor = colorScheme.primary;
    if (note.categoryId != null) {
      final category = noteProvider.categories.firstWhere(
        (c) => c.id == note.categoryId,
        orElse: () => Category(id: '', name: '', colorValue: colorScheme.primary.value),
      );
      categoryColor = Color(category.colorValue);
    }

    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: _buildSwipeBackground(colorScheme),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Hero(
        tag: note.id,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.3)
                      : colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : colorScheme.outlineVariant.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Category Color Strip
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 6,
                      color: categoryColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.notes_rounded,
                                size: 18,
                                color: categoryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                note.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                  fontSize: 17,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (note.isPinned)
                              Icon(
                                Icons.push_pin_rounded,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert_rounded,
                                size: 20,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onSelected: (value) {
                                if (value == 'pin') {
                                  noteProvider.togglePin(note.id);
                                } else if (value == 'delete') {
                                  onDelete();
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'pin',
                                  child: ListTile(
                                    leading: Icon(
                                      note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                                      size: 20,
                                      color: colorScheme.onSurface,
                                    ),
                                    title: Text(
                                      note.isPinned ? 'Unpin' : 'Pin',
                                      style: TextStyle(color: colorScheme.onSurface),
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.delete_outline_rounded,
                                      size: 20,
                                      color: colorScheme.error,
                                    ),
                                    title: Text(
                                      'Delete',
                                      style: TextStyle(color: colorScheme.error),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (note.content.isNotEmpty)
                          Text(
                            note.content,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                              height: 1.5,
                              fontSize: 14,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),

                        const SizedBox(height: 16),

                        if (note.tags.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: note.tags.take(3).map((tag) => Chip(
                                label: Text(
                                  tag,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                ),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: colorScheme.surfaceVariant,
                                side: BorderSide.none,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              )).toList(),
                            ),
                          ),

                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(note.updatedDate),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.3),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // The red background revealed when swiping left
  Widget _buildSwipeBackground(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_rounded, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
