import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionState {
  final List<TransactionModel> transactions;
  final bool loading;
  TransactionState({required this.transactions, this.loading = false});
}

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _repo;

  TransactionCubit(this._repo) : super(TransactionState(transactions: [])) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    emit(TransactionState(transactions: state.transactions, loading: true));
    final txs = await _repo.getTransactions();
    emit(TransactionState(transactions: txs));
  }

  Future<void> addTransaction(TransactionModel tx) async {
    await _repo.addTransaction(tx);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _repo.deleteTransaction(id);
    await loadTransactions();
  }
}
