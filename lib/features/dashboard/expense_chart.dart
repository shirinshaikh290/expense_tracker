// lib/presentation/widgets/expense_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseChart extends StatelessWidget {
  final Map<String, double> categoryData; // e.g. {'Food': 1200, 'Travel': 800}

  const ExpenseChart({super.key, required this.categoryData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = categoryData.values.fold<double>(0.0, (a, b) => a + b);

    if (categoryData.isEmpty || total == 0) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No expenses to show',
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
          ),
        ),
      );
    }

    final colors = List.generate(
      categoryData.length,
          (i) => Colors.primaries[i % Colors.primaries.length],
    );

    final sections = <PieChartSectionData>[];
    int i = 0;
    for (final entry in categoryData.entries) {
      final value = entry.value;
      final percent = (value / total) * 100;
      sections.add(
        PieChartSectionData(
          color: colors[i],
          value: value,
          title: percent >= 6 ? '${percent.toStringAsFixed(0)}%' : '',
          radius: 60,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
      i++;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Expenses by Category',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: categoryData.keys.map((k) {
                final idx = categoryData.keys.toList().indexOf(k);
                final color = colors[idx];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                    const SizedBox(width: 6),
                    Text(k, style: const TextStyle(fontSize: 13)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
