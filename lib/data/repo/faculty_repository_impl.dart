import '../../domain/repo/faculty_repository.dart';
import '../../model/faculty.dart';
import '../../model/enums.dart';
import '../../model/time_slot.dart';
import '../../service/storage_service.dart';

class FacultyRepositoryImpl implements FacultyRepository {
  final StorageService _storageService;

  FacultyRepositoryImpl(this._storageService);

  @override
  Future<List<Faculty>> getAllFaculties() async {
    return _storageService.getAllFaculties();
  }

  @override
  Future<Faculty?> getFacultyById(String id) async {
    return _storageService.getFaculty(id);
  }

  @override
  Future<void> addFaculty(Faculty faculty) async {
    await _storageService.saveFaculty(faculty);
  }

  @override
  Future<void> updateFaculty(Faculty faculty) async {
    await _storageService.saveFaculty(faculty);
  }

  @override
  Future<void> deleteFaculty(String id) async {
    await _storageService.deleteFaculty(id);
  }

  @override
  Future<List<Faculty>> getAvailableFaculties(WeekDay day, TimeSlot timeSlot) async {
    final allFaculties = _storageService.getAllFaculties();
    final allTimetables = _storageService.getAllTimetables();
    
    final assignedFacultyIds = <String>{};
    
    for (final timetable in allTimetables) {
      final dayTimetable = timetable.weekTimetable.firstWhere(
        (d) => d.day == day,
        orElse: () => throw Exception('Day not found in timetable'),
      );
      
      for (final entry in dayTimetable.entries) {
        if (entry.timeSlot.id == timeSlot.id && entry.facultyId != null) {
          assignedFacultyIds.add(entry.facultyId!);
        }
      }
    }
    
    return allFaculties.where((f) => !assignedFacultyIds.contains(f.id)).toList();
  }
}
