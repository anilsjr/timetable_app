import 'package:flutter/foundation.dart';

import '../../model/class_section.dart';
import '../../model/day_timetable.dart';
import '../../model/enums.dart';
import '../../model/faculty.dart';
import '../../model/subject.dart';
import '../../model/time_slot.dart';
import '../../model/timetable.dart';
import '../../model/timetable_entry.dart';
import '../../domain/repo/timetable_repository.dart';
import '../../service/timetable_export_service.dart';

/// ViewModel for managing timetable data.
class TimetableViewModel extends ChangeNotifier {
  TimetableViewModel({required TimetableRepository timetableRepository})
      : _timetableRepository = timetableRepository {
    loadData();
  }

  final TimetableRepository _timetableRepository;

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
        endTime: t(16, 10),
        type: SlotType.lecture,
        durationMinutes: 50,
      ),
    ];
  }

  /// Loads all data required for timetable page.
  void loadData() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _timetableRepository.loadTimetables();
      _timetables = _timetableRepository.getAllTimetables();
      _classSections = _timetableRepository.getAllClassSections();
      _subjects = _timetableRepository.getAllSubjects();
      _faculties = _timetableRepository.getAllFaculties();
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Selects a class section and loads/sets the corresponding timetable (if any).
  void selectClassSection(ClassSection? classSection) {
    _selectedClassSection = classSection;
    if (classSection == null) {
      _currentTimetable = null;
    } else {
      _currentTimetable =
          _timetableRepository.getTimetableByClassSection(classSection.id);
    }
    notifyListeners();
  }

  /// Get subject by code from cached subjects.
  Subject? getSubject(String code) {
    try {
      return _subjects.firstWhere((s) => s.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Get faculty by id from cached faculties.
  Faculty? getFaculty(String id) {
    try {
      return _faculties.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Returns list of faculties that can teach the given subject code.
  List<Faculty> getFacultiesForSubject(String subjectCode) {
    return _faculties.where((f) => f.subjectCodes.contains(subjectCode)).toList();
  }

  /// Returns the TimetableEntry for the given day and slotId (if any).
  TimetableEntry? getEntry(WeekDay day, String slotId) {
    if (_currentTimetable == null) return null;
    try {
      final dayTimetable = _currentTimetable!.weekTimetable
          .firstWhere((d) => d.day == day, orElse: () => DayTimetable(day: day, entries: []));
      return dayTimetable.entries.firstWhere(
        (e) => e.timeSlot.id == slotId,
        orElse: () => null as TimetableEntry,
      );
    } catch (e) {
      // firstWhere with orElse above avoids exceptions, but keep guard
      return null;
    }
  }

  /// Saves (adds or updates) an entry into the current timetable.
  /// If no timetable exists for the selected class, a new one will be created.
  Future<bool> saveEntry(TimetableEntry entry) async {
    if (_selectedClassSection == null) {
      _errorMessage = 'No class selected';
      notifyListeners();
      return false;
    }

    try {
      // Ensure we have a timetable for this class
      Timetable timetable = _currentTimetable ??
          Timetable(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            classSectionId: _selectedClassSection!.id,
            weekTimetable: WeekDay.values
                .where((d) => d != WeekDay.sunday)
                .map((d) => DayTimetable(day: d, entries: []))
                .toList(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

      // Find the day timetable
      final dayIndex =
          timetable.weekTimetable.indexWhere((d) => d.day == entry.day);
      if (dayIndex == -1) {
        // shouldn't happen; create day
        timetable.weekTimetable.add(DayTimetable(day: entry.day, entries: []));
      }

      final targetDay = timetable.weekTimetable
          .firstWhere((d) => d.day == entry.day, orElse: () => DayTimetable(day: entry.day, entries: []));

      // Remove any existing entry in same slot and replace
      final existingIndex =
          targetDay.entries.indexWhere((e) => e.timeSlot.id == entry.timeSlot.id);
      if (existingIndex != -1) {
        targetDay.entries[existingIndex] = entry;
      } else {
        targetDay.entries.add(entry);
      }

      // Update timestamps
      final now = DateTime.now();
      timetable = timetable.copyWith(updatedAt: now, weekTimetable: timetable.weekTimetable);

      final success = _currentTimetable == null
          ? await _timetableRepository.addTimetable(timetable)
          : await _timetableRepository.updateTimetable(timetable);

      if (!success) {
        _errorMessage = 'Failed to save timetable';
        notifyListeners();
        return false;
      }

      // Update local cache
      _currentTimetable = timetable;
      // replace or add in list
      final idx = _timetables.indexWhere((t) => t.id == timetable.id);
      if (idx == -1) {
        _timetables.add(timetable);
      } else {
        _timetables[idx] = timetable;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save entry: $e';
      notifyListeners();
      return false;
    }
  }

  /// Deletes an entry identified by day and slotId from the current timetable.
  Future<bool> deleteEntry(WeekDay day, String slotId) async {
    if (_currentTimetable == null) {
      _errorMessage = 'No timetable selected';
      notifyListeners();
      return false;
    }

    try {
      final timetable = _currentTimetable!;
      final dayTimetableIndex = timetable.weekTimetable.indexWhere((d) => d.day == day);
      if (dayTimetableIndex == -1) {
        _errorMessage = 'Entry not found';
        notifyListeners();
        return false;
      }

      final dayTimetable = timetable.weekTimetable[dayTimetableIndex];
      final entryIndex = dayTimetable.entries.indexWhere((e) => e.timeSlot.id == slotId);
      if (entryIndex == -1) {
        _errorMessage = 'Entry not found';
        notifyListeners();
        return false;
      }

      dayTimetable.entries.removeAt(entryIndex);

      final now = DateTime.now();
      final updatedTimetable = timetable.copyWith(updatedAt: now, weekTimetable: timetable.weekTimetable);

      final success = await _timetableRepository.updateTimetable(updatedTimetable);
      if (!success) {
        _errorMessage = 'Failed to delete entry';
        notifyListeners();
        return false;
      }

      _currentTimetable = updatedTimetable;
      final idx = _timetables.indexWhere((t) => t.id == updatedTimetable.id);
      if (idx != -1) _timetables[idx] = updatedTimetable;

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete entry: $e';
      notifyListeners();
      return false;
    }
  }

  /// Deletes the whole current timetable.
  Future<bool> deleteTimetable() async {
    if (_currentTimetable == null) {
      _errorMessage = 'No timetable to delete';
      notifyListeners();
      return false;
    }

    try {
      final id = _currentTimetable!.id;
      final success = await _timetableRepository.deleteTimetable(id);
      if (!success) {
        _errorMessage = 'Failed to delete timetable';
        notifyListeners();
        return false;
      }

      _timetables.removeWhere((t) => t.id == id);
      _currentTimetable = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete timetable: $e';
      notifyListeners();
      return false;
    }
  }

  /// Builds a simple subject -> faculty name map for the selected class.
  /// If multiple faculties can teach a subject, picks the first available.
  Map<String, String> getSubjectFacultyMap() {
    final Map<String, String> map = {};
    if (_selectedClassSection == null) return map;

    for (final code in _selectedClassSection!.subjectCodes) {
      final faculty = _faculties.firstWhere(
        (f) => f.subjectCodes.contains(code),
        orElse: () => Faculty(
          id: '',
          name: '---',
          shortName: '',
          computerCode: '',
          subjectCodes: const [],
        ),
      );
      map[code] = (faculty.id.isEmpty) ? '---' : faculty.name;
    }
    return map;
  }

  /// Exports the current timetable to Excel format.
  Future<String?> exportToExcel() async {
    if (_currentTimetable == null || _selectedClassSection == null) {
      _errorMessage = 'No timetable to export';
      notifyListeners();
      return null;
    }

    final exportService = TimetableExportService();
    try {
      final filePath = await exportService.exportToExcel(
        timetable: _currentTimetable!,
        classSection: _selectedClassSection!,
        subjects: _subjects,
        faculties: _faculties,
        timeSlots: standardTimeSlots,
      );
      return filePath;
    } catch (e) {
      _errorMessage = 'Failed to export to Excel: $e';
      notifyListeners();
      return null;
    }
  }

  /// Exports the current timetable to PDF format.
  Future<String?> exportToPdf() async {
    if (_currentTimetable == null || _selectedClassSection == null) {
      _errorMessage = 'No timetable to export';
      notifyListeners();
      return null;
    }

    final exportService = TimetableExportService();
    try {
      final filePath = await exportService.exportToPdf(
        timetable: _currentTimetable!,
        classSection: _selectedClassSection!,
        subjects: _subjects,
        faculties: _faculties,
        timeSlots: standardTimeSlots,
      );
      return filePath;
    } catch (e) {
      _errorMessage = 'Failed to export to PDF: $e';
      notifyListeners();
      return null;
    }
  }
}