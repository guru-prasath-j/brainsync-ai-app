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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
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
                  Text(passed ? 'Great Job!' : 'Keep Studying!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text('$score / $total',
                          style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        Text('$percent% Score',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (wrongAnswers.isNotEmpty) ...[
              const SizedBox(height: 28),
              const Text('Review Wrong Answers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        Text(q['question_text'],
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.cancel, color: Colors.red, size: 18),
                            const SizedBox(width: 6),
                            Expanded(child: Text('Your answer: ${options[q['selected_index']]}',
                              style: const TextStyle(color: Colors.red))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 18),
                            const SizedBox(width: 6),
                            Expanded(child: Text('Correct: ${options[correctIdx]}',
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500))),
                          ],
                        ),
                        if (q['explanation'] != null && q['explanation'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(q['explanation'],
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
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
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Back to Home', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}