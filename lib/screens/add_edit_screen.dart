// lib/screens/add_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';

class AddEditScreen extends ConsumerStatefulWidget {
  final int? expenseKey;
  const AddEditScreen({super.key, this.expenseKey});

  @override
  ConsumerState<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends ConsumerState<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.expenseKey != null) {
      final existing =
          ref.read(expenseProvider).getExpenseByKey(widget.expenseKey!);
      if (existing != null) {
        _descriptionController =
            TextEditingController(text: existing.description);
        _amountController =
            TextEditingController(text: existing.amount.toStringAsFixed(2));
        _selectedCategory = existing.category;
        _selectedDate = existing.date;
      } else {
        _descriptionController = TextEditingController();
        _amountController = TextEditingController();
        _selectedCategory = null;
      }
    } else {
      _descriptionController = TextEditingController();
      _amountController = TextEditingController();
      _selectedCategory = null;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final chosen = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (chosen != null) {
      setState(() {
        _selectedDate = chosen;
      });
    }
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) return;
    final description = _descriptionController.text.trim();
    final amount = double.parse(_amountController.text.trim());
    final category = _selectedCategory!;
    final date = _selectedDate;
    final provider = ref.read(expenseProvider);

    if (widget.expenseKey == null) {
      final newExpense = Expense(
        description: description,
        amount: amount,
        date: date,
        category: category,
      );
      provider.addExpense(newExpense);
    } else {
      final existing = provider.getExpenseByKey(widget.expenseKey!);
      if (existing != null) {
        existing.description = description;
        existing.amount = amount;
        existing.date = date;
        existing.category = category;
        provider.updateExpense(existing);
      }
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expenseKey != null;
    final title = isEditing ? 'Edit Expense' : 'Add Expense';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Amount Field
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter an amount';
                      }
                      final parsed = double.tryParse(val.trim());
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid, positive number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Food', child: Text('Food')),
                      DropdownMenuItem(
                          value: 'Transport', child: Text('Transport')),
                      DropdownMenuItem(
                          value: 'Shopping', child: Text('Shopping')),
                      DropdownMenuItem(
                          value: 'Utilities', child: Text('Utilities')),
                      DropdownMenuItem(value: 'Misc', child: Text('Misc')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date Picker
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        '${_selectedDate.toLocal().year}-${_selectedDate.toLocal().month.toString().padLeft(2, '0')}-${_selectedDate.toLocal().day.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveExpense,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          isEditing ? 'Update Expense' : 'Add Expense',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
