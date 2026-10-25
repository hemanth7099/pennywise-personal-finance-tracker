import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/finance_transaction.dart';
import '../providers/finance_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/budget_form_sheet.dart';
import '../widgets/finance_widgets.dart';
import '../widgets/transaction_form_sheet.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _titles = ['PennyWise', 'Transactions', 'Budgets', 'Insights'];

  void _addAction() {
    if (_index == 2) {
      showBudgetForm(context);
    } else {
      showTransactionForm(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(financeControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(_titles[_index]),
          ],
        ),
        actions: [
          if (_index == 0)
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppTheme.paleGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppTheme.primary,
                ),
              ),
            ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 42,
                      color: AppTheme.expense,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Could not open your finance database',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(controller.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 15),
                    FilledButton(
                      onPressed: () =>
                          ref.read(financeControllerProvider).load(),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            )
          : IndexedStack(
              index: _index,
              children: [
                DashboardScreen(
                  onAdd: _addAction,
                  onSeeAll: () => setState(() => _index = 1),
                  onSeeInsights: () => setState(() => _index = 3),
                ),
                const TransactionsScreen(),
                const BudgetsScreen(),
                const AnalyticsScreen(),
              ],
            ),
      floatingActionButton: controller.isLoading || controller.error != null
          ? null
          : FloatingActionButton.extended(
              onPressed: _addAction,
              icon: Icon(
                _index == 2 ? Icons.savings_outlined : Icons.add_rounded,
              ),
              label: Text(_index == 2 ? 'Set budget' : 'Add entry'),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard_rounded),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings_rounded),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Insights',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    required this.onAdd,
    required this.onSeeAll,
    required this.onSeeInsights,
  });
  final VoidCallback onAdd;
  final VoidCallback onSeeAll;
  final VoidCallback onSeeInsights;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeControllerProvider);
    final recent = finance.transactions.take(5).toList();
    return RefreshIndicator(
      onRefresh: () => ref.read(financeControllerProvider).load(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
        children: [
          Text(
            DateFormat('EEEE, d MMMM').format(DateTime.now()),
            style: const TextStyle(
              color: AppTheme.muted,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Your money, in focus.',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 18),
          _BalanceCard(
            balance: finance.balance,
            monthlySavings: finance.monthlySavings,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              StatCard(
                label: 'Income this month',
                amount: formatMoney(finance.monthlyIncome),
                icon: Icons.south_west_rounded,
                color: AppTheme.income,
                background: AppTheme.paleGreen,
              ),
              const SizedBox(width: 12),
              StatCard(
                label: 'Spent this month',
                amount: formatMoney(finance.monthlyExpenses),
                icon: Icons.north_east_rounded,
                color: AppTheme.expense,
                background: AppTheme.paleRed,
              ),
            ],
          ),
          const SizedBox(height: 23),
          SectionHeader(
            title: 'Spending trend',
            actionLabel: 'Insights',
            onAction: onSeeInsights,
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
              child: finance.transactions.isEmpty
                  ? const EmptyState(
                      icon: Icons.bar_chart_rounded,
                      title: 'Your trend starts here',
                      message:
                          'Add transactions to see how your monthly spending changes.',
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly expenses',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SpendingBarChart(months: finance.lastSixMonths),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 22),
          SectionHeader(
            title: 'Recent activity',
            actionLabel: 'See all',
            onAction: onSeeAll,
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: recent.isEmpty
                  ? EmptyState(
                      icon: Icons.receipt_long_rounded,
                      title: 'No transactions yet',
                      message:
                          'Start by recording your first income or expense.',
                      actionLabel: 'Add transaction',
                      onAction: onAdd,
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < recent.length; i++) ...[
                          TransactionListTile(
                            transaction: recent[i],
                            onEdit: () => showTransactionForm(
                              context,
                              transaction: recent[i],
                            ),
                            onDelete: () =>
                                _deleteTransaction(context, ref, recent[i]),
                          ),
                          if (i != recent.length - 1) const Divider(height: 8),
                        ],
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your data is stored locally on this device.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance, required this.monthlySavings});
  final double balance;
  final double monthlySavings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Total balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz_rounded, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(balance),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.17)),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 17,
                color: Colors.white70,
              ),
              const SizedBox(width: 7),
              const Text(
                'This month',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              Icon(
                monthlySavings >= 0
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: 17,
                color: Colors.white,
              ),
              const SizedBox(width: 5),
              Text(
                '${monthlySavings >= 0 ? '+' : '−'}${formatMoney(monthlySavings.abs())}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();
  String _filter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(financeControllerProvider);
    final query = _searchController.text.trim().toLowerCase();
    final filtered = finance.transactions.where((transaction) {
      final matchesType =
          _filter == 'All' ||
          (_filter == 'Income' && transaction.isIncome) ||
          (_filter == 'Expense' && !transaction.isIncome);
      final matchesQuery =
          query.isEmpty ||
          transaction.title.toLowerCase().contains(query) ||
          transaction.category.toLowerCase().contains(query) ||
          transaction.note.toLowerCase().contains(query);
      return matchesType && matchesQuery;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
      children: [
        const Text(
          'Every rupee, accounted for.',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppTheme.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${finance.transactions.length} transaction${finance.transactions.length == 1 ? '' : 's'} saved on this device',
          style: const TextStyle(color: AppTheme.muted, fontSize: 12),
        ),
        const SizedBox(height: 17),
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search title, category or note',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: ['All', 'Income', 'Expense']
              .map(
                (type) => ChoiceChip(
                  label: Text(type),
                  selected: _filter == type,
                  onSelected: (_) => setState(() => _filter = type),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 15),
        if (filtered.isEmpty)
          EmptyState(
            icon: Icons.search_off_rounded,
            title: query.isNotEmpty || _filter != 'All'
                ? 'No matching transactions'
                : 'Nothing here yet',
            message: query.isNotEmpty || _filter != 'All'
                ? 'Try another search or filter.'
                : 'Add your income and expenses to start building your money history.',
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                children: [
                  for (var i = 0; i < filtered.length; i++) ...[
                    TransactionListTile(
                      transaction: filtered[i],
                      onEdit: () => showTransactionForm(
                        context,
                        transaction: filtered[i],
                      ),
                      onDelete: () =>
                          _deleteTransaction(context, ref, filtered[i]),
                    ),
                    if (i != filtered.length - 1) const Divider(height: 8),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeControllerProvider);
    final budgets = finance.budgets;
    final spending = finance.monthlyExpenseByCategory;
    final categories = <String>{...expenseCategories, ...budgets.keys}.toList();
    final configured = categories
        .where((category) => budgets.containsKey(category))
        .toList();
    final hasBudget = configured.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
      children: [
        const Text(
          'Give every rupee a plan.',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppTheme.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Set monthly limits and see where you stand.',
          style: TextStyle(color: AppTheme.muted, fontSize: 13),
        ),
        const SizedBox(height: 18),
        _BudgetSummaryCard(
          totalBudget: budgets.values.fold<double>(
            0,
            (sum, value) => sum + value,
          ),
          totalSpent: budgets.keys.fold<double>(
            0,
            (sum, category) => sum + (spending[category] ?? 0),
          ),
          count: budgets.length,
        ),
        const SizedBox(height: 20),
        SectionHeader(title: 'Category budgets'),
        if (!hasBudget)
          EmptyState(
            icon: Icons.savings_outlined,
            title: 'No budgets set yet',
            message:
                'Create a monthly limit for categories like food, shopping or transport. Your spending will update automatically.',
            actionLabel: 'Create first budget',
            onAction: () => showBudgetForm(context),
          )
        else
          ...configured.map((category) {
            final limit = budgets[category] ?? 0;
            final spent = spending[category] ?? 0;
            final ratio = limit <= 0 ? 0.0 : spent / limit;
            final over = ratio > 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: categoryColor(
                                category,
                              ).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              categoryIcon(category),
                              color: categoryColor(category),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.ink,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${formatMoney(spent)} of ${formatMoney(limit)}',
                                  style: const TextStyle(
                                    color: AppTheme.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                showBudgetForm(
                                  context,
                                  category: category,
                                  currentLimit: limit,
                                );
                              } else if (value == 'delete') {
                                _deleteBudget(context, ref, category);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit budget'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Remove budget'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: ratio.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: AppTheme.border,
                          color: over ? AppTheme.expense : AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            over
                                ? 'Over budget by ${formatMoney(spent - limit)}'
                                : '${(ratio * 100).round()}% used',
                            style: TextStyle(
                              color: over ? AppTheme.expense : AppTheme.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${formatMoney((limit - spent).abs())} ${over ? 'over' : 'left'}',
                            style: TextStyle(
                              color: over ? AppTheme.expense : AppTheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        if (hasBudget) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => showBudgetForm(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add another category budget'),
          ),
        ],
      ],
    );
  }
}

class _BudgetSummaryCard extends StatelessWidget {
  const _BudgetSummaryCard({
    required this.totalBudget,
    required this.totalSpent,
    required this.count,
  });
  final double totalBudget;
  final double totalSpent;
  final int count;

  @override
  Widget build(BuildContext context) {
    final ratio = totalBudget <= 0 ? 0.0 : totalSpent / totalBudget;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.paleGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly budget overview',
            style: TextStyle(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            formatMoney(totalSpent),
            style: const TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryDark,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'spent across $count budget ${count == 1 ? 'category' : 'categories'}',
            style: const TextStyle(color: AppTheme.primary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white,
              color: ratio > 1 ? AppTheme.expense : AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Budget: ${formatMoney(totalBudget)}',
                style: const TextStyle(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                totalBudget <= 0
                    ? 'Set a limit'
                    : '${(ratio * 100).round()}% used',
                style: const TextStyle(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeControllerProvider);
    final monthly = finance.lastSixMonths;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
      children: [
        const Text(
          'Your money patterns.',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppTheme.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Insights from your saved transactions.',
          style: TextStyle(color: AppTheme.muted, fontSize: 13),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            StatCard(
              label: 'Month savings',
              amount: formatMoney(finance.monthlySavings),
              icon: Icons.savings_outlined,
              color: finance.monthlySavings >= 0
                  ? AppTheme.income
                  : AppTheme.expense,
              background: finance.monthlySavings >= 0
                  ? AppTheme.paleGreen
                  : AppTheme.paleRed,
            ),
            const SizedBox(width: 12),
            StatCard(
              label: 'All-time expenses',
              amount: formatMoney(finance.totalExpenses),
              icon: Icons.payments_outlined,
              color: AppTheme.expense,
              background: AppTheme.paleRed,
            ),
          ],
        ),
        const SizedBox(height: 22),
        const SectionHeader(title: 'Expenses over 6 months'),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 18, 12, 10),
            child: finance.transactions.isEmpty
                ? const EmptyState(
                    icon: Icons.show_chart_rounded,
                    title: 'No trends yet',
                    message:
                        'Your chart will appear after you add a few transactions.',
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly expense totals',
                        style: TextStyle(fontSize: 12, color: AppTheme.muted),
                      ),
                      const SizedBox(height: 8),
                      SpendingBarChart(months: monthly),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 22),
        const SectionHeader(title: 'This month by category'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CategoryPieChart(values: finance.monthlyExpenseByCategory),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Analytics are calculated from transactions stored on this device.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: AppTheme.muted),
        ),
      ],
    );
  }
}

Future<void> _deleteTransaction(
  BuildContext context,
  WidgetRef ref,
  FinanceTransaction transaction,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete transaction?'),
      content: Text(
        '“${transaction.title}” will be removed from your local history.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await ref
        .read(financeControllerProvider)
        .deleteTransaction(transaction.id!);
    if (context.mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
  }
}

Future<void> _deleteBudget(
  BuildContext context,
  WidgetRef ref,
  String category,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Remove budget?'),
      content: Text(
        'Remove the monthly limit for $category? Your transactions will not be deleted.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await ref.read(financeControllerProvider).deleteBudget(category);
    if (context.mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Budget removed')));
  }
}
