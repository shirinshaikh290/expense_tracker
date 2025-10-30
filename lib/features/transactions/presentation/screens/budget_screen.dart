import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/budget_model.dart';
import '../budget_cubit/budget_cubit.dart';


class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  void _showAddBudgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Add Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (₹)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _categoryController.clear();
                _amountController.clear();
                Navigator.pop(ctx);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final category = _categoryController.text.trim();
                final amount = double.tryParse(_amountController.text.trim()) ?? 0;

                if (category.isEmpty || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter valid category and amount.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final newBudget = BudgetModel(category: category, limitAmount: amount);
                context.read<BudgetCubit>().addBudget(newBudget);

                _categoryController.clear();
                _amountController.clear();
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<BudgetCubit>().loadBudgets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body:BlocBuilder<BudgetCubit, BudgetState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.budgets.isEmpty) {
            return const Center(child: Text('No budgets yet. Tap + to add one.'));
          }

          return ListView.builder(
            itemCount: state.budgets.length,
            itemBuilder: (context, index) {
              final budget = state.budgets[index];
              final spent = state.spentPerCategory[budget.category] ?? 0;
              final progress = spent / budget.limitAmount;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(budget.category),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Budget: ₹${budget.limitAmount.toStringAsFixed(2)}'),
                      Text('Spent: ₹${spent.toStringAsFixed(2)}'),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress.clamp(0, 1),
                        color: progress >= 1
                            ? Colors.red
                            : progress >= 0.8
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => context
                        .read<BudgetCubit>()
                        .deleteBudgetSafely(budget.category, context),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        child: const Icon(Icons.add),
      ),

    );

  }
}
