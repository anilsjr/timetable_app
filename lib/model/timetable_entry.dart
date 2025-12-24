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
}
