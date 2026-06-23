import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:brainsync_ai/models/note_model.dart';
import 'package:brainsync_ai/services/notes_service.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final _notesService = NotesService();
  late Future<List<NoteModel>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _notesFuture = _loadNotes();
  }

  Future<List<NoteModel>> _loadNotes() async {
    try {
      return await _notesService.getNotes();
    } catch (e) {
      if (e.toString().contains('401') && mounted) {
        context.go('/login');
      }
      rethrow;
    }
  }

  void _refresh() {
    setState(() { _notesFuture = _loadNotes(); });
  }

  Future<void> _deleteNote(NoteModel note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Delete "${note.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _notesService.deleteNote(note.id);
        _refresh();
      } catch (e) {
        final is404 = e.toString().contains('404');
        if (mounted) {
          if (is404) {
            // Note already gone — refresh list silently
            _refresh();
          } else if (e.toString().contains('401')) {
            context.go('/login');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
            );
          }
        }
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'processing': return Colors.orange;
      case 'processed': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Study Materials'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/home'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async { await context.push('/upload'); _refresh(); },
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<NoteModel>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Failed to load notes', style: Theme.of(context).textTheme.titleMedium),
                  TextButton(onPressed: _refresh, child: const Text('Retry')),
                ],
              ),
            );
          }
          final notes = snapshot.data ?? [];
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No study materials yet'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.go('/upload'),
                    child: const Text('Upload Your First File'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF6C63FF),
                      child: Icon(Icons.description, color: Colors.white),
                    ),
                    title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${note.fileSizeFormatted} • ${note.createdAt.toLocal().toString().substring(0, 10)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(
                            note.status,
                            style: const TextStyle(fontSize: 11, color: Colors.white),
                          ),
                          backgroundColor: _statusColor(note.status),
                          padding: EdgeInsets.zero,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          tooltip: 'Delete',
                          onPressed: () => _deleteNote(note),
                        ),
                      ],
                    ),

                    onTap: () => context.go('/note/${note.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}