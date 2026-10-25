import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/finance_transaction.dart';
import '../theme/app_theme.dart';

final _money = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

String formatMoney(num value) => _money.format(value);

String formatCompactMoney(num value) {
  final n = value.abs();
  if (n >= 10000000)
    return '${value < 0 ? '-' : ''}₹${(n / 10000000).toStringAsFixed(1)}Cr';
  if (n >= 100000)
    return '${value < 0 ? '-' : ''}₹${(n / 100000).toStringAsFixed(1)}L';
  if (n >= 1000)
    return '${value < 0 ? '-' : ''}₹${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}k';
  return formatMoney(value);
}

String formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);

IconData categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'salary':
      return Icons.account_balance_wallet_rounded;
    case 'freelance':
      return Icons.laptop_mac_rounded;
    case 'business':
      return Icons.storefront_rounded;
    case 'investment':
      return Icons.trending_up_rounded;
    case 'food':
      return Icons.restaurant_rounded;
    case 'transport':
      return Icons.directions_car_filled_rounded;
    case 'shopping':
      return Icons.shopping_bag_rounded;
    case 'bills':
      return Icons.receipt_long_rounded;
    case 'health':
      return Icons.favorite_rounded;
    case 'education':
      return Icons.school_rounded;
    case 'entertainment':
      return Icons.movie_rounded;
    case 'travel':
      return Icons.flight_takeoff_rounded;
    case 'home':
      return Icons.home_rounded;
    case 'personal care':
      return Icons.spa_rounded;
    default:
      return Icons.category_rounded;
  }
}

Color categoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return const Color(0xFFE9A23B);
    case 'transport':
      return const Color(0xFF4D8FD9);
    case 'shopping':
      return const Color(0xFF9874D5);
    case 'bills':
      return const Color(0xFFDD6B6B);
    case 'health':
      return const Color(0xFFE879A9);
    case 'education':
      return const Color(0xFF4DA9A0);
    case 'entertainment':
      return const Color(0xFF6878D6);
    case 'travel':
      return const Color(0xFF54A6D8);
    case 'home':
      return const Color(0xFF9A916B);
    case 'salary':
      return AppTheme.income;
    case 'freelance':
      return const Color(0xFF3F8DCE);
    case 'business':
      return const Color(0xFF9874D5);
    case 'investment':
      return const Color(0xFFE9A23B);
    default:
      return const Color(0xFF7F8C88);
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.background,
  });
  final String label;
  final String amount;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 13),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amount,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: AppTheme.paleGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: AppTheme.primary),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.45, color: AppTheme.muted),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 17),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
  });
  final FinanceTransaction transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final color = transaction.isIncome ? AppTheme.income : AppTheme.expense;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: categoryColor(
                transaction.category,
              ).withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              categoryIcon(transaction.category),
              color: categoryColor(transaction.category),
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.category} · ${DateFormat('dd MMM').format(transaction.date)}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.isIncome ? '+' : '−'}${formatMoney(transaction.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontSize: 13,
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 128),
                iconSize: 18,
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 9),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppTheme.expense,
                        ),
                        SizedBox(width: 9),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SpendingBarChart extends StatelessWidget {
  const SpendingBarChart({super.key, required this.months});
  final List<MonthlySpend> months;

  @override
  Widget build(BuildContext context) {
    final maxValue = months.fold<double>(
      0,
      (max, m) => m.expense > max ? m.expense : max,
    );
    final ceiling = maxValue <= 0 ? 1000.0 : maxValue * 1.22;
    return SizedBox(
      height: 218,
      child: BarChart(
        BarChartData(
          maxY: ceiling,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: true),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: ceiling / 4,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppTheme.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: ceiling / 4,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Text(
                    formatCompactMoney(value),
                    style: const TextStyle(fontSize: 9, color: AppTheme.muted),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= months.length)
                    return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(
                      DateFormat('MMM').format(months[index].month),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.muted,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: months
              .asMap()
              .entries
              .map(
                (entry) => BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.expense,
                      width: 18,
                      color: AppTheme.primary,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(5),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key, required this.values});
  final Map<String, double> values;

  @override
  Widget build(BuildContext context) {
    final entries = values.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (entries.isEmpty)
      return const SizedBox(
        height: 180,
        child: EmptyState(
          icon: Icons.pie_chart_outline_rounded,
          title: 'No spending to analyze',
          message:
              'Add a few expense transactions to see your category breakdown.',
        ),
      );
    final colors = entries.map((e) => categoryColor(e.key)).toList();
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 44,
              sectionsSpace: 3,
              sections: entries
                  .asMap()
                  .entries
                  .map(
                    (entry) => PieChartSectionData(
                      value: entry.value.value,
                      color: colors[entry.key],
                      title: '',
                      radius: 62,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...entries.take(6).toList().asMap().entries.map((indexed) {
          final entry = indexed.value;
          final total = entries.fold<double>(
            0,
            (sum, item) => sum + item.value,
          );
          final percent = total == 0 ? 0 : entry.value / total * 100;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors[indexed.key],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.ink,
                    ),
                  ),
                ),
                Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatMoney(entry.value),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
