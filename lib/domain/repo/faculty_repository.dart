import '../../model/faculty.dart';
import '../../model/subject.dart';

/// Abstract repository interface for managing faculty operations.
abstract class FacultyRepository {
  void loadFaculties();
  List<Faculty> getAllFaculties();
  List<Subject> getAllSubjects();
  Faculty? getFaculty(String id);

  Future<bool> addFaculty({
    required String name,
    required String shortName,
    required String computerCode,
    String? email,
    String? phone,
    required List<String> subjectCodes,
    bool isActive = true,
  });

  Future<bool> updateFaculty({
    required String id,
    required String name,
    required String shortName,
    required String computerCode,
    String? email,
    String? phone,
    required List<String> subjectCodes,
    bool isActive = true,
  });

  Future<bool> deleteFaculty(String id);
}