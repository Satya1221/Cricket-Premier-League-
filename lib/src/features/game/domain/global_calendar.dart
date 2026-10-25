import '../../match/domain/format_config.dart';

enum Month { jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec }

class Tournament {
  const Tournament({
    required this.id,
    required this.name,
    required this.format,
    required this.startMonth,
    required this.endMonth,
    this.isInternational = false,
  }) : assert(id != ''), assert(name != '');

  final String id;
  final String name;
  final CricketFormat format;
  final Month startMonth;
  final Month endMonth;
  final bool isInternational;

  bool isActiveIn(Month month) {
    if (startMonth.index <= endMonth.index) {
      return month.index >= startMonth.index && month.index <= endMonth.index;
    }
    return month.index >= startMonth.index || month.index <= endMonth.index;
  }
}

class CalendarTick {
  const CalendarTick({
    required this.year,
    required this.month,
    required this.started,
    required this.active,
  });

  final int year;
  final Month month;
  final List<Tournament> started;
  final List<Tournament> active;
}

class GlobalCalendarEngine {
  GlobalCalendarEngine({
    int startingYear = 2026,
    Month startingMonth = Month.jan,
    List<Tournament>? tournaments,
  })  : currentYear = startingYear,
        currentMonth = startingMonth,
        tournaments = List.unmodifiable(tournaments ?? defaultTournaments);

  int currentYear;
  Month currentMonth;
  final List<Tournament> tournaments;

  static const List<Tournament> defaultTournaments = [
    Tournament(
      id: 'psl', name: 'Pakistan Super League',
      format: CricketFormat.t20, startMonth: Month.feb, endMonth: Month.mar,
    ),
    Tournament(
      id: 'ipl', name: 'Indian Premier League',
      format: CricketFormat.t20, startMonth: Month.apr, endMonth: Month.may,
    ),
    Tournament(
      id: 'hundred', name: 'The Hundred',
      format: CricketFormat.hundred, startMonth: Month.aug, endMonth: Month.aug,
    ),
    Tournament(
      id: 't20-world-cup', name: 'T20 World Cup',
      format: CricketFormat.t20, startMonth: Month.oct, endMonth: Month.nov,
      isInternational: true,
    ),
  ];

  CalendarTick advanceMonth() {
    final month = currentMonth;
    final year = currentYear;
    final started = tournaments
        .where((tournament) => tournament.startMonth == month)
        .toList(growable: false);
    final active = tournaments
        .where((tournament) => tournament.isActiveIn(month))
        .toList(growable: false);

    if (currentMonth == Month.dec) {
      currentMonth = Month.jan;
      currentYear++;
    } else {
      currentMonth = Month.values[currentMonth.index + 1];
    }

    return CalendarTick(
      year: year,
      month: month,
      started: started,
      active: active,
    );
  }
}
