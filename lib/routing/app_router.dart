// import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_tracker/screens/list_screen.dart';
import 'package:expense_tracker/screens/add_edit_screen.dart';
import 'package:expense_tracker/screens/chart_screens/bar_chart_screen.dart';
import 'package:expense_tracker/screens/chart_screens/line_chart_screen.dart';
import 'package:expense_tracker/screens/chart_screens/pie_chart_screen.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const ListScreen(),
      ),
      GoRoute(
        path: '/add',
        name: 'add',
        builder: (context, state) => const AddEditScreen(),
      ),
      GoRoute(
        path: '/edit/:id',
        name: 'edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          //final id = int.parse(state.params['id']!);
          return AddEditScreen(expenseKey: id);
        },
      ),
      GoRoute(
        path: '/charts/bar',
        name: 'bar_chart',
        builder: (context, state) => const BarChartScreen(),
      ),
      GoRoute(
        path: '/charts/line',
        name: 'line_chart',
        builder: (context, state) => const LineChartScreen(),
      ),
      GoRoute(
        path: '/charts/pie',
        name: 'pie_chart',
        builder: (context, state) => const PieChartScreen(),
      ),
    ],
  );
}
