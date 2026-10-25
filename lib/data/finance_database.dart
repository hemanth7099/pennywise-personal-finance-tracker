import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/finance_transaction.dart';

class FinanceDatabase {
  FinanceDatabase._();
  static final FinanceDatabase instance = FinanceDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      p.join(dbPath, 'pennywise.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL CHECK(amount > 0),
            type TEXT NOT NULL CHECK(type IN ('income', 'expense')),
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            note TEXT NOT NULL DEFAULT ''
          )
        ''');
        await db.execute('''
          CREATE TABLE budgets (
            category TEXT PRIMARY KEY,
            limit_amount REAL NOT NULL CHECK(limit_amount > 0),
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_transactions_date ON transactions(date)',
        );
        await db.execute(
          'CREATE INDEX idx_transactions_type ON transactions(type)',
        );
      },
    );
    return _database!;
  }

  Future<List<FinanceTransaction>> getTransactions() async {
    final db = await database;
    final rows = await db.query('transactions', orderBy: 'date DESC, id DESC');
    return rows.map(FinanceTransaction.fromMap).toList();
  }

  Future<int> insertTransaction(FinanceTransaction transaction) async {
    final db = await database;
    return db.insert('transactions', transaction.toMap());
  }

  Future<int> updateTransaction(FinanceTransaction transaction) async {
    final db = await database;
    return db.update(
      'transactions',
      transaction.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, double>> getBudgets() async {
    final db = await database;
    final rows = await db.query('budgets');
    return {
      for (final row in rows)
        row['category'] as String: (row['limit_amount'] as num).toDouble(),
    };
  }

  Future<void> saveBudget(String category, double limit) async {
    final db = await database;
    await db.insert('budgets', {
      'category': category,
      'limit_amount': limit,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteBudget(String category) async {
    final db = await database;
    await db.delete('budgets', where: 'category = ?', whereArgs: [category]);
  }
}
