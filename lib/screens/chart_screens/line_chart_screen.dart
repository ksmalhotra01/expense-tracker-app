// lib/screens/chart_screens/line_chart_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/providers/selected_month_provider.dart';
import 'package:expense_tracker/providers/date_range_provider.dart';
import 'package:expense_tracker/widgets/filter_picker_button.dart';

class LineChartScreen extends ConsumerWidget {
  const LineChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allExpenses = ref.watch(expenseProvider).expenses;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final dateRange = ref.watch(dateRangeProvider);

    final today = DateTime.now();
    final dateFormatter = DateFormat('MM/dd');
    final Map<String, double> dailyTotals = {};

    // 1) Build dailyTotals according to filter priority:
    if (dateRange != null) {
      // a) Date‐range filter active:
      for (final e in allExpenses) {
        if (!e.date.isBefore(dateRange.start) &&
            !e.date.isAfter(dateRange.end)) {
          final key = dateFormatter.format(e.date);
          dailyTotals[key] = (dailyTotals[key] ?? 0) + e.amount;
        }
      }
    } else if (selectedMonth != null) {
      // b) Monthly filter active:
      for (final e in allExpenses) {
        if (e.date.year == selectedMonth.year &&
            e.date.month == selectedMonth.month) {
          final key = dateFormatter.format(e.date);
          dailyTotals[key] = (dailyTotals[key] ?? 0) + e.amount;
        }
      }
    } else {
      // c) Default “last 30 days”:
      for (final e in allExpenses) {
        final diff = today.difference(e.date).inDays;
        if (diff >= 0 && diff < 30) {
          final key = dateFormatter.format(e.date);
          dailyTotals[key] = (dailyTotals[key] ?? 0) + e.amount;
        }
      }
    }

    // 2) Build AppBar title:
    String appBarTitle;
    if (dateRange != null) {
      final df = DateFormat('MMM d, y');
      appBarTitle =
          'Spending (${df.format(dateRange.start)} – ${df.format(dateRange.end)})';
    } else if (selectedMonth != null) {
      final monthName = DateFormat('MMMM y').format(selectedMonth);
      appBarTitle = 'Spending ($monthName)';
    } else {
      appBarTitle = 'Spending Over Time (30d)';
    }

    // 3) If no data to show:
    if (dailyTotals.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          actions: const [ FilterPickerButton() ],
        ),
        body: const Center(child: Text('No data to display')),
      );
    }

    // 4) Sort keys, build spots:
    final sortedKeys = dailyTotals.keys.toList()
      ..sort((a, b) {
        final da = dateFormatter.parse(a);
        final db = dateFormatter.parse(b);
        return da.compareTo(db);
      });

    final spots = <FlSpot>[];
    for (var i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      spots.add(FlSpot(i.toDouble(), dailyTotals[key]!));
    }

    final maxY = dailyTotals.values.reduce((a, b) => a > b ? a : b) * 1.2;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: const [ FilterPickerButton() ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(0.15),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(
              border: Border(
                bottom:
                    BorderSide(width: 1, color: Theme.of(context).dividerColor),
                left:
                    BorderSide(width: 1, color: Theme.of(context).dividerColor),
                top: const BorderSide(width: 0),
                right: const BorderSide(width: 0),
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: maxY / 4,
                  getTitlesWidget: (val, _) => Text(
                    '\$${val.toInt()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (val, _) {
                    final idx = val.toInt();
                    if (idx < 0 || idx >= sortedKeys.length) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        sortedKeys[idx],
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
            minY: 0,
            maxY: maxY,
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) {
                  return spots.map((lineSpot) {
                    final day = sortedKeys[lineSpot.x.toInt()];
                    final amt = lineSpot.y;
                    return LineTooltipItem(
                      '$day\n\$${amt.toStringAsFixed(2)}',
                      TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 3,
                color: Theme.of(context).colorScheme.primary,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.4),
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
