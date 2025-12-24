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
}
