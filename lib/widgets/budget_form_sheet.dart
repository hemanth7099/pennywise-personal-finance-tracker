import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/finance_controller.dart';
import '../theme/app_theme.dart';

Future<void> showBudgetForm(
  BuildContext context, {
  String? category,
  double? currentLimit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        BudgetFormSheet(category: category, currentLimit: currentLimit),
  );
}

class BudgetFormSheet extends ConsumerStatefulWidget {
  const BudgetFormSheet({super.key, this.category, this.currentLimit});
  final String? category;
  final double? currentLimit;

  @override
  ConsumerState<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends ConsumerState<BudgetFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _category;
  late final TextEditingController _amountController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _category = widget.category ?? expenseCategories.first;
    _amountController = TextEditingController(
      text: widget.currentLimit?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(
      _amountController.text.trim().replaceAll(',', ''),
    );
    if (amount == null || !amount.isFinite || amount <= 0) return;
    setState(() => _saving = true);
    try {
      await ref.read(financeControllerProvider).saveBudget(_category, amount);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save budget: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.category == null
                  ? 'Set a monthly budget'
                  : 'Edit ${widget.category} budget',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Expense category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: expenseCategories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: widget.category == null
                  ? (value) {
                      if (value != null) setState(() => _category = value);
                    }
                  : null,
            ),
            const SizedBox(height: 13),
            TextFormField(
              controller: _amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monthly limit',
                prefixText: '₹ ',
                hintText: 'e.g. 5000',
              ),
              validator: (value) {
                final amount = double.tryParse(
                  (value ?? '').trim().replaceAll(',', ''),
                );
                if (amount == null || !amount.isFinite || amount <= 0)
                  return 'Enter a limit greater than zero';
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.savings_outlined),
                label: Text(_saving ? 'Saving…' : 'Save budget'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
