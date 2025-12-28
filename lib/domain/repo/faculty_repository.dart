import '../../model/faculty.dart';
import '../../model/enums.dart';
import '../../model/time_slot.dart';

abstract class FacultyRepository {
  Future<List<Faculty>> getAllFaculties();
  Future<Faculty?> getFacultyById(String id);
  Future<void> addFaculty(Faculty faculty);
  Future<void> updateFaculty(Faculty faculty);
  Future<void> deleteFaculty(String id);
  
  /// Returns a list of faculties who are not assigned to any class during the given time slot.
  Future<List<Faculty>> getAvailableFaculties(WeekDay day, TimeSlot timeSlot);
}
