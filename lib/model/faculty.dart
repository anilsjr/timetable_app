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

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      subjectIds: (json['subjectIds'] as List<dynamic>).cast<String>(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'subjectIds': subjectIds,
      'isActive': isActive,
    };
  }
}
