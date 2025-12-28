import 'package:flutter/foundation.dart';

import '../../model/class_section.dart';
import '../../model/subject.dart';
import '../../service/storage_service.dart';

/// ViewModel for managing class room data.
class ClassSectionViewModel extends ChangeNotifier {
  ClassSectionViewModel({required StorageService storageService})
    : _storageService = storageService {
    loadData();
  }

  final StorageService _storageService;

  List<ClassSection> _classSections = [];
  List<ClassSection> get classSections => _classSections;

  List<Subject> _subjects = [];
  List<Subject> get subjects => _subjects;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Loads all class sections and subjects from storage.
  void loadData() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _classSections = _storageService.getAllClassSections();
      _subjects = _storageService.getAllSubjects();
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gets subject names for given IDs.
  List<String> getSubjectNames(List<String> subjectCodes) {
    return subjectCodes.map((code) {
      final subject = _subjects.where((s) => s.code == code).firstOrNull;
      return subject?.name ?? 'Unknown';
    }).toList();
  }

  /// Adds a new class section.
  Future<bool> addClassSection({
    required String id,
    required int studentCount,
    required List<String> subjectCodes,
  }) async {
    try {
      final classSection = ClassSection.fromId(
        id,
        studentCount: studentCount,
        subjectCodes: subjectCodes,
      );

      await _storageService.saveClassSection(classSection);
      loadData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add class: $e';
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing class section.
  Future<bool> updateClassSection({
    required String id,
    required int studentCount,
    required List<String> subjectCodes,
  }) async {
    try {
      final classSection = ClassSection.fromId(
        id,
        studentCount: studentCount,
        subjectCodes: subjectCodes,
      );

      await _storageService.saveClassSection(classSection);
      loadData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update class: $e';
      notifyListeners();
      return false;
    }
  }

  /// Deletes a class room by ID.
  Future<bool> deleteClassSection(String id) async {
    try {
      await _storageService.deleteClassSection(id);
      loadData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete class: $e';
      notifyListeners();
      return false;
    }
  }
}
