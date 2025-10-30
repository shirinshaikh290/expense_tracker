import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/budget_model.dart';
import '../../domain/repositories/budget_repository.dart';

class BudgetState {
  final List<BudgetModel> budgets;
  final Map<String, double> spentPerCategory;
  final bool loading;
  final String? errorMessage;

  BudgetState({
    required this.budgets,
    required this.spentPerCategory,
    this.loading = false,
    this.errorMessage,
  });

  BudgetState copyWith({
    List<BudgetModel>? budgets,
    Map<String, double>? spentPerCategory,
    bool? loading,
    String? errorMessage,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      spentPerCategory: spentPerCategory ?? this.spentPerCategory,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }
}

class BudgetCubit extends Cubit<BudgetState> {
  final BudgetRepository _repo;

  BudgetCubit(this._repo)
      : super(BudgetState(budgets: [], spentPerCategory: {})) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    emit(state.copyWith(loading: true, errorMessage: null));
    final budgets = await _repo.getBudgets();

    final Map<String, double> spentData = {};
    for (var b in budgets) {
      spentData[b.category] = await _repo.getTotalSpentForCategory(b.category);
    }

    emit(BudgetState(budgets: budgets, spentPerCategory: spentData));
  }

  Future<void> addBudget(BudgetModel budget) async {
    await _repo.addBudget(budget);
    await loadBudgets();
  }

  Future<void> deleteBudgetSafely(String category, BuildContext context) async {
    final success = await _repo.deleteBudgetSafely(category);
    if (!success) {
      emit(state.copyWith(errorMessage: 'Cannot delete — transactions exist for this category.'));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete budget — existing transactions found.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      await loadBudgets();
    }
  }

  void clearError() => emit(state.copyWith(errorMessage: null));
}
