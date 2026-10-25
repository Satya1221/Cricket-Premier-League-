import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/global_calendar.dart';
import '../domain/inbox_message.dart';

class GlobalCalendarState {
  GlobalCalendarState({
    required this.currentDate,
    List<InboxMessage> messages = const [],
    this.lastTickSummary = 'Calendar ready.',
  }) : messages = List.unmodifiable(messages);

  final DateTime currentDate;
  final List<InboxMessage> messages;
  final String lastTickSummary;

  int get year => currentDate.year;
  Month get month => Month.values[currentDate.month - 1];
  int get unreadCount => messages.where((message) => !message.isRead).length;
  bool get hasMustRespond =>
      messages.any((message) => !message.isRead && message.isCritical);

  GlobalCalendarState copyWith({
    DateTime? currentDate,
    List<InboxMessage>? messages,
    String? lastTickSummary,
  }) => GlobalCalendarState(
        currentDate: currentDate ?? this.currentDate,
        messages: messages ?? this.messages,
        lastTickSummary: lastTickSummary ?? this.lastTickSummary,
      );
}

class GlobalCalendarController extends StateNotifier<GlobalCalendarState> {
  GlobalCalendarController({GlobalCalendarEngine? engine})
      : _engine = engine ?? GlobalCalendarEngine(),
        super(GlobalCalendarState(currentDate: DateTime(2026, 1, 1)));

  final GlobalCalendarEngine _engine;
  int _messageSequence = 0;

  /// Advances one in-game day. Tournament events are emitted when the date
  /// crosses into a new month.
  void advanceDay() {
    if (state.hasMustRespond) return;

    final nextDate = state.currentDate.add(const Duration(days: 1));
    final messages = [...state.messages];
    var summary = 'Date advanced to ${_formatDate(nextDate)}.';

    if (nextDate.month != state.currentDate.month ||
        nextDate.year != state.currentDate.year) {
      final tick = _engine.advanceMonth();
      for (final tournament in tick.started) {
        messages.insert(
          0,
          InboxMessage(
            id: 'calendar-${tick.year}-${tick.month.name}-${tournament.id}-${_messageSequence++}',
            date: nextDate,
            subject: 'Competition begins: ${tournament.name}',
            body: '${tournament.name} starts this month. Format: ${tournament.format.name.toUpperCase()}. Review player availability and plan your squad.',
            actionRoute: '/calendar',
            priority: tournament.isInternational
                ? InboxPriority.important
                : InboxPriority.normal,
          ),
        );
      }
      summary = tick.started.isEmpty
          ? 'Calendar advanced to ${_formatDate(nextDate)}.'
          : '${tick.started.length} competition(s) started as the calendar reached ${tick.month.name.toUpperCase()} ${tick.year}.';
    }

    state = state.copyWith(
      currentDate: nextDate,
      messages: messages,
      lastTickSummary: summary,
    );
  }

  /// Retained for dashboard use when the manager wants to jump a full month.
  void advanceMonth() {
    if (state.hasMustRespond) return;
    final tick = _engine.advanceMonth();
    final nextDate = DateTime(tick.year, tick.month.index + 1, 1);
    final messages = [...state.messages];
    for (final tournament in tick.started) {
      messages.insert(
        0,
        InboxMessage(
          id: 'calendar-${tick.year}-${tick.month.name}-${tournament.id}-${_messageSequence++}',
          date: nextDate,
          subject: 'Competition begins: ${tournament.name}',
          body: '${tournament.name} starts this month. Format: ${tournament.format.name.toUpperCase()}. Review player availability and plan your squad.',
          actionRoute: '/calendar',
          priority: tournament.isInternational
              ? InboxPriority.important
              : InboxPriority.normal,
        ),
      );
    }
    state = state.copyWith(
      currentDate: nextDate,
      messages: messages,
      lastTickSummary: tick.started.isEmpty
          ? 'Calendar advanced to ${tick.month.name.toUpperCase()} ${tick.year}.'
          : '${tick.started.length} competition(s) started in ${tick.month.name.toUpperCase()} ${tick.year}.',
    );
  }

  void addMessage(InboxMessage message) {
    state = state.copyWith(messages: [message, ...state.messages]);
  }

  void markRead(String id) {
    final updated = state.messages
        .map((message) => message.id == id ? message.copyWith(isRead: true) : message)
        .toList(growable: false);
    state = state.copyWith(messages: updated);
  }

  void markAllRead() {
    state = state.copyWith(
      messages: state.messages
          .map((message) => message.copyWith(isRead: true))
          .toList(growable: false),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

final globalCalendarProvider =
    StateNotifierProvider<GlobalCalendarController, GlobalCalendarState>(
  (ref) => GlobalCalendarController(),
);
