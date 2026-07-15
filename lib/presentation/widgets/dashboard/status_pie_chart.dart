import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatusPieChart extends StatelessWidget {
  const StatusPieChart({
    super.key,
    required this.title,
    required this.activeCount,
    required this.inactiveCount,
  });

  final String title;
  final int activeCount;
  final int inactiveCount;

  @override
  Widget build(BuildContext context) {
    final total = activeCount + inactiveCount;
    final hasData = total > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (!hasData)
              const SizedBox(
                height: 160,
                child: Center(child: Text('Sin datos')),
              )
            else
              SizedBox(
                height: 160,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 1.5,
                    centerSpaceRadius: 26,
                    sections: [
                      PieChartSectionData(
                        value: activeCount.toDouble(),
                        color: Colors.green,
                        title: '$activeCount',
                        radius: 44,
                      ),
                      PieChartSectionData(
                        value: inactiveCount.toDouble(),
                        color: Colors.red,
                        title: '$inactiveCount',
                        radius: 44,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 10),
            const _LegendRow(label: 'Activo', color: Colors.green),
            const SizedBox(height: 4),
            const _LegendRow(label: 'Inactivo', color: Colors.red),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
