import 'package:flutter/material.dart';
import 'package:goat_tracker/models/metric.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final List<Metric> metrics;

  const SummaryCard({
    super.key,
    required this.title,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...metrics.map((metric) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    metric.label,
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    metric.value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
