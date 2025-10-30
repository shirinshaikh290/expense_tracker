import 'package:expense_tracker_app/themes/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeCubit.toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Current Theme: ${isDark ? "Dark" : "Light"}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
