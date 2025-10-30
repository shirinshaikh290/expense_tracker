import '../../data/database/app_database.dart';
import '../../data/models/transaction_model.dart';

class TransactionRepository {
  Future<List<TransactionModel>> getTransactions() async {
    final db = await AppDatabase.database;
    final res = await db.query('transactions', orderBy: 'id DESC');
    return res.map((e) => TransactionModel.fromMap(e)).toList();
  }

  Future<int> addTransaction(TransactionModel tx) async {
    final db = await AppDatabase.database;
    return await db.insert('transactions', tx.toMap());
  }

  Future<int> deleteTransaction(int id) async {
    final db = await AppDatabase.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}