import '../../data/database/app_database.dart';
import '../../data/models/budget_model.dart';

class BudgetRepository {
  Future<List<BudgetModel>> getBudgets() async {
    final db = await AppDatabase.database;
    final res = await db.query('budgets');
    return res.map((e) => BudgetModel.fromMap(e)).toList();
  }
  Future<List<BudgetModel>> getBudgetsmonth({int? month, int? year}) async {

    final db = await AppDatabase.database;
    final now = DateTime.now();
    final m = month ?? now.month;
    final y = year ?? now.year;

    final result = await db.query(
      'budgets',
      where: 'month = ? AND year = ?',
      whereArgs: [m, y],
    );
    return result.map((e) => BudgetModel.fromMap(e)).toList();
  }



  Future<int> addBudget(BudgetModel budget) async {
    final db = await AppDatabase.database;
    return await db.insert('budgets', budget.toMap());
  }

  Future<int> deleteBudget(int id) async {
    final db = await AppDatabase.database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  /// 🔹 Get total spent for a specific category
  Future<double> getTotalSpentForCategory(String category, int month, int year) async {

    final db = await AppDatabase.database;

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE category = ? AND strftime('%m', date) = ? AND strftime('%Y', date) = ?
    ''', [category, month.toString().padLeft(2, '0'), year.toString()]);
    return (result.first['total'] as double?) ?? 0;
  }

  Future<void> deleteBudgetAndTransactions(String category) async {
    final db = await AppDatabase.database;

    await db.transaction((txn) async {
      // Delete operations for that category
      await txn.delete(
        'transactions',
        where: 'category = ?',
        whereArgs: [category],
      );

      // Delete the budget entry
      await txn.delete(
        'budgets',
        where: 'category = ?',
        whereArgs: [category],
      );
    });
  }
  // 🔹 Check if any operations exist for this category
  Future<bool> hasTransactions(String category) async {
    final db = await AppDatabase.database;
    final res = await db.query(
      'transactions',
      where: 'category = ?',
      whereArgs: [category],
    );
    return res.isNotEmpty;
  }

  // 🔹 Delete budget safely
  Future<bool> deleteBudgetSafely(String category) async {
    final db = await AppDatabase.database;

    final hasTx = await hasTransactions(category);
    if (hasTx) return false; // ❌ Cannot delete

    await db.delete('budgets', where: 'category = ?', whereArgs: [category]);
    return true; // ✅ Deleted successfully
  }


}
