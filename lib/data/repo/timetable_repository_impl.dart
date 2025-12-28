import '../../domain/repo/timetable_repository.dart';
import '../../model/timetable.dart';
import '../../model/enums.dart';
import '../../model/timetable_entry.dart';
import '../../model/day_timetable.dart';
import '../../service/storage_service.dart';

class TimetableRepositoryImpl implements TimetableRepository {
  final StorageService _storageService;

  TimetableRepositoryImpl(this._storageService);

  @override
  Future<List<Timetable>> getAllTimetables() async {
    return _storageService.getAllTimetables();
  }

  @override
  Future<Timetable?> getTimetableById(String id) async {
    return _storageService.getTimetable(id);
  }

  @override
  Future<Timetable?> getTimetableByClassSectionId(String classSectionId) async {
    return _storageService.getTimetableByClassSection(classSectionId);
  }

  @override
  Future<void> saveTimetable(Timetable timetable) async {
    await _storageService.saveTimetable(timetable);
  }

  @override
  Future<void> deleteTimetable(String id) async {
    await _storageService.deleteTimetable(id);
  }

  @override
  Future<void> setFacultyForSlot({
    required String timetableId,
    required WeekDay day,
    required String timeSlotId,
    required String facultyId,
    required String subjectCode,
  }) async {
    final timetable = _storageService.getTimetable(timetableId);
    if (timetable == null) return;

    final updatedWeekTimetable = timetable.weekTimetable.map((dayTimetable) {
      if (dayTimetable.day == day) {
        final updatedEntries = dayTimetable.entries.map((entry) {
          if (entry.timeSlot.id == timeSlotId) {
            return entry.copyWith(
              subjectCode: subjectCode,
              facultyId: facultyId,
            );
          }
          return entry;
        }).toList();
        return dayTimetable.copyWith(entries: updatedEntries);
      }
      return dayTimetable;
    }).toList();

    final updatedTimetable = timetable.copyWith(
      weekTimetable: updatedWeekTimetable,
      updatedAt: DateTime.now(),
    );

    await _storageService.saveTimetable(updatedTimetable);
  }
}
