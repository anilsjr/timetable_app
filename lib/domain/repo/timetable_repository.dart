import '../../model/class_section.dart';
import '../../model/faculty.dart';
import '../../model/subject.dart';
import '../../model/timetable.dart';

/// Abstract repository interface for managing timetable operations.
abstract class TimetableRepository {
  /// Loads all timetables from storage.
  void loadTimetables();

  /// Gets all timetables.
  ///
  /// Returns a list of all timetables.
  List<Timetable> getAllTimetables();

  /// Gets all class sections. 
  ///
  /// Returns a list of all class sections. 
  List<ClassSection> getAllClassSections();

  /// Gets all subjects. 
  ///
  /// Returns a list of all subjects.
  List<Subject> getAllSubjects();

  /// Gets all faculties.
  ///
  /// Returns a list of all faculties.
  List<Faculty> getAllFaculties();

  /// Gets a timetable by ID. 
  ///
  /// Returns the timetable if found, otherwise returns `null`.
  Timetable? getTimetable(String id);

  /// Gets a timetable by class section ID. 
  ///
  /// Returns the timetable if found, otherwise returns `null`.
  Timetable? getTimetableByClassSection(String classSectionId);

  /// Adds a new timetable. 
  ///
  /// Returns `true` if the timetable was successfully added, `false` otherwise.
  Future<bool> addTimetable(Timetable timetable);

  /// Updates an existing timetable.
  ///
  /// Returns `true` if the timetable was successfully updated, `false` otherwise.
  Future<bool> updateTimetable(Timetable timetable);

  /// Deletes a timetable by ID.
  ///
  /// Returns `true` if the timetable was successfully deleted, `false` otherwise.
  Future<bool> deleteTimetable(String id);
}