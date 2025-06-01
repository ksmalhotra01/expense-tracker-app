import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker/models/expense.dart';

class HiveService {
  static const String expenseBoxName = 'expenses';

  Box<Expense> _getExpenseBox() => Hive.box<Expense>(expenseBoxName);

  List<Expense> getAllExpenses() {
    final box = _getExpenseBox();
    return box.values.toList();
  }

  Future<void> addExpense(Expense expense) async {
    final box = _getExpenseBox();
    await box.add(expense);
  }

  Future<void> updateExpense(Expense expense) async {
    await expense.save();
  }

  Future<void> deleteExpense(Expense expense) async {
    await expense.delete();
  }
}
