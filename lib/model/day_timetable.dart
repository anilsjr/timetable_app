import 'enums.dart';
import 'timetable_entry.dart';

class DayTimetable {
  final WeekDay day;
  final List<TimetableEntry> entries;

  const DayTimetable({
    required this.day,
    required this.entries,
  });
}
