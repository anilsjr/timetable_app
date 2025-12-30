import '../../model/subject.dart';

/// Abstract repository interface for managing subject operations.
abstract class SubjectRepository {
  /// Loads all subjects from storage.
  void loadSubjects();

  /// Gets all subjects.
  ///
  /// Returns a list of all subjects.
  List<Subject> getAllSubjects();

  /// Adds a new subject.
  ///
  /// Returns `true` if the subject was successfully added, `false` otherwise.
  Future<bool> addSubject({
    required String name,
    required String code,
    required int weeklyLectures,
    bool isLab = false,
  });

  /// Updates an existing subject.
  ///
  /// Returns `true` if the subject was successfully updated, `false` otherwise.
  Future<bool> updateSubject({
    required String name,
    required String code,
    required int weeklyLectures,
    bool isLab = false,
  });

  /// Deletes a subject by code.
  ///
  /// Returns `true` if the subject was successfully deleted, `false` otherwise.
  Future<bool> deleteSubject(String code);

  /// Gets a subject by code.
  ///
  /// Returns the subject if found, otherwise returns `null`.
  Subject? getSubject(String code);
}
