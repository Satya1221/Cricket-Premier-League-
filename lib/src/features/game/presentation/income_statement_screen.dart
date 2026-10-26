import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cricket_currency.dart';
import '../../../core/display_labels.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/ui/empty_state.dart';
import '../../../widgets/ui/game_page_scaffold.dart';
import '../../../../services/treasury_service.dart';

final treasuryRefreshProvider = StateProvider<int>((ref) => 0);

class IncomeStatementScreen extends ConsumerWidget {
  const IncomeStatementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(treasuryRefreshProvider);
    final treasury = const TreasuryService();
    final rows = treasury.transactions;
    final income = rows.where((row) => row.isIncome)
        .fold<double>(0, (sum, row) => sum + row.amount);
    final expense = rows.where((row) => !row.isIncome)
        .fold<double>(0, (sum, row) => sum + row.amount);

    return GamePageScaffold(
      title: 'INCOME STATEMENT',
      bodyPadding: EdgeInsets.zero,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.lg, AppSpace.lg, AppSpace.lg, AppSpace.huge,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpace.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OPERATING TREASURY',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: AppSpace.sm),
                Text(
                  CricketCurrency.formatRupees(treasury.balanceRupees),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpace.lg),
                Row(
                  children: [
                    Expanded(child: _metric('Income', income, AppColors.positive)),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(child: _metric('Expenses', expense, AppColors.negative)),
                  ],
                ),
                const SizedBox(height: AppSpace.md),
                const Text(
                  'The auction purse is a separate capped budget. Operating revenue does not increase the player salary cap.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          Text(
            'TRANSACTION LEDGER',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.action,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          if (rows.isEmpty)
            const EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No transactions yet',
              message: 'Match revenue, facility upgrades and other operating activity will appear here when you play.',
              compact: true,
            )
          else
            for (final transaction in rows)
              Card(
                child: ListTile(
                  leading: Icon(
                    transaction.isIncome
                        ? Icons.south_west_rounded
                        : Icons.north_east_rounded,
                    color: transaction.isIncome
                        ? AppColors.positive
                        : AppColors.negative,
                  ),
                  title: Text(transaction.description),
                  subtitle: Text(
                    '${DisplayLabels.display(transaction.category)} · ${_dateLabel(transaction.date)}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: Text(
                    '${transaction.isIncome ? '+' : '−'}${CricketCurrency.formatRupees(transaction.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: transaction.isIncome
                          ? AppColors.positive
                          : AppColors.negative,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  static Widget _metric(String label, double value, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            CricketCurrency.formatRupees(value),
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      );

  static String _dateLabel(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }
}
