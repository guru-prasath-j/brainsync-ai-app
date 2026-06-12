import 'package:flutter/material.dart';

class ActivityChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> dailyActivity;

  const ActivityChartWidget({Key? key, required this.dailyActivity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxCount = dailyActivity
        .map((d) => (d['count'] as int))
        .fold(0, (a, b) => a > b ? a : b);
    final effectiveMax = maxCount == 0 ? 1 : maxCount;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '7-Day Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: dailyActivity.map((day) {
                  final count = day['count'] as int;
                  final dateStr = day['date'] as String;
                  final label = dateStr.substring(5); // MM-DD
                  final heightRatio = count / effectiveMax;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (count > 0)
                            Text(
                              '$count',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.deepPurple),
                            ),
                          const SizedBox(height: 2),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            height: 70 * heightRatio,
                            decoration: BoxDecoration(
                              color: count > 0
                                  ? Colors.deepPurple
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: TextStyle(
                                fontSize: 9, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
