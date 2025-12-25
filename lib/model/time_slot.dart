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

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      type: SlotType.values.byName(json['type'] as String),
      durationMinutes: json['durationMinutes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'type': type.name,
      'durationMinutes': durationMinutes,
    };
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSlot && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;}
