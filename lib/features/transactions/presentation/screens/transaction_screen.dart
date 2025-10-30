import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/transaction_model.dart';
import '../budget_cubit/budget_cubit.dart';
import '../transaction_cubit/transaction_controller.dart';
import '../widgets/transaction_tile.dart';


class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String category = 'Food';

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TransactionCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state.loading) return const Center(child: CircularProgressIndicator());

          return ListView.builder(
            itemCount: state.transactions.length,
            itemBuilder: (context, index) {
              final tx = state.transactions[index];
              return Dismissible(
                key: ValueKey(tx.id),
                background: Container(color: Colors.red),
                onDismissed: (_) => cubit.deleteTransaction(tx.id!),
                child: TransactionTile(transaction: tx),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(cubit),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(TransactionCubit cubit) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
            DropdownButton<String>(
              value: category,
              onChanged: (v) => setState(() => category = v!),
              items: ['Food', 'Travel', 'Bills', 'Other']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final tx = TransactionModel(
                title: _titleController.text,
                category: category,
                amount: double.tryParse(_amountController.text) ?? 0.0,
                date: DateTime.now().toIso8601String(),
              );
              cubit.addTransaction(tx);

              // 🔄 Refresh budgets
              context.read<BudgetCubit>().loadBudgets();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
