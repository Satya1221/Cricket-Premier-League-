import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/display_labels.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/ui/empty_state.dart';
import '../../../widgets/ui/game_page_scaffold.dart';
import '../application/global_calendar_controller.dart';
import '../domain/global_calendar.dart';

class CompetitionCalendarScreen extends ConsumerWidget {
  const CompetitionCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(globalCalendarProvider);
    final controller = ref.read(globalCalendarProvider.notifier);
    final month = Month.values[state.currentDate.month - 1];
    final active = GlobalCalendarEngine.defaultTournaments
        .where((event) => event.isActiveIn(month))
        .toList();
    final upcoming = GlobalCalendarEngine.defaultTournaments
        .where((event) => event.startMonth.index > month.index)
        .toList()
      ..sort((a, b) => a.startMonth.index.compareTo(b.startMonth.index));

    return GamePageScaffold(
      title: 'COMPETITION CALENDAR',
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
                  'IN-GAME DATE',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: AppSpace.sm),
                Text(
                  _dateLabel(state.currentDate),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpace.md),
                Text(
                  state.lastTickSummary,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpace.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: state.hasMustRespond ? null : controller.advanceDay,
                    icon: const Icon(Icons.calendar_today_rounded),
                    label: const Text('ADVANCE ONE DAY'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          Text(
            'ACTIVE THIS MONTH',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.action,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          if (active.isEmpty)
            const EmptyState(
              icon: Icons.event_available_rounded,
              title: 'A quieter month',
              message: 'No competitions are scheduled to be active during this month. Advance the calendar to see what comes next.',
              compact: true,
            )
          else
            for (final event in active)
              Card(
                child: ListTile(
                  leading: Icon(
                    event.isInternational
                        ? Icons.public_rounded
                        : Icons.sports_cricket_rounded,
                    color: AppColors.action,
                  ),
                  title: Text(event.name),
                  subtitle: Text(
                    '${DisplayLabels.display(event.format.name)} · ${_monthLabel(event.startMonth)}–${_monthLabel(event.endMonth)}',
                  ),
                  trailing: event.isInternational
                      ? const Chip(label: Text('INTERNATIONAL'))
                      : null,
                ),
              ),
          const SizedBox(height: AppSpace.xl),
          Text(
            'UPCOMING COMPETITIONS',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.action,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          if (upcoming.isEmpty)
            const EmptyState(
              icon: Icons.event_repeat_rounded,
              title: 'You are at the end of the calendar year',
              message: 'Advance through December and the calendar will roll into January with the next year.',
              compact: true,
            )
          else
            for (final event in upcoming)
              ListTile(
                leading: const Icon(Icons.event_outlined, color: AppColors.textSecondary),
                title: Text(event.name),
                subtitle: Text(
                  'Starts in ${_monthLabel(event.startMonth)} · ${DisplayLabels.display(event.format.name)}',
                ),
              ),
        ],
      ),
    );
  }

  static String _dateLabel(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  static String _monthLabel(Month month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[month.index];
  }
}
