import 'package:flutter_test/flutter_test.dart';
import 'package:pennywise_tracker/models/finance_transaction.dart';

void main() {
  test('FinanceTransaction can be saved and restored', () {
    final original = FinanceTransaction(
      id: 1,
      title: 'Monthly salary',
      amount: 50000.0,
      type: 'income',
      category: 'Salary',
      date: DateTime(2026, 10, 25),
      note: 'October salary',
    );

    final restored = FinanceTransaction.fromMap(original.toMap());

    expect(restored.id, original.id);
    expect(restored.title, original.title);
    expect(restored.amount, original.amount);
    expect(restored.type, original.type);
    expect(restored.category, original.category);
    expect(restored.date, original.date);
    expect(restored.note, original.note);
  });
}
