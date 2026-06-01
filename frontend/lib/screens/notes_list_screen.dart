import 'package:flutter/material.dart';
import 'package:brainsync/models/note_model.dart';
import 'package:brainsync/services/notes_service.dart';

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
    _notesFuture = _notesService.getNotes();
  }

  void _refresh() {
    setState(() => _notesFuture = _notesService.getNotes());
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
      appBar: AppBar(title: const Text('My Study Materials')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/upload').then((_) => _refresh()),
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
                    onPressed: () => Navigator.pushNamed(context, '/upload'),
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
                    subtitle: Text(note.fileSizeFormatted + ' • ' +
                        note.createdAt.toLocal().toString().substring(0, 10)),
                    trailing: Chip(
                      label: Text(note.status,
                          style: const TextStyle(fontSize: 11, color: Colors.white)),
                      backgroundColor: _statusColor(note.status),
                      padding: EdgeInsets.zero,
                    ),
                    onTap: () => Navigator.pushNamed(context, '/note/' + note.id.toString()),
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