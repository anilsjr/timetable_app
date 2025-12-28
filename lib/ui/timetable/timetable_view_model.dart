import 'package:flutter/foundation.dart';

import '../../model/class_section.dart';
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

  List<ClassSection> _classSections = [];
  List<ClassSection> get classSections => _classSections;

  List<Subject> _subjects = [];
  List<Subject> get subjects => _subjects;

  List<Faculty> _faculties = [];
  List<Faculty> get faculties => _faculties;

  ClassSection? _selectedClassSection;
  ClassSection? get selectedClassSection => _selectedClassSection;

  Timetable? _currentTimetable;
  Timetable? get currentTimetable => _currentTimetable;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Standard time slots for the IPS Academy schedule.
  static List<TimeSlot> get standardTimeSlots {
    final now = DateTime.now();
    DateTime t(int h, int m) => DateTime(now.year, now.month, now.day, h, m);

    return [
      TimeSlot(
        id: 'slot_1',
        startTime: t(9, 45),
        endTime: t(10, 35),
        type: SlotType.lecture,
        durationMinutes: 50,
      ),
      TimeSlot(
        id: 'slot_2',
        startTime: t(10, 35),
        endTime: t(11, 25),
        type: SlotType.lecture,
        durationMinutes: 50,
      ),
      TimeSlot(
        id: 'slot_break_short',
        startTime: t(11, 25),
        endTime: t(11, 30),
        type: SlotType.shortBreak,
        durationMinutes: 5,
      ),
      TimeSlot(
        id: 'slot_3',
        startTime: t(11, 30),
        endTime: t(12, 20),
        type: SlotType.lecture,
        durationMinutes: 50,
      ),
      TimeSlot(
        id: 'slot_4',
        startTime: t(12, 20),
        endTime: t(13, 10),
        type: SlotType.lecture,
        durationMinutes: 50,
      ),
      TimeSlot(
        id: 'slot_break_lunch',
        startTime: t(13, 10),
        endTime: t(13, 40),
        type: SlotType.lunchBreak,
        durationMinutes: 30,
      ),
      TimeSlot(
        id: 'slot_5',
        startTime: t(13, 40),
        endTime: t(14, 30),
        type: SlotType.lecture,
        durationMinutes: 50,
      ),
      TimeSlot(
        id: 'slot_6',
        startTime: t(14, 30),
        endTime: t(15, 20),
        type: SlotType.lecture,
        durationMinutes: 50,
      ),
      TimeSlot(
        id: 'slot_7',
        startTime: t(15, 20),
        endTime: t(16, 5),
        type: SlotType.lecture,
        durationMinutes: 45,
      ),
      TimeSlot(
        id: 'slot_8',
        startTime: t(16, 5),
        endTime: t(16, 50),
        type: SlotType.lecture,
        durationMinutes: 45,
      ),
    ];
  }

  /// Loads all required data from storage.
  void loadData() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _timetables = _storageService.getAllTimetables();
      _classSections = _storageService.getAllClassSections();
      _subjects = _storageService.getAllSubjects();
      _faculties = _storageService.getAllFaculties();

      // Refresh selected class section instance if it exists
      if (_selectedClassSection != null) {
        _selectedClassSection = _classSections
            .where((c) => c.id == _selectedClassSection!.id)
            .firstOrNull;
        if (_selectedClassSection != null) {
          _currentTimetable = _storageService.getTimetableByClassSection(
            _selectedClassSection!.id,
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

  /// Selects a class section and loads its timetable.
  void selectClassSection(ClassSection? classSection) {
    _selectedClassSection = classSection;
    if (classSection != null) {
      _currentTimetable = _storageService.getTimetableByClassSection(classSection.id);
    } else {
      _currentTimetable = null;
    }
    notifyListeners();
  }

  /// Gets subject by code.
  Subject? getSubject(String? code) {
    if (code == null) return null;
    return _subjects.where((s) => s.code == code).firstOrNull;
  }

  /// Gets faculty by ID.
  Faculty? getFaculty(String? id) {
    if (id == null) return null;
    return _faculties.where((f) => f.id == id).firstOrNull;
  }

  /// Gets an entry for a specific day and slot ID.
  TimetableEntry? getEntry(WeekDay day, String timeSlotId) {
    if (_currentTimetable == null) return null;
    final dayTimetable = _currentTimetable!.weekTimetable
        .where((dt) => dt.day == day)
        .firstOrNull;
    return dayTimetable?.entries
        .where((e) => e.timeSlot.id == timeSlotId)
        .firstOrNull;
  }

  /// Checks if a faculty is available at a specific day and time slot.
  bool isFacultyAvailable(
    String facultyId,
    WeekDay day,
    TimeSlot slot, {
    String? excludeEntryId,
  }) {
    final allTimetables = _storageService.getAllTimetables();
    for (final tt in allTimetables) {
      for (final dt in tt.weekTimetable) {
        if (dt.day == day) {
          for (final entry in dt.entries) {
            if (entry.id == excludeEntryId) continue;
            if (entry.facultyId == facultyId) {
              if (_doSlotsOverlap(entry.timeSlot, slot)) {
                return false;
              }
            }
          }
        }
      }
    }
    return true;
  }

  /// Checks if two time slots overlap.
  bool _doSlotsOverlap(TimeSlot s1, TimeSlot s2) {
    // Convert to minutes from start of day for comparison
    final start1 = s1.startTime.hour * 60 + s1.startTime.minute;
    final end1 = s1.endTime.hour * 60 + s1.endTime.minute;
    final start2 = s2.startTime.hour * 60 + s2.startTime.minute;
    final end2 = s2.endTime.hour * 60 + s2.endTime.minute;

    return start1 < end2 && start2 < end1;
  }

  /// Gets class room by ID.
  ClassSection? getClassSection(String? fullId) {
    if (fullId == null) return null;
    return _classSections.where((c) => c.id == fullId).firstOrNull;
  }

  /// Gets active faculties for a subject.
  List<Faculty> getFacultiesForSubject(String subjectCode) {
    return _faculties
        .where((f) => f.isActive && f.subjectCodes.contains(subjectCode))
        .toList();
  }

  /// Creates or updates a timetable for the selected class.
  Future<bool> saveTimetable(List<DayTimetable> weekTimetable) async {
    if (_selectedClassSection == null) {
      _errorMessage = 'Please select a class first';
      notifyListeners();
      return false;
    }

    try {
      final now = DateTime.now();
      final timetable = Timetable(
        id: _currentTimetable?.id ?? now.millisecondsSinceEpoch.toString(),
        classSectionId: _selectedClassSection!.id,
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
    if (_selectedClassSection == null) {
      _errorMessage = 'Please select a class first';
      notifyListeners();
      return false;
    }

    // Validate faculty availability
    if (entry.facultyId != null) {
      final isAvailable = isFacultyAvailable(
        entry.facultyId!,
        entry.day,
        entry.timeSlot,
        excludeEntryId: entry.id,
      );

      if (!isAvailable) {
        final faculty = getFaculty(entry.facultyId);
        _errorMessage =
            '${faculty?.name ?? "Faculty"} is already assigned to another class at this time.';
        notifyListeners();
        return false;
      }
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

  /// Gets a map of subject code to assigned faculty names for the current class.
  Map<String, String> getSubjectFacultyMap() {
    if (_currentTimetable == null) return {};

    final Map<String, Set<String>> subjectToFaculties = {};

    for (final dayTimetable in _currentTimetable!.weekTimetable) {
      for (final entry in dayTimetable.entries) {
        if (entry.subjectCode != null && entry.facultyId != null) {
          final faculty = getFaculty(entry.facultyId);
          if (faculty != null) {
            subjectToFaculties
                .putIfAbsent(entry.subjectCode!, () => {})
                .add(faculty.name);
          }
        }
      }
    }

    return subjectToFaculties.map((code, names) => MapEntry(code, names.join(', ')));
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
