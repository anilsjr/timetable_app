import '../../model/subject.dart';

abstract class SubjectRepository {
  Future<List<Subject>> getAllSubjects();
  Future<Subject?> getSubjectByCode(String code);
  Future<void> addSubject(Subject subject);
  Future<void> updateSubject(Subject subject);
  Future<void> deleteSubject(String code);
  Future<List<Subject>> getSubjectsByCodes(List<String> codes);
}
