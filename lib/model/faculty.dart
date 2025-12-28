class Faculty {
  final String id;
  final String name;
  final String shortName;
  final String computerCode;
  final String? email;
  final String? phone;
  final List<String> subjectCodes;
  final bool isActive;

  const Faculty({
    required this.id,
    required this.name,
    required this.shortName,
    required this.computerCode,
    this.email,
    this.phone,
    required this.subjectCodes,
    this.isActive = true,
  });

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String? ?? '',
      computerCode: json['computerCode'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      subjectCodes: (json['subjectCodes'] as List<dynamic>).cast<String>(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'computerCode': computerCode,
      'email': email,
      'phone': phone,
      'subjectCodes': subjectCodes,
      'isActive': isActive,
    };
  }

  Faculty copyWith({
    String? id,
    String? name,
    String? shortName,
    String? computerCode,
    String? email,
    String? phone,
    List<String>? subjectCodes,
    bool? isActive,
  }) {
    return Faculty(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      computerCode: computerCode ?? this.computerCode,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      subjectCodes: subjectCodes ?? this.subjectCodes,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Faculty && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
