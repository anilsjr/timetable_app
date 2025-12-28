import '../../model/class_section.dart';
import '../../model/subject.dart';

abstract class ClassSectionRepository {
  Future<List<ClassSection>> getAllClassSections();
  Future<ClassSection?> getClassSectionById(String id);
  Future<void> addClassSection(ClassSection classSection);
  Future<void> updateClassSection(ClassSection classSection);
  Future<void> deleteClassSection(String id);
  
  /// Returns all subjects assigned to a specific class section.
  Future<List<Subject>> getSubjectsOfClass(String classSectionId);
}
