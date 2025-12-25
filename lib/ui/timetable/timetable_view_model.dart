import 'package:flutter/foundation.dart';

import '../../model/class_room.dart';
import '../../model/day_timetable.dart';
import '../../model/enums.dart';
import '../../model/faculty.dart';
import '../../model/subject.dart';
import '../../model/time_slot.dart';
import '../../model/timetable.dart';
import '../../model/timetable_entry.dart';
import '../../service/storage_service.dart';

/// ViewModel for managing timetable data.
class TimetableViewModel extends ChangeNotifier {
  TimetableViewModel({required StorageService storageService})
    : _storageService = storageService {
    loadData();
  }

  final StorageService _storageService;

  List<Timetable> _timetables = [];
  List<Timetable> get timetables => _timetables;

  List<ClassRoom> _classRooms = [];
  List<ClassRoom> get classRooms => _classRooms;

  List<Subject> _subjects = [];
  List<Subject> get subjects => _subjects;

  List<Faculty> _faculties = [];
  List<Faculty> get faculties => _faculties;

  ClassRoom? _selectedClassRoom;
  ClassRoom? get selectedClassRoom => _selectedClassRoom;

  Timetable? _currentTimetable;
  Timetable? get currentTimetable => _currentTimetable;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Loads all required data from storage.
  void loadData() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _timetables = _storageService.getAllTimetables();
      _classRooms = _storageService.getAllClassRooms();
      _subjects = _storageService.getAllSubjects();
      _faculties = _storageService.getAllFaculties();

      // Refresh selected class room instance if it exists
      if (_selectedClassRoom != null) {
        _selectedClassRoom = _classRooms
            .where((c) => c.id == _selectedClassRoom!.id)
            .firstOrNull;
        if (_selectedClassRoom != null) {
          _currentTimetable = _storageService.getTimetableByClassRoom(
            _selectedClassRoom!.id,
          );
        } else {
          _currentTimetable = null;
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Selects a class room and loads its timetable.
  void selectClassRoom(ClassRoom? classRoom) {
    _selectedClassRoom = classRoom;
    if (classRoom != null) {
      _currentTimetable = _storageService.getTimetableByClassRoom(classRoom.id);
    } else {
      _currentTimetable = null;
    }
    notifyListeners();
  }

  /// Gets subject by ID.
  Subject? getSubject(String? id) {
    if (id == null) return null;
    return _subjects.where((s) => s.id == id).firstOrNull;
  }

  /// Gets faculty by ID.
  Faculty? getFaculty(String? id) {
    if (id == null) return null;
    return _faculties.where((f) => f.id == id).firstOrNull;
  }

  /// Gets class room by ID.
  ClassRoom? getClassRoom(String? id) {
    if (id == null) return null;
    return _classRooms.where((c) => c.id == id).firstOrNull;
  }

  /// Gets active faculties for a subject.
  List<Faculty> getFacultiesForSubject(String subjectId) {
    return _faculties
        .where((f) => f.isActive && f.subjectIds.contains(subjectId))
        .toList();
  }

  /// Creates or updates a timetable for the selected class.
  Future<bool> saveTimetable(List<DayTimetable> weekTimetable) async {
    if (_selectedClassRoom == null) {
      _errorMessage = 'Please select a class first';
      notifyListeners();
      return false;
    }

    try {
      final now = DateTime.now();
      final timetable = Timetable(
        id: _currentTimetable?.id ?? now.millisecondsSinceEpoch.toString(),
        classRoomId: _selectedClassRoom!.id,
        weekTimetable: weekTimetable,
        createdAt: _currentTimetable?.createdAt ?? now,
        updatedAt: now,
      );

      await _storageService.saveTimetable(timetable);
      _currentTimetable = timetable;
      loadData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save timetable: $e';
      notifyListeners();
      return false;
    }
  }

  /// Adds or updates an entry in the current timetable.
  Future<bool> saveEntry(TimetableEntry entry) async {
    if (_selectedClassRoom == null) {
      _errorMessage = 'Please select a class first';
      notifyListeners();
      return false;
    }

    try {
      List<DayTimetable> weekTimetable;

      if (_currentTimetable != null) {
        weekTimetable = _currentTimetable!.weekTimetable.map((dayTimetable) {
          if (dayTimetable.day == entry.day) {
            // Remove existing entry with same ID if exists
            final entries = dayTimetable.entries
                .where((e) => e.id != entry.id)
                .toList();
            entries.add(entry);
            // Sort by start time
            entries.sort(
              (a, b) => a.timeSlot.startTime.compareTo(b.timeSlot.startTime),
            );
            return DayTimetable(day: dayTimetable.day, entries: entries);
          }
          return dayTimetable;
        }).toList();

        // If day doesn't exist, add it
        if (!weekTimetable.any((dt) => dt.day == entry.day)) {
          weekTimetable.add(DayTimetable(day: entry.day, entries: [entry]));
        }
      } else {
        weekTimetable = [
          DayTimetable(day: entry.day, entries: [entry]),
        ];
      }

      return await saveTimetable(weekTimetable);
    } catch (e) {
      _errorMessage = 'Failed to save entry: $e';
      notifyListeners();
      return false;
    }
  }

  /// Deletes an entry from the current timetable.
  Future<bool> deleteEntry(WeekDay day, String timeSlotId) async {
    if (_currentTimetable == null) {
      _errorMessage = 'No timetable found';
      notifyListeners();
      return false;
    }

    try {
      final weekTimetable = _currentTimetable!.weekTimetable.map((
        dayTimetable,
      ) {
        if (dayTimetable.day == day) {
          final entries = dayTimetable.entries
              .where((e) => e.timeSlot.id != timeSlotId)
              .toList();
          return DayTimetable(day: dayTimetable.day, entries: entries);
        }
        return dayTimetable;
      }).toList();

      return await saveTimetable(weekTimetable);
    } catch (e) {
      _errorMessage = 'Failed to delete entry: $e';
      notifyListeners();
      return false;
    }
  }

  /// Deletes the entire timetable for the selected class.
  Future<bool> deleteTimetable() async {
    if (_currentTimetable == null) {
      _errorMessage = 'No timetable to delete';
      notifyListeners();
      return false;
    }

    try {
      await _storageService.deleteTimetable(_currentTimetable!.id);
      _currentTimetable = null;
      loadData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete timetable: $e';
      notifyListeners();
      return false;
    }
  }

  /// Gets entries for a specific day.
  List<TimetableEntry> getEntriesForDay(WeekDay day) {
    if (_currentTimetable == null) return [];
    final dayTimetable = _currentTimetable!.weekTimetable
        .where((dt) => dt.day == day)
        .firstOrNull;
    return dayTimetable?.entries ?? [];
  }

  /// Creates a default time slot.
  TimeSlot createTimeSlot({
    required int hour,
    required int minute,
    required int durationMinutes,
    required SlotType type,
  }) {
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, hour, minute);
    final endTime = startTime.add(Duration(minutes: durationMinutes));

    return TimeSlot(
      id: '${hour}_$minute',
      startTime: startTime,
      endTime: endTime,
      type: type,
      durationMinutes: durationMinutes,
    );
  }
}
