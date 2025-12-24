import 'enums.dart';

class TimeSlot {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final SlotType type;
  final int durationMinutes;

  const TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.durationMinutes,
  });
}
