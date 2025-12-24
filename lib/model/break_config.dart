import 'enums.dart';

class BreakConfig {
  final String id;
  final String name;
  final int durationMinutes;
  final SlotType type;

  const BreakConfig({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.type,
  });

  factory BreakConfig.fromJson(Map<String, dynamic> json) {
    return BreakConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      durationMinutes: json['durationMinutes'] as int,
      type: SlotType.values.byName(json['type'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'durationMinutes': durationMinutes,
      'type': type.name,
    };
  }
}
