import 'package:flutter/material.dart';

class AddEditScreen extends StatelessWidget {
  final int? expenseKey;
  const AddEditScreen({Key? key, this.expenseKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('AddEditScreen placeholder')),
    );
  }
}
