import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds a single DateTime whose day is ignored — we only use year+month.
/// If null, no “monthly” filter is active.
final selectedMonthProvider = StateProvider<DateTime?>((ref) => null);
