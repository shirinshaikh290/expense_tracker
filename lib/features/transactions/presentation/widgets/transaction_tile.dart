import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(transaction.title),
      subtitle: Text(transaction.category),
      trailing: Text('₹${transaction.amount.toStringAsFixed(2)}'),
    );
  }
}
