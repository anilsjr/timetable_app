class ClassRoom {
  final String id;
  final String className;
  final String section;
  final int studentCount;
  final List<String> subjectIds;

  const ClassRoom({
    required this.id,
    required this.className,
    required this.section,
    required this.studentCount,
    required this.subjectIds,
  });

  factory ClassRoom.fromJson(Map<String, dynamic> json) {
    return ClassRoom(
      id: json['id'] as String,
      className: json['className'] as String,
      section: json['section'] as String,
      studentCount: json['studentCount'] as int,
      subjectIds: (json['subjectIds'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'className': className,
      'section': section,
      'studentCount': studentCount,
      'subjectIds': subjectIds,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassRoom && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
