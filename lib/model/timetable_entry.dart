import 'enums.dart';
import 'time_slot.dart';

class TimetableEntry {
  final String id;
  final WeekDay day;
  final TimeSlot timeSlot;
  final String? subjectCode;
  final String? facultyId;
  final String? classSectionId;
  final SlotType slotType;

  const TimetableEntry({
    required this.id,
    required this.day,
    required this.timeSlot,
    required this.slotType,
    this.subjectCode,
    this.facultyId,
    this.classSectionId,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      id: json['id'] as String,
      day: WeekDay.values.byName(json['day'] as String),
      timeSlot: TimeSlot.fromJson(json['timeSlot'] as Map<String, dynamic>),
      slotType: SlotType.values.byName(json['slotType'] as String),
      subjectCode: json['subjectCode'] as String?,
      facultyId: json['facultyId'] as String?,
      classSectionId: json['classSectionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day.name,
      'timeSlot': timeSlot.toJson(),
      'slotType': slotType.name,
      'subjectCode': subjectCode,
      'facultyId': facultyId,
      'classSectionId': classSectionId,
    };
  }

  TimetableEntry copyWith({
    String? id,
    WeekDay? day,
    TimeSlot? timeSlot,
    String? subjectCode,
    String? facultyId,
    String? classSectionId,
    SlotType? slotType,
  }) {
    return TimetableEntry(
      id: id ?? this.id,
      day: day ?? this.day,
      timeSlot: timeSlot ?? this.timeSlot,
      subjectCode: subjectCode ?? this.subjectCode,
      facultyId: facultyId ?? this.facultyId,
      classSectionId: classSectionId ?? this.classSectionId,
      slotType: slotType ?? this.slotType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
