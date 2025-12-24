import 'enums.dart';
import 'timetable_entry.dart';

class DayTimetable {
  final WeekDay day;
  final List<TimetableEntry> entries;

  const DayTimetable({
    required this.day,
    required this.entries,
  });

  factory DayTimetable.fromJson(Map<String, dynamic> json) {
    return DayTimetable(
      day: WeekDay.values.byName(json['day'] as String),
      entries: (json['entries'] as List<dynamic>)
          .map((entry) => TimetableEntry.fromJson(entry as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day.name,
      'entries': entries.map((entry) => entry.toJson()).toList(),
    };
  }
}
