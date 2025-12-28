class Subject {
  final String name;
  final String code;
  final int weeklyLectures;
  final bool isLab;

  const Subject({
    required this.name,
    required this.code,
    required this.weeklyLectures,
    this.isLab = false,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      name: json['name'] as String,
      code: json['code'] as String,
      weeklyLectures: json['weeklyLectures'] as int,
      isLab: json['isLab'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'weeklyLectures': weeklyLectures,
      'isLab': isLab,
    };
  }

  Subject copyWith({
    String? name,
    String? code,
    int? weeklyLectures,
    bool? isLab,
  }) {
    return Subject(
      name: name ?? this.name,
      code: code ?? this.code,
      weeklyLectures: weeklyLectures ?? this.weeklyLectures,
      isLab: isLab ?? this.isLab,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}
