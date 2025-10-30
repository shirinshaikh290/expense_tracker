import 'package:flutter/material.dart';

import 'features/dashboard/dashboard_screen.dart';
import 'features/operations/presentation/screens/budget_screen.dart';
import 'features/operations/presentation/screens/transaction_screen.dart';

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
