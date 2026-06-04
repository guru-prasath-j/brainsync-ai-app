import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../models/summary_model.dart';
import '../services/summary_service.dart';

class SummaryScreen extends StatefulWidget {
  final NoteModel note;

  const SummaryScreen({Key? key, required this.note}) : super(key: key);

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final SummaryService _summaryService = SummaryService();

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
      final summary = await _summaryService.getSummary(widget.note.id);
      setState(() => _summary = summary);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _generateSummary() async {
    setState(() { _generating = true; _error = null; });
    try {
      final summary = await _summaryService.generateSummary(widget.note.id);
      setState(() => _summary = summary);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Summary generated!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note.title),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _summary == null
              ? _buildEmptyState()
              : _buildSummaryContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generating ? null : _generateSummary,
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        icon: _generating
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.auto_awesome),
        label: Text(_generating ? 'Generating...' : (_summary == null ? 'Generate' : 'Regenerate')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.summarize_outlined, size: 72, color: Colors.grey),
          const SizedBox(height: 16),
          Text('No summary yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to generate an AI summary.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryContent() {
    final s = _summary!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: const [
                    Icon(Icons.flash_on, color: Color(0xFF6C63FF), size: 20),
                    SizedBox(width: 6),
                    Text('TL;DR', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C63FF), fontSize: 14)),
                  ]),
                  const SizedBox(height: 8),
                  Text(s.tldr, style: const TextStyle(fontSize: 15, height: 1.5)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Key Points', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...s.keyPoints.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: const BoxDecoration(color: Color(0xFF6C63FF), shape: BoxShape.circle),
                  child: Center(child: Text('${entry.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 14, height: 1.5))),
              ],
            ),
          )),
          const SizedBox(height: 20),
          const Text('Key Concepts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: s.concepts.map((c) => Chip(
              label: Text(c),
              backgroundColor: const Color(0xFF6C63FF).withOpacity(0.15),
              labelStyle: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.w500),
            )).toList(),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
