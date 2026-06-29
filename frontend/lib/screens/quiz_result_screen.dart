import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';

class QuizResultScreen extends StatefulWidget {
  final int sessionId;
  const QuizResultScreen({Key? key, required this.sessionId}) : super(key: key);

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  Map<String, dynamic>? _session;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final resp = await ApiClient.instance.get('/api/quizzes/${widget.sessionId}');
      setState(() { _session = resp.data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_session == null) return const Scaffold(body: Center(child: Text('Could not load results')));

    final score = _session!['score'] as int;
    final total = _session!['total_questions'] as int;
    final percent = total > 0 ? (score / total * 100).round() : 0;
    final passed = percent >= 60;
    final questions = _session!['questions'] as List;
    final wrongAnswers = questions.where((q) => q['is_correct'] == false).toList();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(passed ? '🎉' : '📚', style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text(
                    passed ? 'Great Job!' : 'Keep Studying!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$score / $total',
                          style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: colorScheme.primary),
                        ),
                        Text(
                          '$percent% Score',
                          style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withOpacity(0.65)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (wrongAnswers.isNotEmpty) ...[
              const SizedBox(height: 28),
              Text(
                'Review Wrong Answers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 12),
              ...wrongAnswers.map((q) {
                final options = q['options'] as List;
                final correctIdx = q['correct_index'] as int;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q['question_text'],
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: colorScheme.onSurface),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.cancel, color: colorScheme.error, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Your answer: ${options[q['selected_index']]}',
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: colorScheme.secondary, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Correct: ${options[correctIdx]}',
                                style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        if (q['explanation'] != null && q['explanation'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            q['explanation'],
                            style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.7)),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Back to Home', style: TextStyle(fontSize: 16, color: colorScheme.onPrimary)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}