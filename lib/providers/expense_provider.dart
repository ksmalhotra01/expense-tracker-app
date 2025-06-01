import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/hive_service.dart';
import 'package:hive/hive.dart';

final expenseProvider = ChangeNotifierProvider<ExpenseProvider>(
  (ref) => ExpenseProvider(),
);

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = true;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  ExpenseProvider() {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final service = HiveService();
    _expenses = service.getAllExpenses();
    _isLoading = false;
    notifyListeners();

    // Listen to box changes for auto‐refresh
    Hive.box<Expense>(HiveService.expenseBoxName).watch().listen((_) {
      _expenses = service.getAllExpenses();
      notifyListeners();
    });
  }

  /// Returns the Expense instance from the box (or null if not found)
  Expense? getExpenseByKey(int key) {
    final box = Hive.box<Expense>(HiveService.expenseBoxName);
    return box.get(key);
  }

  Future<void> addExpense(Expense expense) async {
    await HiveService().addExpense(expense);
    _expenses = HiveService().getAllExpenses();
    notifyListeners();
  }

  Future<void> updateExpense(Expense updatedExpense) async {
    // Since updatedExpense is a HiveObject (with an existing key), call save():
    await updatedExpense.save();
    _expenses = HiveService().getAllExpenses();
    notifyListeners();
  }

  Future<void> deleteExpense(Expense expense) async {
    await HiveService().deleteExpense(expense);
    _expenses = HiveService().getAllExpenses();
    notifyListeners();
  }
}
