import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../models/summary_model.dart';
import '../services/summary_service.dart';
import '../widgets/aurora_scaffold.dart';

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
          const SnackBar(content: Text('Summary generated!')),
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
    return AuroraScaffold(
      appBar: AppBar(
        title: Text(widget.noteTitle, style: const TextStyle(fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/note/${widget.noteId}'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generating ? null : _generateSummary,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.black,
        icon: _generating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(_summary == null ? 'Generate Summary' : 'Regenerate'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _summary == null
              ? _buildEmptyState(context)
              : _buildSummaryContent(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.summarize_outlined, size: 64, color: AppTheme.primary),
          const SizedBox(height: 16),
          Text(
            'No summary yet',
            style: TextStyle(color: onSurface, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to generate\nan AI-powered summary',
            textAlign: TextAlign.center,
            style: TextStyle(color: onSurface.withValues(alpha: 0.6), fontSize: 14),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryContent(BuildContext context) {
    final summary = _summary!;
    return RefreshIndicator(
      onRefresh: _loadSummary,
      color: AppTheme.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            icon: Icons.flash_on,
            color: AppTheme.accent,
            title: 'TL;DR',
            child: Text(
              summary.tldr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (summary.keyPoints.isNotEmpty)
            _SectionCard(
              icon: Icons.format_list_bulleted,
              color: AppTheme.secondary,
              title: 'Key Points',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: summary.keyPoints
                    .map((point) => _KeyPointRow(point: point))
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),
          if (summary.concepts.isNotEmpty)
            _SectionCard(
              icon: Icons.label_outline,
              color: AppTheme.primary,
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
          Text(
            'Generated ${summary.formattedDate} • ${summary.modelUsed}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 80),
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
    final surface = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).colorScheme.outlineVariant;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: AppTheme.secondary, fontSize: 16)),
          Expanded(
            child: Text(
              point,
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.85),
                fontSize: 14,
                height: 1.5,
              ),
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
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.35)),
      ),
      child: Text(label, style: TextStyle(color: AppTheme.primary, fontSize: 13)),
    );
  }
}
