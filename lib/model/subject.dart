class Subject {
  final String id;
  final String name;
  final String code;
  final int weeklyLectures;
  final bool isLab;

  const Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.weeklyLectures,
    this.isLab = false,
  });
}
