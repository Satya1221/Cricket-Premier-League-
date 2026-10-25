import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/global_calendar.dart';
import '../domain/inbox_message.dart';

class GlobalCalendarState {
  GlobalCalendarState({
    required this.year,
    required this.month,
    List<InboxMessage> messages = const [],
    this.lastTickSummary = 'Calendar ready.',
  }) : messages = List.unmodifiable(messages);

  final int year;
  final Month month;
  final List<InboxMessage> messages;
  final String lastTickSummary;

  int get unreadCount => messages.where((message) => !message.isRead).length;

  GlobalCalendarState copyWith({
    int? year,
    Month? month,
    List<InboxMessage>? messages,
    String? lastTickSummary,
  }) => GlobalCalendarState(
        year: year ?? this.year,
        month: month ?? this.month,
        messages: messages ?? this.messages,
        lastTickSummary: lastTickSummary ?? this.lastTickSummary,
      );
}

class GlobalCalendarController extends StateNotifier<GlobalCalendarState> {
  GlobalCalendarController({GlobalCalendarEngine? engine})
      : _engine = engine ?? GlobalCalendarEngine(),
        super(GlobalCalendarState(year: 2026, month: Month.jan));

  final GlobalCalendarEngine _engine;
  int _messageSequence = 0;

  void advanceMonth() {
    final tick = _engine.advanceMonth();
    final messages = [...state.messages];
    for (final tournament in tick.started) {
      messages.insert(
        0,
        InboxMessage(
          id: 'calendar-${tick.year}-${tick.month.name}-${tournament.id}-${_messageSequence++}',
          date: DateTime(tick.year, tick.month.index + 1, 1),
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
      year: _engine.currentYear,
      month: _engine.currentMonth,
      messages: messages,
      lastTickSummary: tick.started.isEmpty
          ? 'Calendar advanced to ${_engine.currentMonth.name.toUpperCase()} ${_engine.currentYear}.'
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
      messages: state.messages.map((message) => message.copyWith(isRead: true)).toList(growable: false),
    );
  }
}

final globalCalendarProvider =
    StateNotifierProvider<GlobalCalendarController, GlobalCalendarState>(
  (ref) => GlobalCalendarController(),
);
