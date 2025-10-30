import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../themes/theme_cubit.dart';
import '../operations/presentation/budget_cubit/budget_cubit.dart';
import '../operations/presentation/screens/budget_screen.dart';
import '../operations/presentation/screens/transaction_screen.dart';
import '../operations/presentation/transaction_cubit/transaction_controller.dart';
import 'expense_chart.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BudgetCubit>().loadBudgets();
    context.read<TransactionCubit>().loadTransactions();
  }

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isDark = themeMode == ThemeMode.dark;
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 💰 Summary Card
            _buildSummaryCard(context),

            const SizedBox(height: 24),

            /// 📊 Budgets Overview
            Text(
              'Budgets Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            BlocBuilder<BudgetCubit, BudgetState>(
              builder: (context, state) {

                final isDark = Theme.of(context).brightness == Brightness.dark;
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.budgets.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No budgets yet — add one to start tracking!',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }

                return Column(
                  children: state.budgets.take(3).map((budget) {
                    final spent = state.spentPerCategory[budget.category] ?? 0;
                    final progress = spent / budget.limitAmount;
                    final isExceeded = progress >= 1.0;

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        gradient: LinearGradient(
                          colors:  isDark
                              ? [
                            Colors.grey.shade300,
                            Colors.grey.shade800,
                          ]
                              : [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                          ]
                        ),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          budget.category,
                          style: const TextStyle(fontWeight: FontWeight.w600,color: Colors.black),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${spent.toStringAsFixed(2)} / ₹${budget.limitAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isExceeded
                                      ? Colors.red.shade700
                                      : Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  minHeight: 6,
                                  value: progress.clamp(0, 1),
                                  color: isExceeded
                                      ? Colors.red
                                      : progress >= 0.8
                                      ? Colors.orange
                                      : Colors.green,
                                  backgroundColor: Colors.grey.shade300,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BudgetScreen(),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            /// 📈 Expense Chart by Category
            BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, txState) {
                if (txState.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (txState.transactions.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No transactions yet — add one to see chart data!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                // ✅ Compute category totals dynamically from current transactions
                final Map<String, double> categoryTotals = {};
                for (var tx in txState.transactions) {
                  categoryTotals[tx.category] =
                      (categoryTotals[tx.category] ?? 0) + tx.amount;
                }

                return ExpenseChart(categoryData: categoryTotals);
              },
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  '${DateFormat.yMMMM().format(DateTime(selectedYear, selectedMonth))}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
             SizedBox(height: 20),
          BlocBuilder<TransactionCubit, TransactionState>(
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              // ✅ Filter transactions for selected month
              final filteredTransactions = state.transactions.where((tx) {
                final date = DateTime.tryParse(tx.date);
                return date != null &&
                    date.month == selectedMonth &&
                    date.year == selectedYear;
              }).toList();

              if (filteredTransactions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No operations this month.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // ✅ Sort by most recent & take last 5
              final recent5 = filteredTransactions
                ..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
              final last5 = recent5.take(5).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      "Recent Transactions",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  ...last5.map((tx) {
                    final date = DateTime.parse(tx.date);
                    final isExpense = tx.amount < 0;
                    final color = isExpense ? Colors.red : Colors.green;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.surface,
                            theme.colorScheme.surfaceContainerHighest,
                          ],
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.1),
                          child: Icon(
                            isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                            color: color,
                          ),
                        ),
                        title: Text(
                          tx.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          "${tx.category} • ${date.day}-${date.month}-${date.year}",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        trailing: Text(
                          "${isExpense ? '-' : '+'}₹${tx.amount.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
          const SizedBox(height: 200),
          ],
        ),
      ),

      /// 🔘 Floating buttons row
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            heroTag: 'addTx',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransactionScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'addBudget',
            backgroundColor: Colors.green,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BudgetScreen()),
              );
            },
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: const Text('Add Budget'),
          ),
        ],
      ),
    );
  }

  // 🔄 Month navigation
  void _changeMonth(int delta) {
    setState(() {
      selectedMonth += delta;
      if (selectedMonth < 1) {
        selectedMonth = 12;
        selectedYear--;
      } else if (selectedMonth > 12) {
        selectedMonth = 1;
        selectedYear++;
      }
    });

  Widget _buildSummaryCard(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, txState) {
        double totalSpent = txState.transactions.fold(0, (sum, t) => sum + t.amount);
        double totalBudget = context.read<BudgetCubit>().state.budgets.fold(
          0,
              (sum, b) => sum + b.limitAmount,
        );

        double remaining = totalBudget - totalSpent;
        remaining = remaining < 0 ? 0 : remaining;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Budget',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500)),
              Text(
                '₹${totalBudget.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 26),
              ),
              const SizedBox(height: 8),
              Text(
                'Spent: ₹${totalSpent.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white.withOpacity(0.9)),
              ),
              const SizedBox(height: 4),
              Text(
                'Remaining: ₹${remaining.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }
}

  Widget _buildSummaryCard(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, txState) {
        double totalSpent = txState.transactions.fold(0, (sum, t) => sum + t.amount);
        double totalBudget = context.read<BudgetCubit>().state.budgets.fold(
          0,
              (sum, b) => sum + b.limitAmount,
        );

        double remaining = totalBudget - totalSpent;
        remaining = remaining < 0 ? 0 : remaining;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Budget',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500)),
              totalBudget.toStringAsFixed(2)==0?CircularProgressIndicator():Text(
                '₹${totalBudget.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 26),
              ),
              const SizedBox(height: 8),
              Text(
                'Spent: ₹${totalSpent.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white.withOpacity(0.9)),
              ),
              const SizedBox(height: 4),
              Text(
                'Remaining: ₹${remaining.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }
}
