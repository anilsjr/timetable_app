class ClassSection {
  final String fullId; // "CSE-AIML-T1"
  final String branch; // "CSE-AIML"
  final int year; // 3
  final String section; // "1"
  final String displayName; // "CSE-AIML - Year 3 - Sec 1"
  final int studentCount;
  final List<String> subjectCodes;
  final List<String> coordinators;

  const ClassSection({
    required this.fullId,
    required this.branch,
    required this.year,
    required this.section,
    required this.displayName,
    this.studentCount = 0,
    this.subjectCodes = const [],
    this.coordinators = const [],
  });

  String get id => fullId;
  String get className => branch;

  static String toStrictCapsSectionId(String raw) =>
      raw.trim().replaceAll(' ', '').toUpperCase();

  // Factory to parse your specific ID format
  factory ClassSection.fromId(String rawId,
      {int studentCount = 0,
      List<String> subjectCodes = const [],
      List<String> coordinators = const []}) {
    final officialId = toStrictCapsSectionId(rawId);
    final id = officialId.toLowerCase(); // only for parsing

    String branch = "";
    int year = 1;
    String section = "1";

    // Handle Special 1st Year Case (cse-1, cse-2)
    if (RegExp(r'^[a-z]+-\d$').hasMatch(id)) {
      final parts = id.split('-');
      branch = parts.first.toUpperCase();
      year = 1;
      section = parts.last;
    }
    // Handle Standard Case (cse-aiml-t1, cse-s1)
    else {
      final parts = id.split('-');
      final lastPart = parts.last; // "t1", "s1", "f1"

      // Combine everything before the last part as branch (e.g., "cse-aiml")
      branch = parts.sublist(0, parts.length - 1).join('-').toUpperCase();

      // Parse Year from first letter of last part
      String yearCode = lastPart[0].toLowerCase();
      if (yearCode == 't') {
        year = 3;
      } else if (yearCode == 's') {
        year = 2;
      } else if (yearCode == 'f') {
        year = 4; // Assuming 'F' for Final/4th year as per user's naming_convention.dart logic
      } else {
        year = 1;
      }

      // Parse Section from remaining digit
      section = lastPart.substring(1);
    }

    return ClassSection(
      fullId: officialId,
      branch: branch,
      year: year,
      section: section,
      displayName: "$branch - Year $year - Sec $section",
      studentCount: studentCount,
      subjectCodes: subjectCodes,
      coordinators: coordinators,
    );
  }

  factory ClassSection.fromJson(Map<String, dynamic> json) {
    return ClassSection(
      fullId: json['fullId'] as String,
      branch: json['branch'] as String,
      year: json['year'] as int,
      section: json['section'] as String,
      displayName: json['displayName'] as String,
      studentCount: json['studentCount'] as int? ?? 0,
      subjectCodes:
          (json['subjectCodes'] as List<dynamic>?)?.cast<String>() ?? [],
      coordinators:
          (json['coordinators'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullId': fullId,
      'branch': branch,
      'year': year,
      'section': section,
      'displayName': displayName,
      'studentCount': studentCount,
      'subjectCodes': subjectCodes,
      'coordinators': coordinators,
    };
  }

  ClassSection copyWith({
    String? fullId,
    String? branch,
    int? year,
    String? section,
    String? displayName,
    int? studentCount,
    List<String>? subjectCodes,
    List<String>? coordinators,
  }) {
    return ClassSection(
      fullId: fullId ?? this.fullId,
      branch: branch ?? this.branch,
      year: year ?? this.year,
      section: section ?? this.section,
      displayName: displayName ?? this.displayName,
      studentCount: studentCount ?? this.studentCount,
      subjectCodes: subjectCodes ?? this.subjectCodes,
      coordinators: coordinators ?? this.coordinators,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassSection &&
          runtimeType == other.runtimeType &&
          fullId == other.fullId;

  @override
  int get hashCode => fullId.hashCode;
}
