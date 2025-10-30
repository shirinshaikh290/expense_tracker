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
          if (state.loading)
            return const Center(child: CircularProgressIndicator());

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

  /* void _showAddDialog(TransactionCubit cubit) {
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
}*/

  void _showAddDialog(TransactionCubit cubit) {
    final budgetState = context
        .read<BudgetCubit>()
        .state;
    final categories = budgetState.budgets.map((b) => b.category).toList();

    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a budget category first.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final _titleController = TextEditingController();
    final _amountController = TextEditingController();
    String category = categories.first;

    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: const Text('Add Transaction'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: category,
                  onChanged: (v) {
                    if (v != null) {
                      category = v;
                    }
                  },
                  items: categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final title = _titleController.text.trim();
                  final amountText = _amountController.text.trim();

                  if (title.isEmpty || amountText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all fields.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final amount = double.tryParse(amountText);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid amount.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final tx = TransactionModel(
                    title: title,
                    category: category,
                    amount: amount,
                    date: DateTime.now().toIso8601String(),
                  );

                  cubit.addTransaction(tx);

                  // 🔄 Refresh budget values after adding transaction
                  context.read<BudgetCubit>().loadBudgets();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Transaction added under "$category"'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

}