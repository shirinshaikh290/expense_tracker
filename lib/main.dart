import 'package:expense_tracker_app/themes/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/transactions/domain/repositories/budget_repository.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/transactions/presentation/budget_cubit/budget_cubit.dart';
import 'features/transactions/presentation/transaction_cubit/transaction_controller.dart';
import 'home_screen.dart';

void main() {
  runApp(
     MyApp(),
  );
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  final transactionRepo = TransactionRepository();
   final budgetRepo = BudgetRepository();


   @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => TransactionCubit(transactionRepo)),
        BlocProvider(create: (_) => BudgetCubit(budgetRepo)),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Expense Tracker',
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: themeMode,
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
