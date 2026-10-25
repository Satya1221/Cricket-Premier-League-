import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/game_theme.dart';
import '../application/global_calendar_controller.dart';
import '../domain/inbox_message.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(globalCalendarProvider);
    final controller = ref.read(globalCalendarProvider.notifier);
    final date = _formatLongDate(inbox.currentDate);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'MANAGER INBOX',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900),
        ),
        actions: [
          if (inbox.unreadCount > 0)
            TextButton(
              onPressed: controller.markAllRead,
              child: const Text('READ ALL'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _CalendarHeader(date: inbox.currentDate),
            Expanded(
              child: inbox.messages.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(28),
                        child: Text(
                          'No new messages.\n\nYour staff will report here when competitions start and decisions need your attention.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, height: 1.6),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      itemCount: inbox.messages.length,
                      itemBuilder: (context, index) => _MessageCard(
                        message: inbox.messages[index],
                        index: index,
                        onExpanded: () =>
                            controller.markRead(inbox.messages[index].id),
                        onAction: () {
                          final message = inbox.messages[index];
                          controller.markRead(message.id);
                          if (message.actionRoute == '/calendar') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Competition details are available from the global calendar.'),
                              ),
                            );
                            return;
                          }
                          Navigator.of(context).pushNamed(message.actionRoute);
                        },
                      ),
                    ),
            ),
            _ContinueBar(
              blocked: inbox.hasMustRespond,
              onContinue: controller.advanceDay,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatLongDate(DateTime date) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final formatted = InboxScreen._formatLongDate(date).toUpperCase();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_rounded, color: GamePalette.emerald),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              formatted,
              key: ValueKey(formatted),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ).animate().slideX(begin: 0.12, end: 0, duration: 300.ms).fadeIn(),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.message,
    required this.index,
    required this.onExpanded,
    required this.onAction,
  });

  final InboxMessage message;
  final int index;
  final VoidCallback onExpanded;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final unread = !message.isRead;
    final urgent = message.priority == InboxPriority.urgent || message.isCritical;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: urgent
                ? GamePalette.danger
                : unread
                    ? GamePalette.emerald
                    : Colors.transparent,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.white.withValues(alpha: 0.03),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          childrenPadding: EdgeInsets.zero,
          iconColor: Colors.white,
          collapsedIconColor: Colors.white54,
          onExpansionChanged: (expanded) {
            if (expanded && unread) onExpanded();
          },
          leading: Icon(
            urgent ? Icons.priority_high_rounded : Icons.mail_outline_rounded,
            color: urgent ? GamePalette.danger : GamePalette.emerald,
          ),
          title: Text(
            message.subject,
            style: TextStyle(
              color: unread ? Colors.white : Colors.white70,
              fontWeight: unread ? FontWeight.w900 : FontWeight.w600,
              fontSize: 15,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              '${_shortDate(message.date)}${message.isCritical ? '  •  RESPONSE REQUIRED' : ''}',
              style: TextStyle(
                color: message.isCritical ? GamePalette.danger : Colors.white38,
                fontSize: 11,
                fontWeight: message.isCritical ? FontWeight.w800 : FontWeight.normal,
              ),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  Text(
                    message.body,
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  ),
                  if (message.actionRoute.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: GamePalette.emerald,
                          side: const BorderSide(color: GamePalette.emerald),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onPressed: onAction,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text(
                          'TAKE ACTION',
                          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.7),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 80 * index)).slideY(begin: 0.08, end: 0);
  }

  static String _shortDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _ContinueBar extends StatelessWidget {
  const _ContinueBar({required this.blocked, required this.onContinue});

  final bool blocked;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final accent = blocked ? Colors.blueGrey.shade700 : GamePalette.emerald;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SizedBox(
        height: 64,
        child: ElevatedButton(
          onPressed: blocked ? null : onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            disabledBackgroundColor: Colors.blueGrey.shade900,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white54,
            elevation: blocked ? 0 : 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            blocked ? 'MUST RESPOND' : 'CONTINUE',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ).animate(
          target: blocked ? 0 : 1,
          onPlay: (controller) {
            if (!blocked) controller.repeat(reverse: true);
          },
        ).boxShadow(
          end: BoxShadow(
            color: GamePalette.emerald.withValues(alpha: 0.25),
            blurRadius: 16,
            spreadRadius: 1,
          ),
          duration: 1000.ms,
        ),
      ),
    );
  }
}
