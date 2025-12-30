import '../../model/class_section.dart';
import '../../model/subject.dart';

abstract class ClassSectionRepository {
  void loadClassSections();
  List<ClassSection> getAllClassSections();
  List<Subject> getAllSubjects();
  ClassSection? getClassSection(String id);

  Future<bool> addClassSection({
    required String id,
    required int studentCount,
    required List<String> subjectCodes,
  });

  Future<bool> updateClassSection({
    required String id,
    required int studentCount,
    required List<String> subjectCodes,
  });

  Future<bool> deleteClassSection(String id);
}