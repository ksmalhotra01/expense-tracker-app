// lib/screens/chart_screens/pie_chart_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/providers/selected_month_provider.dart';
import 'package:expense_tracker/providers/date_range_provider.dart';
import 'package:expense_tracker/widgets/filter_picker_button.dart';

class PieChartScreen extends ConsumerWidget {
  const PieChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allExpenses = ref.watch(expenseProvider).expenses;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final dateRange = ref.watch(dateRangeProvider);

    // 1) Filter by dateRange → selectedMonth → none
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

    // 2) Sum totals per category
    final categoryTotals = <String, double>{};
    double grandTotal = 0;
    for (final e in filteredExpenses) {
      categoryTotals[e.category] =
          (categoryTotals[e.category] ?? 0) + e.amount;
      grandTotal += e.amount;
    }

    // 3) Build AppBar title
    String appBarTitle;
    if (dateRange != null) {
      final df = DateFormat('MMM d, y');
      appBarTitle =
          'Pie (${df.format(dateRange.start)} – ${df.format(dateRange.end)})';
    } else if (selectedMonth != null) {
      final monthName = DateFormat('MMMM y').format(selectedMonth);
      appBarTitle = 'Pie ($monthName)';
    } else {
      appBarTitle = 'Category Distribution';
    }

    // 4) If no data:
    if (categoryTotals.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          actions: const [ FilterPickerButton() ],
        ),
        body: const Center(child: Text('No data to display')),
      );
    }

    final colors = <Color>[
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
    ];

    final sections = <PieChartSectionData>[];
    final legendItems = <Widget>[];
    var i = 0;

    categoryTotals.forEach((category, total) {
      final percent = (total / grandTotal) * 100;
      final sliceColor = colors[i % colors.length];

      sections.add(
        PieChartSectionData(
          value: total,
          title: '${percent.toStringAsFixed(1)}%',
          color: sliceColor,
          radius: 60,
          titleStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          badgeWidget: _Badge(text: category, color: sliceColor),
          badgePositionPercentageOffset: 1.2,
        ),
      );

      legendItems.add(_LegendItem(color: sliceColor, text: category));
      i++;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: const [ FilterPickerButton() ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 4,
                pieTouchData: PieTouchData(enabled: true),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: legendItems,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      elevation: 2,
      backgroundColor: color.withOpacity(0.9),
      label: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}
