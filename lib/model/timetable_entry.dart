import 'enums.dart';
import 'time_slot.dart';

class TimetableEntry {
  final String id;
  final WeekDay day;
  final TimeSlot timeSlot;
  final String? subjectId;
  final String? facultyId;
  final String? classRoomId;
  final SlotType slotType;

  const TimetableEntry({
    required this.id,
    required this.day,
    required this.timeSlot,
    required this.slotType,
    this.subjectId,
    this.facultyId,
    this.classRoomId,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      id: json['id'] as String,
      day: WeekDay.values.byName(json['day'] as String),
      timeSlot: TimeSlot.fromJson(json['timeSlot'] as Map<String, dynamic>),
      slotType: SlotType.values.byName(json['slotType'] as String),
      subjectId: json['subjectId'] as String?,
      facultyId: json['facultyId'] as String?,
      classRoomId: json['classRoomId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day.name,
      'timeSlot': timeSlot.toJson(),
      'slotType': slotType.name,
      'subjectId': subjectId,
      'facultyId': facultyId,
      'classRoomId': classRoomId,
    };
  }
}
