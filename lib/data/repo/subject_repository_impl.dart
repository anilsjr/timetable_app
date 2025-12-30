import '../../domain/repo/subject_repository.dart';
import '../../model/subject.dart';
import '../../service/storage_service.dart';

/// Concrete implementation of [SubjectRepository] using [StorageService].
class SubjectRepositoryImpl implements SubjectRepository {
  SubjectRepositoryImpl({required StorageService storageService})
      : _storageService = storageService;

  final StorageService _storageService;

  @override
  void loadSubjects() {
    _storageService.getAllSubjects();
  }

  @override
  List<Subject> getAllSubjects() {
    return _storageService.getAllSubjects();
  }

  @override
  Future<bool> addSubject({
    required String name,
    required String code,
    required int weeklyLectures,
    bool isLab = false,
  }) async {
    try {
      final subject = Subject(
        name: name,
        code: code,
        weeklyLectures: weeklyLectures,
        isLab: isLab,
      );
      await _storageService.saveSubject(subject);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateSubject({
    required String name,
    required String code,
    required int weeklyLectures,
    bool isLab = false,
  }) async {
    try {
      final subject = Subject(
        name: name,
        code: code,
        weeklyLectures: weeklyLectures,
        isLab: isLab,
      );
      await _storageService.saveSubject(subject);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteSubject(String code) async {
    try {
      await _storageService.deleteSubject(code);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Subject? getSubject(String code) {
    return _storageService.getSubject(code);
  }
}
