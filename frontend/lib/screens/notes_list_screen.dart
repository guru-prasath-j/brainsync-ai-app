"""Notes list screen."""
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/note_model.dart';
import '../services/notes_service.dart';


class NotesListScreen extends StatefulWidget {
  const NotesListScreen({Key? key}) : super(key: key);

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final NotesService _notesService = NotesService();
  late Future<List<NoteModel>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() {
    setState(() {
      _notesFuture = _notesService.getNotes();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'processing':
        return Colors.orange;
      case 'processed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshNotes(),
        child: FutureBuilder<List<NoteModel>>(
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
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshNotes,
                      child: const Text('Retry'),
                    ),
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
                    const Icon(Icons.note_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No notes yet'),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/upload'),
                      icon: const Icon(Icons.add),
                      label: const Text('Upload Your First Note'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${note.fileName} • ${note.formattedSize}'),
                        const SizedBox(height: 4),
                        Text(note.formattedDate, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(note.status),
                      backgroundColor: _getStatusColor(note.status),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    onTap: () => context.go('/notes/${note.id}'),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/upload'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
