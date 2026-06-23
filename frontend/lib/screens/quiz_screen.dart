import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/api_client.dart';

class QuizScreen extends StatefulWidget {
  final int sessionId;
  const QuizScreen({super.key, required this.sessionId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Map<String, dynamic>? _session;
  int _currentIndex = 0;
  int? _selectedOption;
  Map<String, dynamic>? _answerResult;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final resp = await ApiClient.instance.get('/api/quizzes/${widget.sessionId}');
      setState(() {
        _session = resp.data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load quiz';
        _loading = false;
      });
    }
  }

  Future<void> _submitAnswer() async {
    if (_selectedOption == null || _session == null) return;
    final question = _session!['questions'][_currentIndex];
    setState(() => _submitting = true);
    try {
      final resp = await ApiClient.instance.post(
        '/api/quizzes/submit-answer',
        data: {
          'session_id': widget.sessionId,
          'question_id': question['id'],
          'selected_index': _selectedOption,
        },
      );
      if (mounted) {
        setState(() {
          _answerResult = resp.data;
          _submitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit answer')),
        );
      }
    }
  }

  void _nextQuestion() {
    final questions = _session!['questions'] as List;
    final isCompleted = _answerResult?['session_completed'] == true;
    final isLastQuestion = _currentIndex >= questions.length - 1;

    if (isCompleted || isLastQuestion) {
      final score = _answerResult?['session_score'] ?? 0;
      context.go(
        '/quiz/${widget.sessionId}/result'
        '?score=$score'
        '&total=${questions.length}',
      );
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedOption = null;
      _answerResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: Center(child: Text(_error!)));

    final questions = _session!['questions'] as List;
    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('No questions found')));
    }
    final question = questions[_currentIndex];
    final options = question['options'] as List;
    final progress = (_currentIndex + 1) / questions.length;
    final correctIndex = _answerResult?['correct_index'] as int?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz (${_currentIndex + 1}/${questions.length})'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/notes'),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.deepPurple.shade100,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      question['question_text'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(options.length, (i) {
                    Color cardColor = Colors.white;
                    if (_answerResult != null) {
                      if (i == correctIndex) {
                        cardColor = Colors.green.shade100;
                      } else if (i == _selectedOption) {
                        cardColor = Colors.red.shade100;
                      }
                    } else if (i == _selectedOption) {
                      cardColor = Colors.deepPurple.shade100;
                    }
                    return GestureDetector(
                      onTap: _answerResult != null
                          ? null
                          : () => setState(() => _selectedOption = i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedOption == i && _answerResult == null
                                ? Colors.deepPurple
                                : Colors.grey.shade300,
                            width: _selectedOption == i && _answerResult == null ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.deepPurple.shade100,
                              child: Text(
                                'ABCD'[i].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                options[i].toString(),
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (_answerResult != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _answerResult!['is_correct']
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _answerResult!['is_correct'] ? Colors.green : Colors.orange,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _answerResult!['is_correct'] ? '✅ Correct!' : '❌ Incorrect',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _answerResult!['is_correct']
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _answerResult!['explanation'] ?? '',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting
                    ? null
                    : (_answerResult != null
                        ? _nextQuestion
                        : (_selectedOption != null ? _submitAnswer : null)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _answerResult != null ? 'Next Question' : 'Submit Answer',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizResultScreen extends StatelessWidget {
  final int sessionId;
  final int score;
  final int total;

  const QuizResultScreen({
    super.key,
    required this.sessionId,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? (score / total * 100).round() : 0;
    final passed = percent >= 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(passed ? '🎉' : '📚', style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 24),
              Text(
                passed ? 'Well Done!' : 'Keep Studying!',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '$score / $total',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    Text(
                      '$percent% Score',
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/notes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Back to Notes', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
