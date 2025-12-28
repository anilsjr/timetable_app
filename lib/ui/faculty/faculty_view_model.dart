import 'package:flutter/foundation.dart';

import '../../model/faculty.dart';
import '../../model/subject.dart';
import '../../service/storage_service.dart';

/// ViewModel for managing faculty data.
class FacultyViewModel extends ChangeNotifier {
  FacultyViewModel({required StorageService storageService})
    : _storageService = storageService {
    loadData();
  }

  final StorageService _storageService;

  List<Faculty> _faculties = [];
  List<Faculty> get faculties => _faculties;

  List<Subject> _subjects = [];
  List<Subject> get subjects => _subjects;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Loads all faculties and subjects from storage.
  void loadData() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _faculties = _storageService.getAllFaculties();
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

  /// Adds a new faculty.
  Future<bool> addFaculty({
    required String name,
    required String shortName,
    required String computerCode,
    String? email,
    String? phone,
    required List<String> subjectCodes,
    bool isActive = true,
  }) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final faculty = Faculty(
        id: id,
        name: name,
        shortName: shortName,
        computerCode: computerCode,
        email: email,
        phone: phone,
        subjectCodes: subjectCodes,
        isActive: isActive,
      );

      await _storageService.saveFaculty(faculty);
      loadData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add faculty: $e';
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing faculty.
  Future<bool> updateFaculty({
    required String id,
    required String name,
    required String shortName,
    required String computerCode,
    String? email,
    String? phone,
    required List<String> subjectCodes,
    bool isActive = true,
  }) async {
    try {
      final faculty = Faculty(
        id: id,
        name: name,
        shortName: shortName,
        computerCode: computerCode,
        email: email,
        phone: phone,
        subjectCodes: subjectCodes,
        isActive: isActive,
      );

      await _storageService.saveFaculty(faculty);
      loadData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update faculty: $e';
      notifyListeners();
      return false;
    }
  }

  /// Deletes a faculty by ID.
  Future<bool> deleteFaculty(String id) async {
    try {
      await _storageService.deleteFaculty(id);
      loadData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete faculty: $e';
      notifyListeners();
      return false;
    }
  }
}
