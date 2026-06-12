import 'package:flutter/material.dart';

class StatCard extends StatefulWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  }) : super(key: key);

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _countAnimation = Tween<double>(begin: 0, end: widget.value.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 20),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _countAnimation,
              builder: (_, __) => Text(
                _countAnimation.value.toInt().toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                widget.subtitle!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[400]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
