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
}
