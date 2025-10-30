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


  Future<Map<String, double>> getCategoryTotals() async {

    final db = await AppDatabase.database;

    final result = await db.rawQuery('''
      SELECT c.category AS category, SUM(t.amount) AS total
      FROM transactions t
      INNER JOIN budgets c ON t.id = c.id
      GROUP BY c.category
    ''');

    // Convert result into a map: { 'Food': 1200, 'Travel': 800 }
    final Map<String, double> categoryTotals = {};
    for (var row in result) {
      final category = row['category'] as String;
      final total = (row['total'] as num?)?.toDouble() ?? 0.0;
      categoryTotals[category] = total;
    }

    return categoryTotals;
  }
}