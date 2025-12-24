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

  factory Timetable.fromJson(Map<String, dynamic> json) {
    return Timetable(
      id: json['id'] as String,
      classRoomId: json['classRoomId'] as String,
      weekTimetable: (json['weekTimetable'] as List<dynamic>)
          .map((day) => DayTimetable.fromJson(day as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classRoomId': classRoomId,
      'weekTimetable': weekTimetable.map((day) => day.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
