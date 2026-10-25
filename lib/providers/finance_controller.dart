import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/finance_database.dart';
import '../models/finance_transaction.dart';

const incomeCategories = <String>[
  'Salary',
  'Freelance',
  'Business',
  'Investment',
  'Other',
];
const expenseCategories = <String>[
  'Food',
  'Transport',
  'Shopping',
  'Bills',
  'Health',
  'Education',
  'Entertainment',
  'Travel',
  'Home',
  'Personal care',
  'Other',
];

final financeControllerProvider = ChangeNotifierProvider<FinanceController>(
  (ref) => FinanceController()..load(),
);

class FinanceController extends ChangeNotifier {
  final FinanceDatabase _database = FinanceDatabase.instance;
  List<FinanceTransaction> _transactions = [];
  Map<String, double> _budgets = {};
  bool isLoading = true;
  String? error;

  List<FinanceTransaction> get transactions => List.unmodifiable(_transactions);
  Map<String, double> get budgets => Map.unmodifiable(_budgets);

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _transactions = await _database.getTransactions();
      _budgets = await _database.getBudgets();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveTransaction(FinanceTransaction transaction) async {
    if (transaction.id == null) {
      await _database.insertTransaction(transaction);
    } else {
      await _database.updateTransaction(transaction);
    }
    await _reloadSilently();
  }

  Future<void> deleteTransaction(int id) async {
    await _database.deleteTransaction(id);
    await _reloadSilently();
  }

  Future<void> saveBudget(String category, double amount) async {
    await _database.saveBudget(category, amount);
    _budgets = await _database.getBudgets();
    notifyListeners();
  }

  Future<void> deleteBudget(String category) async {
    await _database.deleteBudget(category);
    _budgets = await _database.getBudgets();
    notifyListeners();
  }

  Future<void> _reloadSilently() async {
    _transactions = await _database.getTransactions();
    _budgets = await _database.getBudgets();
    notifyListeners();
  }

  DateTime get now => DateTime.now();

  bool isInCurrentMonth(DateTime date) =>
      date.year == now.year && date.month == now.month;

  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpenses => _transactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpenses;

  double get monthlyIncome => _transactions
      .where((t) => t.isIncome && isInCurrentMonth(t.date))
      .fold(0, (sum, t) => sum + t.amount);

  double get monthlyExpenses => _transactions
      .where((t) => !t.isIncome && isInCurrentMonth(t.date))
      .fold(0, (sum, t) => sum + t.amount);

  double get monthlySavings => monthlyIncome - monthlyExpenses;

  Map<String, double> get monthlyExpenseByCategory {
    final result = <String, double>{};
    for (final transaction in _transactions) {
      if (!transaction.isIncome && isInCurrentMonth(transaction.date)) {
        result.update(
          transaction.category,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }
    return result;
  }

  double spentThisMonth(String category) =>
      monthlyExpenseByCategory[category] ?? 0;

  List<MonthlySpend> get lastSixMonths {
    final current = DateTime(now.year, now.month);
    return List.generate(6, (index) {
      final month = DateTime(current.year, current.month - (5 - index));
      double income = 0;
      double expense = 0;
      for (final transaction in _transactions) {
        if (transaction.date.year == month.year &&
            transaction.date.month == month.month) {
          if (transaction.isIncome) {
            income += transaction.amount;
          } else {
            expense += transaction.amount;
          }
        }
      }
      return MonthlySpend(month: month, income: income, expense: expense);
    });
  }
}
