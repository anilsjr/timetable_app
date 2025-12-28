import 'day_timetable.dart';

class Timetable {
  final String id;
  final String classSectionId;
  final List<DayTimetable> weekTimetable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Timetable({
    required this.id,
    required this.classSectionId,
    required this.weekTimetable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Timetable.fromJson(Map<String, dynamic> json) {
    return Timetable(
      id: json['id'] as String,
      classSectionId: json['classSectionId'] as String,
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
      'classSectionId': classSectionId,
      'weekTimetable': weekTimetable.map((day) => day.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Timetable copyWith({
    String? id,
    String? classSectionId,
    List<DayTimetable>? weekTimetable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Timetable(
      id: id ?? this.id,
      classSectionId: classSectionId ?? this.classSectionId,
      weekTimetable: weekTimetable ?? this.weekTimetable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Timetable && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
