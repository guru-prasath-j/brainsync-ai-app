import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:brainsync_ai/screens/splash_screen.dart';
import 'package:brainsync_ai/screens/auth/login_screen.dart';
import 'package:brainsync_ai/screens/auth/register_screen.dart';
import 'package:brainsync_ai/screens/home_screen.dart';
import 'package:brainsync_ai/screens/profile_screen.dart';
import 'package:brainsync_ai/screens/upload_screen.dart';
import 'package:brainsync_ai/screens/notes_list_screen.dart';
import 'package:brainsync_ai/screens/dashboard_screen.dart';
import 'package:brainsync_ai/screens/settings_screen.dart';
import 'package:brainsync_ai/screens/chat_screen.dart';
import 'package:brainsync_ai/screens/quiz_screen.dart';
import 'package:brainsync_ai/screens/summary_screen.dart';
import 'package:brainsync_ai/screens/flashcard_screen.dart';
import 'package:brainsync_ai/services/notes_service.dart';
import 'package:brainsync_ai/models/note_model.dart';
import 'package:brainsync_ai/core/api_client.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/upload', builder: (_, __) => const UploadScreen()),
      GoRoute(path: '/notes', builder: (_, __) => const NotesListScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),

      // Screens that need a note selected first — prompt to go to notes
      GoRoute(
        path: '/chat',
        builder: (_, __) => const _SelectNotePrompt(
          icon: Icons.chat_bubble_outline,
          feature: 'AI Chat',
          hint: 'Open a note from My Notes to start chatting with AI.',
        ),
      ),
      GoRoute(
        path: '/quiz',
        builder: (_, __) => const _SelectNotePrompt(
          icon: Icons.quiz_outlined,
          feature: 'Quiz Mode',
          hint: 'Open a note from My Notes to generate a quiz.',
        ),
      ),
      GoRoute(
        path: '/summaries',
        builder: (_, __) => const _SelectNotePrompt(
          icon: Icons.summarize_outlined,
          feature: 'Summaries',
          hint: 'Open a note from My Notes to view its AI summary.',
        ),
      ),
      GoRoute(
        path: '/flashcards',
        builder: (_, __) => const _SelectNotePrompt(
          icon: Icons.style_outlined,
          feature: 'Flashcards',
          hint: 'Open a note from My Notes to generate flashcards.',
        ),
      ),

      // Note detail
      GoRoute(
        path: '/note/:noteId',
        builder: (_, state) {
          final noteId = int.parse(state.pathParameters['noteId']!);
          return _NoteDetailScreen(noteId: noteId);
        },
      ),

      // Deep routes with path parameters
      GoRoute(
        path: '/chat/:sessionId',
        builder: (_, state) {
          final sessionId = int.parse(state.pathParameters['sessionId']!);
          final title = state.uri.queryParameters['title'];
          final noteIdStr = state.uri.queryParameters['noteId'];
          final noteId = noteIdStr != null ? int.tryParse(noteIdStr) : null;
          return ChatScreen(sessionId: sessionId, noteId: noteId, title: title);
        },
      ),
      GoRoute(
        path: '/quiz/:sessionId',
        builder: (_, state) {
          final sessionId = int.parse(state.pathParameters['sessionId']!);
          return QuizScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/quiz/:sessionId/result',
        builder: (_, state) {
          final sessionId = int.parse(state.pathParameters['sessionId']!);
          final score = int.tryParse(state.uri.queryParameters['score'] ?? '0') ?? 0;
          final total = int.tryParse(state.uri.queryParameters['total'] ?? '0') ?? 0;
          return QuizResultScreen(sessionId: sessionId, score: score, total: total);
        },
      ),
      GoRoute(
        path: '/note/:noteId/summary',
        builder: (_, state) {
          final noteId = int.parse(state.pathParameters['noteId']!);
          final title = state.uri.queryParameters['title'] ?? 'Note';
          return SummaryScreen(noteId: noteId, noteTitle: title);
        },
      ),
      GoRoute(
        path: '/note/:noteId/flashcards',
        builder: (_, state) {
          final noteId = int.parse(state.pathParameters['noteId']!);
          final title = state.uri.queryParameters['title'];
          return FlashcardScreen(noteId: noteId, noteTitle: title);
        },
      ),
    ],
  );
});

class _NoteDetailScreen extends StatefulWidget {
  final int noteId;
  const _NoteDetailScreen({required this.noteId});

  @override
  State<_NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<_NoteDetailScreen> {
  NoteModel? _note;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final note = await NotesService().getNoteById(widget.noteId);
      if (mounted) setState(() { _note = note; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startQuiz() async {
    final note = _note;
    if (note == null) return;
    try {
      final data = await ApiClient.instance.post(
        '/api/quizzes/generate',
        data: {'note_id': note.id, 'num_questions': 5, 'difficulty': 'medium'},
      );
      final sessionId = (data.data as Map<String, dynamic>)['id'] as int;
      if (mounted) context.go('/quiz/$sessionId');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create quiz: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _startChat() async {
    final note = _note;
    if (note == null) return;
    try {
      final data = await ApiClient.instance.post(
        '/api/chat/sessions',
        data: {'note_id': note.id, 'title': note.title},
      );
      final sessionId = (data.data as Map<String, dynamic>)['id'] as int;
      if (mounted) {
        context.go('/chat/$sessionId?noteId=${note.id}&title=${Uri.encodeComponent(note.title)}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start chat: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_note?.title ?? 'Note'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.go('/notes'),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _note == null
              ? const Center(child: Text('Note not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.description, color: Colors.deepPurple),
                          title: Text(_note!.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${_note!.fileName} · ${_note!.fileSizeFormatted}'),
                          trailing: Chip(
                            label: Text(_note!.status, style: const TextStyle(color: Colors.white, fontSize: 11)),
                            backgroundColor: _note!.status == 'processed' ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Study Tools', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _toolBtn(
                        context, Icons.summarize_outlined, 'View Summary', Colors.purple,
                        () => context.go('/note/${_note!.id}/summary?title=${Uri.encodeComponent(_note!.title)}'),
                      ),
                      const SizedBox(height: 8),
                      _toolBtn(
                        context, Icons.chat_bubble_outline, 'Ask AI (Chat)', Colors.blue,
                        _startChat,
                      ),
                      const SizedBox(height: 8),
                      _toolBtn(
                        context, Icons.quiz_outlined, 'Take a Quiz', Colors.green,
                        _startQuiz,
                      ),
                      const SizedBox(height: 8),
                      _toolBtn(
                        context, Icons.style_outlined, 'Flashcards', Colors.orange,
                        () => context.go('/note/${_note!.id}/flashcards?title=${Uri.encodeComponent(_note!.title)}'),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _toolBtn(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        icon: Icon(icon),
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }
}

class _SelectNotePrompt extends StatelessWidget {
  final IconData icon;
  final String feature;
  final String hint;

  const _SelectNotePrompt({
    required this.icon,
    required this.feature,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(feature),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: Colors.deepPurple.withValues(alpha: 0.4)),
              const SizedBox(height: 24),
              Text(
                feature,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                hint,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                icon: const Icon(Icons.list_alt),
                label: const Text('Go to My Notes'),
                onPressed: () => context.go('/notes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
