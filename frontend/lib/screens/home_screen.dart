import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../widgets/aurora_scaffold.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuroraScaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.psychology_rounded, color: AppTheme.primary, size: 22),
            const SizedBox(width: 8),
            const Text('BrainSync AI'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
            tooltip: 'Settings',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5)),
                ),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(context),
            const SizedBox(height: 28),
            _buildSectionLabel(context, 'Quick Actions'),
            const SizedBox(height: 12),
            _buildActionsGrid(context),
            const SizedBox(height: 28),
            _buildSectionLabel(context, 'Study Tools'),
            const SizedBox(height: 12),
            _buildStudyTools(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'AI Active',
                  style: TextStyle(
                    color: AppTheme.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome back! 👋',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ready to study\nsmarter today?',
            style: TextStyle(
              color: onSurface,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.upload_file_outlined, size: 18),
              label: const Text('Upload Notes'),
              onPressed: () => context.go('/upload'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsGrid(BuildContext context) {
    const actions = [
      _ActionItem(Icons.upload_file_outlined, 'Upload',    '/upload',    AppTheme.primary),
      _ActionItem(Icons.list_alt_outlined,    'My Notes',  '/notes',     AppTheme.secondary),
      _ActionItem(Icons.bar_chart_outlined,   'Dashboard', '/dashboard', AppTheme.accent),
      _ActionItem(Icons.person_outline,       'Profile',   '/profile',   Color(0xFF00CFD5)),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: actions.map((a) => _buildActionTile(context, a)).toList(),
    );
  }

  Widget _buildActionTile(BuildContext context, _ActionItem item) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: () => context.go(item.route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color, size: 26),
          const SizedBox(height: 6),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              color: onSurface,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStudyTools(BuildContext context) {
    const tools = [
      _ToolItem(Icons.style_outlined,      'Flashcards', '/flashcards', 'Memorize with spaced repetition', AppTheme.accent),
      _ToolItem(Icons.quiz_outlined,       'Quiz Mode',  '/quiz',       'Test your knowledge',             AppTheme.secondary),
      _ToolItem(Icons.chat_bubble_outline, 'AI Chat',    '/chat',       'Ask questions about your notes',  Color(0xFF00CFD5)),
      _ToolItem(Icons.summarize_outlined,  'Summaries',  '/summaries',  'AI-generated note summaries',     AppTheme.primary),
    ];

    return Column(
      children: tools
          .map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildToolCard(context, t),
              ))
          .toList(),
    );
  }

  Widget _buildToolCard(BuildContext context, _ToolItem tool) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => context.go(tool.route),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tool.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: tool.color.withValues(alpha: 0.3)),
            ),
            child: Icon(tool.icon, color: tool.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tool.label,
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tool.subtitle,
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: onSurface.withValues(alpha: 0.35),
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  const _ActionItem(this.icon, this.label, this.route, this.color);
}

class _ToolItem {
  final IconData icon;
  final String label;
  final String route;
  final String subtitle;
  final Color color;
  const _ToolItem(this.icon, this.label, this.route, this.subtitle, this.color);
}
