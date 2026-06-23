import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/summary_model.dart';
import '../services/summary_service.dart';

class SummaryScreen extends StatefulWidget {
  final int noteId;
  final String noteTitle;

  const SummaryScreen({
    super.key,
    required this.noteId,
    required this.noteTitle,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final SummaryService _service = SummaryService();

  SummaryModel? _summary;
  bool _loading = true;
  bool _generating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() { _loading = true; _error = null; });
    try {
      final summary = await _service.getSummary(widget.noteId);
      setState(() { _summary = summary; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _generateSummary() async {
    setState(() { _generating = true; _error = null; });
    try {
      final summary = await _service.generateSummary(widget.noteId);
      setState(() { _summary = summary; _generating = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Summary generated!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() { _error = e.toString(); _generating = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF13131A),
        title: Text(widget.noteTitle, style: const TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.go('/note/${widget.noteId}'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generating ? null : _generateSummary,
        backgroundColor: const Color(0xFF7C3AED),
        icon: _generating
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.auto_awesome, color: Colors.white),
        label: Text(
          _summary == null ? 'Generate Summary' : 'Regenerate',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
          : _summary == null
              ? _buildEmptyState()
              : _buildSummaryContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.summarize_outlined, size: 64, color: Color(0xFF7C3AED)),
          const SizedBox(height: 16),
          const Text(
            'No summary yet',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to generate\nan AI-powered summary',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryContent() {
    final summary = _summary!;
    return RefreshIndicator(
      onRefresh: _loadSummary,
      color: const Color(0xFF7C3AED),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // TL;DR Card
          _SectionCard(
            icon: Icons.flash_on,
            color: const Color(0xFFEAB308),
            title: 'TL;DR',
            child: Text(
              summary.tldr,
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6),
            ),
          ),
          const SizedBox(height: 16),

          // Key Points Card
          if (summary.keyPoints.isNotEmpty)
            _SectionCard(
              icon: Icons.format_list_bulleted,
              color: const Color(0xFF22C55E),
              title: 'Key Points',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: summary.keyPoints
                    .map((point) => _KeyPointRow(point: point))
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),

          // Concepts Card
          if (summary.concepts.isNotEmpty)
            _SectionCard(
              icon: Icons.label_outline,
              color: const Color(0xFF7C3AED),
              title: 'Key Concepts',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: summary.concepts
                    .map((c) => _ConceptChip(label: c))
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),

          // Footer
          Text(
            'Generated ${summary.formattedDate} • ${summary.modelUsed}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 80), // FAB clearance
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13131A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _KeyPointRow extends StatelessWidget {
  final String point;
  const _KeyPointRow({required this.point});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF22C55E), fontSize: 16)),
          Expanded(
            child: Text(
              point,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConceptChip extends StatelessWidget {
  final String label;
  const _ConceptChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.4)),
      ),
      child: Text(label, style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 13)),
    );
  }
}
