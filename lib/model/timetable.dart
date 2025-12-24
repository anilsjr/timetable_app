import 'day_timetable.dart';

class Timetable {
  final String id;
  final String classRoomId;
  final List<DayTimetable> weekTimetable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Timetable({
    required this.id,
    required this.classRoomId,
    required this.weekTimetable,
    required this.createdAt,
    required this.updatedAt,
  });
}
