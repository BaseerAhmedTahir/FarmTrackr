import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../services/supabase_service.dart';

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool? trend;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.surfaceContainerHighest;
    final foregroundColor = colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: foregroundColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: 4),
            Icon(
              trend! ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: trend! ? Colors.green : Colors.red,
            ),
          ],
        ],
      ),
    );
  }
}

class WeightChart extends StatelessWidget {
  final String goatId;

  const WeightChart({super.key, required this.goatId});

  String _formatDate(DateTime date) => DateFormat.MMMd().format(date);
  String _formatWeight(double weight) => weight.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder(
      stream: Svc.weightStream(goatId),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: colorScheme.primary,
            ),
          );
        }

        final weights = snapshot.data!;
        if (weights.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.scale_outlined,
                  size: 48,
                  color: colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'No weight records available',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        // Convert data to chart points with dates
        final weightData = weights.map((Map<String, dynamic> w) => (
          date: DateTime.parse(w['date'] as String),
          weight: (w['weight'] as num).toDouble(),
        )).toList();
        
        final spots = weightData.asMap().entries.map((e) {
          return FlSpot(e.key.toDouble(), e.value.weight);
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Statistics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatCard(
                    label: 'Latest',
                    value: '${_formatWeight(weightData.last.weight)} kg',
                    icon: Icons.scale,
                    trend: weightData.length > 1 
                      ? weightData.last.weight > weightData[weightData.length - 2].weight
                      : null,
                  ),
                  _StatCard(
                    label: 'Average',
                    value: '${_formatWeight(weightData.map((w) => w.weight).reduce((a, b) => a + b) / weightData.length)} kg',
                    icon: Icons.analytics,
                  ),
                  if (weightData.length > 1)
                    _StatCard(
                      label: 'Growth',
                      value: '${_formatWeight(weightData.last.weight - weightData.first.weight)} kg',
                      icon: Icons.trending_up,
                      trend: weightData.last.weight > weightData.first.weight,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Chart
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 5,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: colorScheme.outlineVariant,
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: colorScheme.outlineVariant,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value < 0 || value >= weightData.length) {
                              return const Text('');
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Transform.rotate(
                                angle: -0.5,
                                child: Text(
                                  _formatDate(weightData[value.toInt()].date),
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        axisNameWidget: Text(
                          'Weight (kg)',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 5,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: colorScheme.outline),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: colorScheme.primary,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                              radius: 6,
                              color: colorScheme.surface,
                              strokeWidth: 2,
                              strokeColor: colorScheme.primary,
                            ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: colorScheme.primaryContainer,
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (spots) {
                          return spots.map((spot) {
                            final date = weightData[spot.x.toInt()].date;
                            final weight = spot.y;
                            return LineTooltipItem(
                              '${_formatWeight(weight)} kg\n',
                              TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: _formatDate(date),
                                  style: TextStyle(
                                    color: colorScheme.onPrimaryContainer,
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
