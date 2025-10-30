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
    final formKey = GlobalKey<FormState>();
    _categoryController.clear();
    _amountController.clear();

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add New Budget',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      prefixIcon: const Icon(Icons.category_outlined),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter category name' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount (₹)',
                      prefixIcon: const Icon(Icons.currency_rupee),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) {
                      final parsed = double.tryParse(v ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Enter valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {

                            final now = DateTime.now();

                            final category = _categoryController.text.trim();
                            final amount =
                            double.parse(_amountController.text.trim());

                            final newBudget = BudgetModel(
                                month: now.month,
                                year: now.year,
                                category: category, limitAmount: amount);
                            context.read<BudgetCubit>().addBudget(newBudget);
                            Navigator.pop(ctx);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Budget "$category" added!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Budgets'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<BudgetCubit, BudgetState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      size: 60, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    'No budgets added yet.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Tap + to add your first one!',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.budgets.length,
            itemBuilder: (context, index) {
              final budget = state.budgets[index];
              final spent = state.spentPerCategory[budget.category] ?? 0;
              final progress = spent / budget.limitAmount;
              final isExceeded = progress >= 1.0;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    budget.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Budget: ₹${budget.limitAmount.toStringAsFixed(2)}'),
                        Text(
                          'Spent: ₹${spent.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isExceeded
                                ? Colors.red.shade700
                                : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: progress.clamp(0, 1),
                            backgroundColor: Colors.grey.shade300,
                            color: isExceeded
                                ? Colors.red
                                : progress >= 0.8
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBudgetDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Budget'),
      ),
    );
  }
}
