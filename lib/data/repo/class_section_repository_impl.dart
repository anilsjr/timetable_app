import '../../domain/repo/class_section_repository.dart';
import '../../model/class_section.dart';
import '../../model/subject.dart';
import '../../service/storage_service.dart';

class ClassSectionRepositoryImpl implements ClassSectionRepository {
  ClassSectionRepositoryImpl({required StorageService storageService})
      : _storageService = storageService;

  final StorageService _storageService;

  @override
  void loadClassSections() {
    _storageService.getAllClassSections();
  }

  @override
  List<ClassSection> getAllClassSections() {
    return _storageService.getAllClassSections();
  }

  @override
  List<Subject> getAllSubjects() {
    return _storage_service_getAllSubjects();
  }

  // Helper to avoid analyzer warning if service method changed name
  List<Subject> _storage_service_getAllSubjects() => _storageService.getAllSubjects();

  @override
  ClassSection? getClassSection(String id) {
    return _storageService.getClassSection(id);
  }

  @override
  Future<bool> addClassSection({
    required String id,
    required int studentCount,
    required List<String> subjectCodes,
  }) async {
    try {
      final classSection = ClassSection.fromId(
        id,
        studentCount: studentCount,
        subjectCodes: subjectCodes,
      );
      await _storageService.saveClassSection(classSection);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateClassSection({
    required String id,
    required int studentCount,
    required List<String> subjectCodes,
  }) async {
    try {
      final classSection = ClassSection.fromId(
        id,
        studentCount: studentCount,
        subjectCodes: subjectCodes,
      );
      await _storageService.saveClassSection(classSection);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteClassSection(String id) async {
    try {
      await _storageService.deleteClassSection(id);
      return true;
    } catch (e) {
      return false;
    }
  }
}