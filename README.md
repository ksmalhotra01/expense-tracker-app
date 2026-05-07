# Expense Tracker

A Flutter application for tracking personal expenses with category-based filtering and spending visualizations.

## Features

- **Add / Edit / Delete** expenses with description, amount, category, and date
- **5 categories**: Food, Transport, Shopping, Utilities, Misc
- **Filter** by month or custom date range across all screens
- **3 chart views**: bar (by category), line (daily trend), pie (distribution)
- **Persistent storage** via Hive (local, no backend required)

## Screenshots

> Add screenshots here if available.

## Tech Stack

| Layer | Library |
|---|---|
| Framework | Flutter (SDK ≥ 2.18.0) |
| State management | [Riverpod](https://riverpod.dev) 2.0.0 |
| Navigation | [GoRouter](https://pub.dev/packages/go_router) 7.0.0 |
| Local storage | [Hive](https://pub.dev/packages/hive) 2.0.0 |
| Charts | [fl_chart](https://pub.dev/packages/fl_chart) 1.0.0 |

## Project Structure

```
lib/
├── main.dart                  # App entry point, Riverpod setup
├── models/
│   └── expense.dart           # Hive-backed Expense model
├── providers/
│   └── expense_provider.dart  # ChangeNotifier + filter StateProviders
├── services/
│   └── hive_service.dart      # Hive CRUD abstraction
├── screens/
│   ├── list_screen.dart       # Main expense list with filter support
│   ├── add_edit_screen.dart   # Add / edit form
│   └── chart_screens/
│       ├── bar_chart_screen.dart
│       ├── line_chart_screen.dart
│       └── pie_chart_screen.dart
└── widgets/
    └── filter_picker_button.dart  # Reusable month / date-range picker
```

## Getting Started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) 3.x
- Dart SDK (bundled with Flutter)

### Setup

```bash
# Install dependencies
flutter pub get

# Generate Hive type adapters
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

## Data Model

```dart
class Expense extends HiveObject {
  String description;
  double amount;
  DateTime date;
  String category; // Food | Transport | Shopping | Utilities | Misc
}
```

## State Management

| Provider | Type | Purpose |
|---|---|---|
| `expenseProvider` | `ChangeNotifierProvider` | Expense list, loading state, CRUD |
| `selectedMonthProvider` | `StateProvider<DateTime?>` | Active month filter |
| `dateRangeProvider` | `StateProvider<DateTimeRange?>` | Active date-range filter |

Filter priority: **date range > monthly > none (show all)**.

## Screens & Routes

| Route | Screen |
|---|---|
| `/` | Expense list |
| `/add` | Add expense |
| `/edit/:id` | Edit expense |
| `/charts/bar` | Bar chart — spending by category |
| `/charts/line` | Line chart — daily spending trend |
| `/charts/pie` | Pie chart — category distribution |
