// lib/screens/chart_screens/bar_chart_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/providers/selected_month_provider.dart';
import 'package:expense_tracker/providers/date_range_provider.dart';
import 'package:expense_tracker/widgets/filter_picker_button.dart';

class BarChartScreen extends ConsumerWidget {
  const BarChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allExpenses = ref.watch(expenseProvider).expenses;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final dateRange = ref.watch(dateRangeProvider);

    // 1) Filter priority: dateRange → selectedMonth → no filter
    final filteredExpenses = (dateRange != null)
        ? allExpenses.where((e) {
            return !e.date.isBefore(dateRange.start) &&
                   !e.date.isAfter(dateRange.end);
          }).toList()
        : (selectedMonth != null
            ? allExpenses.where((e) {
                return e.date.year == selectedMonth.year &&
                       e.date.month == selectedMonth.month;
              }).toList()
            : allExpenses);

    // 2) Sum amounts by category
    final categoryTotals = <String, double>{};
    for (final e in filteredExpenses) {
      categoryTotals[e.category] =
          (categoryTotals[e.category] ?? 0) + e.amount;
    }

    // 3) Build a dynamic AppBar title
    String appBarTitle;
    if (dateRange != null) {
      final df = DateFormat('MMM d, y');
      appBarTitle = 'Spending (${df.format(dateRange.start)} – ${df.format(dateRange.end)})';
    } else if (selectedMonth != null) {
      final monthName = DateFormat('MMMM y').format(selectedMonth);
      appBarTitle = 'Spending ($monthName)';
    } else {
      appBarTitle = 'Spending by Category';
    }

    // 4) Show “No data” if nothing
    if (categoryTotals.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          actions: const [ FilterPickerButton() ],
        ),
        body: const Center(child: Text('No data to display')),
      );
    }

    final categories = categoryTotals.keys.toList();
    final maxValue =
        categoryTotals.values.reduce((a, b) => a > b ? a : b) * 1.2;

    // 5) Build bar groups with gradient + background rod
    final barGroups = <BarChartGroupData>[];
    for (var i = 0; i < categories.length; i++) {
      final cat = categories[i];
      final total = categoryTotals[cat]!;

      final gradient = LinearGradient(
        colors: [
          Theme.of(context).colorScheme.primary.withOpacity(0.8),
          Theme.of(context).colorScheme.primary,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

      barGroups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: total,
              width: 24,
              borderRadius: BorderRadius.circular(6),
              gradient: gradient,
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxValue,
                color: Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(0.1),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: const [ FilterPickerButton() ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxValue,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, _, rod, __) {
                  final category = categories[group.x.toInt()];
                  return BarTooltipItem(
                    '$category\n\$${rod.toY.toStringAsFixed(2)}',
                    TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48,
                  interval: maxValue / 4,
                  getTitlesWidget: (value, _) => Text(
                    '\$${value.toInt()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index < 0 || index >= categories.length) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        categories[index],
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.15),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: barGroups,
          ),
        ),
      ),
    );
  }
}
