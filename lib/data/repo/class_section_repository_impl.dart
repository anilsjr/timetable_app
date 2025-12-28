import '../../domain/repo/class_section_repository.dart';
import '../../model/class_section.dart';
import '../../model/subject.dart';
import '../../service/storage_service.dart';

class ClassSectionRepositoryImpl implements ClassSectionRepository {
  final StorageService _storageService;

  ClassSectionRepositoryImpl(this._storageService);

  @override
  Future<List<ClassSection>> getAllClassSections() async {
    return _storageService.getAllClassSections();
  }

  @override
  Future<ClassSection?> getClassSectionById(String id) async {
    return _storageService.getClassSection(id);
  }

  @override
  Future<void> addClassSection(ClassSection classSection) async {
    await _storageService.saveClassSection(classSection);
  }

  @override
  Future<void> updateClassSection(ClassSection classSection) async {
    await _storageService.saveClassSection(classSection);
  }

  @override
  Future<void> deleteClassSection(String id) async {
    await _storageService.deleteClassSection(id);
  }

  @override
  Future<List<Subject>> getSubjectsOfClass(String classSectionId) async {
    final classSection = _storageService.getClassSection(classSectionId);
    if (classSection == null) return [];
    
    final allSubjects = _storageService.getAllSubjects();
    return allSubjects.where((s) => classSection.subjectCodes.contains(s.code)).toList();
  }
}
