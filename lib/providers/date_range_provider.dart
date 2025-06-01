import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds an arbitrary DateTimeRange filter, or null if none.
final dateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);
