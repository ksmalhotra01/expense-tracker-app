// lib/models/expense.dart

import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  late String description;

  @HiveField(1)
  late double amount;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late String category;

  /// For new expenses, you do NOT pass a key; Hive will assign one when .add(...) is called.
  Expense({
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });
}
