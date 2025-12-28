import '../../domain/repo/subject_repository.dart';
import '../../model/subject.dart';
import '../../service/storage_service.dart';

class SubjectRepositoryImpl implements SubjectRepository {
  final StorageService _storageService;

  SubjectRepositoryImpl(this._storageService);

  @override
  Future<List<Subject>> getAllSubjects() async {
    return _storageService.getAllSubjects();
  }

  @override
  Future<Subject?> getSubjectByCode(String code) async {
    return _storageService.getSubject(code);
  }

  @override
  Future<void> addSubject(Subject subject) async {
    await _storageService.saveSubject(subject);
  }

  @override
  Future<void> updateSubject(Subject subject) async {
    await _storageService.saveSubject(subject);
  }

  @override
  Future<void> deleteSubject(String code) async {
    await _storageService.deleteSubject(code);
  }

  @override
  Future<List<Subject>> getSubjectsByCodes(List<String> codes) async {
    final allSubjects = _storageService.getAllSubjects();
    return allSubjects.where((s) => codes.contains(s.code)).toList();
  }
}
