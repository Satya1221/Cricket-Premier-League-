import 'package:flutter/material.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('MANAGER INBOX'),
        actions: [
          TextButton(
            onPressed: inbox.unreadCount == 0 ? null : controller.markAllRead,
            child: const Text('MARK ALL READ'),
          ),
        ],
      ),
      body: inbox.messages.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'Your inbox is quiet. Advance the global calendar to receive competition news and manager alerts.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, height: 1.5),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: inbox.messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final message = inbox.messages[index];
                return _InboxCard(
                  message: message,
                  onTap: () {
                    controller.markRead(message.id);
                    if (message.actionRoute == '/calendar') {
                      Navigator.of(context).pop();
                      return;
                    }
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
    );
  }
}

class _InboxCard extends StatelessWidget {
  const _InboxCard({required this.message, required this.onTap});

  final InboxMessage message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final urgent = message.priority == InboxPriority.urgent;
    return Material(
      color: message.isRead ? GamePalette.panel : GamePalette.panelRaised,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                urgent ? Icons.priority_high_rounded : Icons.mail_outline_rounded,
                color: urgent ? GamePalette.danger : GamePalette.gold,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message.subject,
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(message.body,
                        style: const TextStyle(color: Colors.white70, height: 1.4)),
                    const SizedBox(height: 8),
                    Text(
                      '${message.date.day.toString().padLeft(2, '0')}/${message.date.month.toString().padLeft(2, '0')}/${message.date.year}',
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (!message.isRead)
                const Padding(
                  padding: EdgeInsets.only(left: 8, top: 5),
                  child: CircleAvatar(radius: 4, backgroundColor: GamePalette.danger),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
