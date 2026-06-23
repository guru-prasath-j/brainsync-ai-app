import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'BrainSync AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.deepPurple,
              radius: 14,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
            onPressed: () => context.go('/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(context),
            const SizedBox(height: 24),
            Text(
              'Quick Actions',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildActionsGrid(context),
            const SizedBox(height: 24),
            Text(
              'Study Tools',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildStudyTools(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back! 👋',
            style: TextStyle(
                color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ready to study smarter?',
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => context.go('/upload'),
            child: const Text('Upload Notes'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsGrid(BuildContext context) {
    final actions = [
      _ActionItem(Icons.upload_file, 'Upload', '/upload', Colors.blue),
      _ActionItem(Icons.list_alt, 'My Notes', '/notes', Colors.teal),
      _ActionItem(Icons.bar_chart, 'Dashboard', '/dashboard', Colors.deepPurple),
      _ActionItem(Icons.person_outline, 'Profile', '/profile', Colors.orange),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: actions
          .map((a) => _buildActionTile(context, a))
          .toList(),
    );
  }

  Widget _buildActionTile(BuildContext context, _ActionItem item) {
    return GestureDetector(
      onTap: () => context.go(item.route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(item.label,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildStudyTools(BuildContext context) {
    final tools = [
      _ToolItem(Icons.style_outlined, 'Flashcards', '/flashcards',
          'Memorize with spaced repetition', Colors.orange),
      _ToolItem(Icons.quiz_outlined, 'Quiz Mode', '/quiz',
          'Test your knowledge', Colors.green),
      _ToolItem(Icons.chat_bubble_outline, 'AI Chat', '/chat',
          'Ask questions about your notes', Colors.blue),
      _ToolItem(Icons.summarize_outlined, 'Summaries', '/summaries',
          'AI-generated note summaries', Colors.purple),
    ];

    return Column(
      children: tools.map((t) => _buildToolCard(context, t)).toList(),
    );
  }

  Widget _buildToolCard(BuildContext context, _ToolItem tool) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: tool.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(tool.icon, color: tool.color),
        ),
        title:
            Text(tool.label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(tool.subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => context.go(tool.route),
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
