enum InboxPriority { normal, important, urgent }

class InboxMessage {
  InboxMessage({
    required this.id,
    required this.date,
    required this.subject,
    required this.body,
    this.actionRoute = '/inbox',
    this.priority = InboxPriority.normal,
    this.isRead = false,
  })  : assert(id != ''),
        assert(subject != ''),
        assert(actionRoute != '');

  final String id;
  final DateTime date;
  final String subject;
  final String body;
  final String actionRoute;
  final InboxPriority priority;
  bool isRead;

  InboxMessage copyWith({bool? isRead}) => InboxMessage(
        id: id,
        date: date,
        subject: subject,
        body: body,
        actionRoute: actionRoute,
        priority: priority,
        isRead: isRead ?? this.isRead,
      );
}
