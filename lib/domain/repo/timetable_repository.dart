import '../../model/timetable.dart';
import '../../model/enums.dart';

abstract class TimetableRepository {
  Future<List<Timetable>> getAllTimetables();
  Future<Timetable?> getTimetableById(String id);
  Future<Timetable?> getTimetableByClassSectionId(String classSectionId);
  Future<void> saveTimetable(Timetable timetable);
  Future<void> deleteTimetable(String id);
  
  /// Sets a faculty and subject for a specific slot in a timetable.
  Future<void> setFacultyForSlot({
    required String timetableId,
    required WeekDay day,
    required String timeSlotId,
    required String facultyId,
    required String subjectCode,
  });
}
