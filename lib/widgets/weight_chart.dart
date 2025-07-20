import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:goat_tracker/models/goat.dart';
import 'package:goat_tracker/models/weight_record.dart';
import 'package:intl/intl.dart';

class WeightChart extends StatelessWidget {
  final List<WeightRecord> weights;
  final Color lineColor;
  final Color gridColor;
  final int daysToShow;

  const WeightChart({
    super.key,
    required this.weights,
    this.lineColor = Colors.blue,
    this.gridColor = Colors.grey,
    this.daysToShow = 30,
  });

  List<WeightRecord> get _filteredWeights {
    if (weights.isEmpty) return [];
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToShow));
    return weights
        .where((w) => w.date.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Widget build(BuildContext context) {
    final filteredWeights = _filteredWeights;
    if (filteredWeights.isEmpty) {
      return const Center(
        child: Text('No weight records available'),
      );
    }

    final maxY = filteredWeights
        .map((w) => w.weight)
        .reduce((max, w) => max > w ? max : w);
    final minY = filteredWeights
        .map((w) => w.weight)
        .reduce((min, w) => min < w ? min : w);
    final yMargin = (maxY - minY) * 0.1;

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: gridColor.withOpacity(0.2),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: gridColor.withOpacity(0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: (daysToShow / 5).floor().toDouble(),
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= filteredWeights.length) {
                    return const SizedBox.shrink();
                  }
                  final date = filteredWeights[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MMM d').format(date),
                      style: TextStyle(
                        color: gridColor,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                interval: ((maxY - minY) / 5).roundToDouble(),
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      color: gridColor,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: gridColor.withOpacity(0.2),
            ),
          ),
          minX: 0,
          maxX: (filteredWeights.length - 1).toDouble(),
          minY: minY - yMargin,
          maxY: maxY + yMargin,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                filteredWeights.length,
                (i) => FlSpot(
                  i.toDouble(),
                  filteredWeights[i].weight,
                ),
              ),
              isCurved: true,
              color: lineColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 4,
                  color: lineColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withOpacity(0.15),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  final weight = filteredWeights[spot.x.toInt()].weight;
                  final date = filteredWeights[spot.x.toInt()].date;
                  return LineTooltipItem(
                    '${weight.toStringAsFixed(1)} kg\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: DateFormat('MMM d, yyyy').format(date),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
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
    );
  }
}
