import 'package:flutter/foundation.dart';

import '../../domain/repo/subject_repository.dart';
import '../../model/subject.dart';

/// ViewModel for managing subject data.
class SubjectViewModel extends ChangeNotifier {
  SubjectViewModel({required SubjectRepository subjectRepository})
    : _subjectRepository = subjectRepository {
    loadSubjects();
  }

  final SubjectRepository _subjectRepository;

  List<Subject> _subjects = [];
  List<Subject> get subjects => _subjects;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Loads all subjects from storage.
  void loadSubjects() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _subjects = _subjectRepository.getAllSubjects();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load subjects: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new subject.
  Future<bool> addSubject({
    required String name,
    required String code,
    required int weeklyLectures,
    bool isLab = false,
  }) async {
    try {
      final result = await _subjectRepository.addSubject(
        name: name,
        code: code,
        weeklyLectures: weeklyLectures,
        isLab: isLab,
      );

      if (result) {
        loadSubjects();
      }
      return result;
    } catch (e) {
      _errorMessage = 'Failed to add subject: $e';
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing subject.
  Future<bool> updateSubject({
    required String name,
    required String code,
    required int weeklyLectures,
    bool isLab = false,
  }) async {
    try {
      final result = await _subjectRepository.updateSubject(
        name: name,
        code: code,
        weeklyLectures: weeklyLectures,
        isLab: isLab,
      );

      if (result) {
        loadSubjects();
      }
      return result;
    } catch (e) {
      _errorMessage = 'Failed to update subject: $e';
      notifyListeners();
      return false;
    }
  }

  /// Deletes a subject by code.
  Future<bool> deleteSubject(String code) async {
    try {
      final result = await _subjectRepository.deleteSubject(code);
      
      if (result) {
        loadSubjects();
      }
      return result;
    } catch (e) {
      _errorMessage = 'Failed to delete subject: $e';
      notifyListeners();
      return false;
    }
  }

  /// Gets a subject by code.
  Subject? getSubject(String code) {
    return _subjectRepository.getSubject(code);
  }
}
