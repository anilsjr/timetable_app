import '../../domain/repo/faculty_repository.dart';
import '../../model/faculty.dart';
import '../../model/subject.dart';
import '../../service/storage_service.dart';

/// Concrete implementation of [FacultyRepository] using [StorageService].
class FacultyRepositoryImpl implements FacultyRepository {
  FacultyRepositoryImpl({required StorageService storageService})
      : _storageService = storageService;

  final StorageService _storageService;

  @override
  void loadFaculties() {
    _storageService.getAllFaculties();
  }

  @override
  List<Faculty> getAllFaculties() {
    return _storageService.getAllFaculties();
  }

  @override
  List<Subject> getAllSubjects() {
    return _storageService.getAllSubjects();
  }

  @override
  Faculty? getFaculty(String id) {
    return _storageService.getFaculty(id);
  }

  @override
  Future<bool> addFaculty({
    required String name,
    required String shortName,
    required String computerCode,
    String? email,
    String? phone,
    required List<String> subjectCodes,
    bool isActive = true,
  }) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final faculty = Faculty(
        id: id,
        name: name,
        shortName: shortName,
        computerCode: computerCode,
        email: email,
        phone: phone,
        subjectCodes: subjectCodes,
        isActive: isActive,
      );
      await _storageService.saveFaculty(faculty);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateFaculty({
    required String id,
    required String name,
    required String shortName,
    required String computerCode,
    String? email,
    String? phone,
    required List<String> subjectCodes,
    bool isActive = true,
  }) async {
    try {
      final faculty = Faculty(
        id: id,
        name: name,
        shortName: shortName,
        computerCode: computerCode,
        email: email,
        phone: phone,
        subjectCodes: subjectCodes,
        isActive: isActive,
      );
      await _storageService.saveFaculty(faculty);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteFaculty(String id) async {
    try {
      await _storageService.deleteFaculty(id);
      return true;
    } catch (e) {
      return false;
    }
  }
}