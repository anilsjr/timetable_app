class Faculty {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<String> subjectIds;
  final bool isActive;

  const Faculty({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.subjectIds,
    this.isActive = true,
  });
}
