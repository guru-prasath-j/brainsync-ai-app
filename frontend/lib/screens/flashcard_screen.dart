import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/api_client.dart';
import '../core/theme.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key, required this.noteId, this.noteTitle});
  final int noteId;
  final String? noteTitle;

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Map<String, dynamic>> _cards = [];
  int _index = 0;
  bool _isLoading = true;
  bool _isGenerating = false;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient.instance.get('/api/flashcards/${widget.noteId}');
      final data = (res.data as List).cast<Map<String, dynamic>>();
      setState(() {
        _cards = data;
        _index = 0;
        _showAnswer = false;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generate() async {
    setState(() => _isGenerating = true);
    try {
      final res = await ApiClient.instance.post(
        '/api/flashcards/${widget.noteId}/generate',
        data: {},
      );
      final data = (res.data as List).cast<Map<String, dynamic>>();
      setState(() {
        _cards = data;
        _index = 0;
        _showAnswer = false;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rate(bool known) async {
    final card = _cards[_index];
    try {
      await ApiClient.instance.patch(
        '/api/flashcards/${card['id']}/rate',
        data: {'known': known},
      );
    } catch (_) {}
    setState(() {
      _cards[_index]['known'] = known;
      _showAnswer = false;
    });
    await Future.delayed(const Duration(milliseconds: 200));
    if (_index < _cards.length - 1) {
      setState(() => _index++);
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final known = _cards.where((c) => c['known'] == true).length;
    final unknown = _cards.where((c) => c['known'] == false).length;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Session Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, size: 48, color: AppTheme.accent),
            const SizedBox(height: 16),
            Text(
              '$known / ${_cards.length} cards known',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ResultBadge(Icons.check_circle, known.toString(), Colors.green),
                _ResultBadge(Icons.cancel, unknown.toString(), Colors.red),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _index = 0;
                _showAnswer = false;
                for (final c in _cards) {
                  c['known'] = null;
                }
              });
            },
            child: const Text('Restart'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/note/${widget.noteId}');
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/note/${widget.noteId}'),
        ),
        title: Text(
          widget.noteTitle ?? 'Flashcards',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_cards.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Regenerate',
              onPressed: _isGenerating ? null : _generate,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
              ? _EmptyState(onGenerate: _generate, isGenerating: _isGenerating)
              : _buildCardView(),
    );
  }

  Widget _buildCardView() {
    final card = _cards[_index];
    final progress = (_index + 1) / _cards.length;
    final known = _cards.where((c) => c['known'] == true).length;
    final unknown = _cards.where((c) => c['known'] == false).length;
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_index + 1} / ${_cards.length}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  Row(children: [
                    const Icon(Icons.check_circle, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text('$known', style: const TextStyle(fontSize: 13, color: Colors.green)),
                    const SizedBox(width: 12),
                    const Icon(Icons.cancel, size: 14, color: Colors.red),
                    const SizedBox(width: 4),
                    Text('$unknown', style: const TextStyle(fontSize: 13, color: Colors.red)),
                  ]),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: primary.withValues(alpha: 0.15),
                  color: primary,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _FlipCard(
              key: ValueKey(_index),
              question: card['question'] as String,
              answer: card['answer'] as String,
              showAnswer: _showAnswer,
              onTap: () => setState(() => _showAnswer = !_showAnswer),
            ),
          ),
        ),
        if (_showAnswer)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rate(false),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text("Don't Know", style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _rate(true),
                    icon: const Icon(Icons.check),
                    label: const Text('Got It!'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(() => _showAnswer = true),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Reveal Answer'),
              ),
            ),
          ),
      ],
    );
  }
}

class _FlipCard extends StatefulWidget {
  const _FlipCard({
    super.key,
    required this.question,
    required this.answer,
    required this.showAnswer,
    required this.onTap,
  });
  final String question;
  final String answer;
  final bool showAnswer;
  final VoidCallback onTap;

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_FlipCard old) {
    super.didUpdateWidget(old);
    if (widget.showAnswer != old.showAnswer) {
      if (widget.showAnswer) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final angle = _anim.value * pi;
          final showFront = angle < pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showFront
                ? _CardFace(widget.question, isQuestion: true)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _CardFace(widget.answer, isQuestion: false),
                  ),
          );
        },
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace(this.text, {required this.isQuestion});
  final String text;
  final bool isQuestion;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isQuestion ? surface : AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
        border: isQuestion
            ? Border.all(color: primary.withValues(alpha: 0.25))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isQuestion ? 'QUESTION' : 'ANSWER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: isQuestion ? primary : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: isQuestion ? onSurface : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Icon(
            isQuestion ? Icons.touch_app_outlined : Icons.lightbulb_outline,
            color: isQuestion
                ? onSurface.withValues(alpha: 0.2)
                : Colors.black38,
            size: 28,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onGenerate, required this.isGenerating});
  final VoidCallback onGenerate;
  final bool isGenerating;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.style_outlined, size: 48, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'No Flashcards Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate AI flashcards from your note to start studying',
              textAlign: TextAlign.center,
              style: TextStyle(color: onSurface.withValues(alpha: 0.5), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: isGenerating ? null : onGenerate,
              icon: isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(isGenerating ? 'Generating...' : 'Generate Flashcards'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge(this.icon, this.count, this.color);
  final IconData icon;
  final String count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
