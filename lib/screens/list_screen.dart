// lib/screens/list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/providers/selected_month_provider.dart';
import 'package:expense_tracker/providers/date_range_provider.dart';
import 'package:expense_tracker/widgets/filter_picker_button.dart';

final expenseProvider =
    ChangeNotifierProvider<ExpenseProvider>((ref) => ExpenseProvider());

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(expenseProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final dateRange = ref.watch(dateRangeProvider);

    // 1) Filter the raw list by dateRange → selectedMonth → all
    final allExpenses = provider.expenses;
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

    // 2) Show loading if needed
    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 3) Build AppBar title dynamically
    String appBarTitle;
    if (dateRange != null) {
      final df = DateFormat('MMM d, y');
      appBarTitle =
          'Expenses (${df.format(dateRange.start)} – ${df.format(dateRange.end)})';
    } else if (selectedMonth != null) {
      final monthName = DateFormat('MMMM y').format(selectedMonth);
      appBarTitle = 'Expenses ($monthName)';
    } else {
      appBarTitle = 'All Expenses';
    }

    // 4) If empty after filtering
    if (filteredExpenses.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Text(appBarTitle),
          actions: const [
            FilterPickerButton(),
            _ChartMenuButton(),
          ],
        ),
        body: Center(
          child: Card(
            color: Theme.of(context).colorScheme.surfaceVariant,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                selectedMonth == null && dateRange == null
                    ? 'No expenses yet.\nTap + to add.'
                    : 'No expenses in this filter.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ),
        floatingActionButton: const _AddButton(),
      );
    }

    // 5) Otherwise, show the filtered list
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: const [
          FilterPickerButton(),
          _ChartMenuButton(),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: filteredExpenses.length,
        itemBuilder: (context, index) {
          final e = filteredExpenses[index];
          final key = e.key as int;
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                e.description,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                '${e.category} · ${e.date.toLocal().toIso8601String().split('T')[0]}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: Text(
                '\$${e.amount.toStringAsFixed(2)}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              leading: IconButton(
                icon: Icon(Icons.delete,
                    color: Theme.of(context).colorScheme.error),
                onPressed: () {
                  ref.read(expenseProvider).deleteExpense(e);
                },
              ),
              onTap: () => context.push('/edit/$key'),
            ),
          );
        },
      ),
      floatingActionButton: const _AddButton(),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton();
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.push('/add'),
      child: const Icon(Icons.add),
    );
  }
}

/// A small popup menu to navigate to each chart screen.
class _ChartMenuButton extends StatelessWidget {
  const _ChartMenuButton();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'bar') {
          context.push('/charts/bar');
        } else if (value == 'line') {
          context.push('/charts/line');
        } else if (value == 'pie') {
          context.push('/charts/pie');
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'bar', child: Text('Bar Chart')),
        PopupMenuItem(value: 'line', child: Text('Line Chart')),
        PopupMenuItem(value: 'pie', child: Text('Pie Chart')),
      ],
      icon: const Icon(Icons.show_chart),
      tooltip: 'View Charts',
    );
  }
}
