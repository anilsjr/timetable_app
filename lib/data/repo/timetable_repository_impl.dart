import '../../domain/repo/timetable_repository.dart';
import '../../model/class_section.dart';
import '../../model/faculty.dart';
import '../../model/subject.dart';
import '../../model/timetable.dart';
import '../../service/storage_service.dart';

class TimetableRepositoryImpl implements TimetableRepository {
  TimetableRepositoryImpl({required StorageService storageService})
      : _storageService = storageService;

  final StorageService _storageService;

  @override
  void loadTimetables() {
    _storageService.getAllTimetables();
  }

  @override
  List<Timetable> getAllTimetables() {
    return _storageService.getAllTimetables();
  }

  @override
  List<ClassSection> getAllClassSections() {
    return _storageService.getAllClassSections();
  }

  @override
  List<Subject> getAllSubjects() {
    return _storageService.getAllSubjects();
  }

  @override
  List<Faculty> getAllFaculties() {
    return _storageService.getAllFaculties();
  }

  @override
  Timetable? getTimetable(String id) {
    return _storageService.getTimetable(id);
  }

  @override
  Timetable? getTimetableByClassSection(String classSectionId) {
    final allTimetables = _storageService.getAllTimetables();
    try {
      return allTimetables.firstWhere(
        (timetable) => timetable.classSectionId == classSectionId,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> addTimetable(Timetable timetable) async {
    try {
      await _storageService.saveTimetable(timetable);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateTimetable(Timetable timetable) async {
    try {
      await _storageService.saveTimetable(timetable);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteTimetable(String id) async {
    try {
      await _storageService.deleteTimetable(id);
      return true;
    } catch (e) {
      return false;
    }
  }
}