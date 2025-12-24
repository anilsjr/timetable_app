import 'package:flutter/foundation.dart';

import '../../model/class_room.dart';
import '../../model/subject.dart';
import '../../service/storage_service.dart';

/// ViewModel for managing class room data.
class ClassRoomViewModel extends ChangeNotifier {
  ClassRoomViewModel({required StorageService storageService})
    : _storageService = storageService {
    loadData();
  }

  final StorageService _storageService;

  List<ClassRoom> _classRooms = [];
  List<ClassRoom> get classRooms => _classRooms;

  List<Subject> _subjects = [];
  List<Subject> get subjects => _subjects;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Loads all class rooms and subjects from storage.
  void loadData() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _classRooms = _storageService.getAllClassRooms();
      _subjects = _storageService.getAllSubjects();
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gets subject names for given IDs.
  List<String> getSubjectNames(List<String> subjectIds) {
    return subjectIds.map((id) {
      final subject = _subjects.where((s) => s.id == id).firstOrNull;
      return subject?.name ?? 'Unknown';
    }).toList();
  }

  /// Adds a new class room.
  Future<bool> addClassRoom({
    required String className,
    required String section,
    required int studentCount,
    required List<String> subjectIds,
  }) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final classRoom = ClassRoom(
        id: id,
        className: className,
        section: section,
        studentCount: studentCount,
        subjectIds: subjectIds,
      );

      await _storageService.saveClassRoom(classRoom);
      loadData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add class: $e';
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing class room.
  Future<bool> updateClassRoom({
    required String id,
    required String className,
    required String section,
    required int studentCount,
    required List<String> subjectIds,
  }) async {
    try {
      final classRoom = ClassRoom(
        id: id,
        className: className,
        section: section,
        studentCount: studentCount,
        subjectIds: subjectIds,
      );

      await _storageService.saveClassRoom(classRoom);
      loadData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update class: $e';
      notifyListeners();
      return false;
    }
  }

  /// Deletes a class room by ID.
  Future<bool> deleteClassRoom(String id) async {
    try {
      await _storageService.deleteClassRoom(id);
      loadData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete class: $e';
      notifyListeners();
      return false;
    }
  }
}
