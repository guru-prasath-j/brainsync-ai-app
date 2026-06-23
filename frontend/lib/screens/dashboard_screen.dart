import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../widgets/aurora_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/activity_chart_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.get('/api/progress/dashboard');
      setState(() { _stats = data; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuroraScaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: GlassCard(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Color(0xFFF87171)),
                        const SizedBox(height: 16),
                        Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadStats, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  color: AppTheme.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStreakBanner(),
                        const SizedBox(height: 16),
                        _buildStatsGrid(),
                        const SizedBox(height: 16),
                        ActivityChartWidget(
                          dailyActivity: List<Map<String, dynamic>>.from(
                              _stats!['daily_activity'] ?? []),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStreakBanner() {
    final streak = _stats!['streak_days'] as int? ?? 0;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return GlassCard(
      color: AppTheme.primary.withValues(alpha: 0.12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak day${streak == 1 ? '' : 's'} streak',
                style: TextStyle(color: onSurface, fontSize: 20, fontWeight: FontWeight.w700),
              ),
              Text(
                'Keep it up! Upload notes daily.',
                style: TextStyle(color: onSurface.withValues(alpha: 0.6), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final s = _stats!;
    final cards = [
      StatCard(
        label: 'Notes',
        value: s['total_notes'] as int? ?? 0,
        icon: Icons.description_outlined,
        color: Theme.of(context).colorScheme.onSurface,
        subtitle: '${s['processed_notes'] ?? 0} processed',
      ),
      StatCard(
        label: 'Flashcards',
        value: s['total_flashcards'] as int? ?? 0,
        icon: Icons.style_outlined,
        color: AppTheme.accent,
      ),
      StatCard(
        label: 'Quizzes',
        value: s['total_quizzes'] as int? ?? 0,
        icon: Icons.quiz_outlined,
        color: AppTheme.secondary,
        subtitle: 'Avg score: ${s['avg_quiz_score'] ?? 0}%',
      ),
      StatCard(
        label: 'AI Chats',
        value: s['total_messages'] as int? ?? 0,
        icon: Icons.chat_bubble_outline,
        color: AppTheme.primary,
      ),

    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: cards,
    );
  }
}
