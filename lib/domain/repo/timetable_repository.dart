import '../../model/class_section.dart';
import '../../model/faculty.dart';
import '../../model/subject.dart';
import '../../model/timetable.dart';

abstract class TimetableRepository {
  void loadTimetables();
  List<Timetable> getAllTimetables();
  List<ClassSection> getAllClassSections();
  List<Subject> getAllSubjects();
  List<Faculty> getAllFaculties();
  Timetable? getTimetable(String id);
  Timetable? getTimetableByClassSection(String classSectionId);

  Future<bool> addTimetable(Timetable timetable);
  Future<bool> updateTimetable(Timetable timetable);
  Future<bool> deleteTimetable(String id);
}