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

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      weeklyLectures: json['weeklyLectures'] as int,
      isLab: json['isLab'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'weeklyLectures': weeklyLectures,
      'isLab': isLab,
    };
  }
}
