import 'package:flutter/foundation.dart';

import '../../model/subject.dart';
import '../../service/storage_service.dart';

/// ViewModel for managing subject data.
class SubjectViewModel extends ChangeNotifier {
  SubjectViewModel({required StorageService storageService})
    : _storageService = storageService {
    loadSubjects();
  }

  final StorageService _storageService;

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
      _subjects = _storageService.getAllSubjects();
    } catch (e) {
      _errorMessage = 'Failed to load subjects: $e';
    } finally {
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
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final subject = Subject(
        id: id,
        name: name,
        code: code,
        weeklyLectures: weeklyLectures,
        isLab: isLab,
      );

      await _storageService.saveSubject(subject);
      loadSubjects();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add subject: $e';
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing subject.
  Future<bool> updateSubject({
    required String id,
    required String name,
    required String code,
    required int weeklyLectures,
    bool isLab = false,
  }) async {
    try {
      final subject = Subject(
        id: id,
        name: name,
        code: code,
        weeklyLectures: weeklyLectures,
        isLab: isLab,
      );

      await _storageService.saveSubject(subject);
      loadSubjects();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update subject: $e';
      notifyListeners();
      return false;
    }
  }

  /// Deletes a subject by ID.
  Future<bool> deleteSubject(String id) async {
    try {
      await _storageService.deleteSubject(id);
      loadSubjects();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete subject: $e';
      notifyListeners();
      return false;
    }
  }

  /// Gets a subject by ID.
  Subject? getSubject(String id) {
    try {
      return _subjects.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
