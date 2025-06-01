// lib/widgets/filter_picker_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:expense_tracker/providers/selected_month_provider.dart';
import 'package:expense_tracker/providers/date_range_provider.dart';

class FilterPickerButton extends ConsumerWidget {
  const FilterPickerButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final dateRange = ref.watch(dateRangeProvider);
    final anyFilter = (selectedMonth != null) || (dateRange != null);

    return IconButton(
      tooltip: anyFilter
          ? 'Clear filter'
          : 'Filter by month or date range',
      icon: Icon(anyFilter
          ? Icons.clear
          : Icons.filter_alt_outlined),
      onPressed: () async {
        if (anyFilter) {
          // Clear both filters if either is active:
          ref.read(selectedMonthProvider.notifier).state = null;
          ref.read(dateRangeProvider.notifier).state = null;
          return;
        }

        // Ask “Month” vs. “Date Range”
        final choice = await showDialog<String>(
          context: context,
          builder: (_) => SimpleDialog(
            title: const Text('Choose filter type'),
            children: [
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, 'month'),
                child: const Text('Filter by Month'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, 'range'),
                child: const Text('Filter by Date Range'),
              ),
            ],
          ),
        );

        if (choice == 'month') {
          // --- BEGIN custom Month + Year dialog ---
          final now = DateTime.now();
          int selectedMonthIndex = now.month - 1; // 0 = Jan, 11 = Dec
          String yearText = now.year.toString();

          final pickedMonth = await showDialog<DateTime>(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Select Month & Year'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Month dropdown
                        DropdownButton<int>(
                          value: selectedMonthIndex,
                          items: List.generate(12, (index) {
                            final monthName =
                                DateFormat.MMMM().format(DateTime(0, index + 1));
                            return DropdownMenuItem(
                              value: index,
                              child: Text(monthName),
                            );
                          }),
                          onChanged: (newIdx) {
                            if (newIdx != null) {
                              setState(() {
                                selectedMonthIndex = newIdx;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 12),

                        // Year text field
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Year (YYYY)',
                            hintText: 'e.g. 2025',
                          ),
                          onChanged: (val) {
                            yearText = val;
                          },
                          controller: TextEditingController(text: yearText),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, null),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () {
                          final enteredYear = int.tryParse(yearText);
                          if (enteredYear != null && enteredYear >= 1900) {
                            // Build a DateTime on first day of that month:
                            Navigator.pop(
                              context,
                              DateTime(enteredYear, selectedMonthIndex + 1),
                            );
                          } else {
                            // Invalid year → show a simple error SnackBar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid 4-digit year.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          );
          // --- END custom Month + Year dialog ---

          if (pickedMonth != null) {
            // Corrected provider names below:
            ref.read(selectedMonthProvider.notifier).state =
                DateTime(pickedMonth.year, pickedMonth.month);
            ref.read(dateRangeProvider.notifier).state = null;
          }
        }
        else if (choice == 'range') {
          final now = DateTime.now();
          final pickedRange = await showDateRangePicker(
            context: context,
            firstDate: DateTime(now.year - 5),
            lastDate: now,
            initialDateRange: DateTimeRange(
              start: now.subtract(const Duration(days: 7)),
              end: now,
            ),
          );
          if (pickedRange != null) {
            ref.read(dateRangeProvider.notifier).state = pickedRange;
            ref.read(selectedMonthProvider.notifier).state = null;
          }
        }
      },
    );
  }
}
