import 'package:expense_tracker_app/features/transactions/presentation/screens/transaction_screen.dart';
import 'package:flutter/material.dart';

import 'features/transactions/presentation/screens/budget_screen.dart';
import 'features/dashboard/dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final tabs = const [
    DashboardScreen(),
    TransactionScreen(),
    BudgetScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Transactions'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Budgets'),
        ],
      ),
    );
  }
}
