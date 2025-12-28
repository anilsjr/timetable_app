import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../model/break_config.dart';
import '../model/class_section.dart';
import '../model/day_timetable.dart';
import '../model/faculty.dart';
import '../model/subject.dart';
import '../model/time_slot.dart';
import '../model/timetable.dart';
import '../model/timetable_entry.dart';

/// Service class for managing local storage using Hive.
class StorageService {
  static const String _facultyBox = 'faculty';
  static const String _subjectBox = 'subject';
  static const String _classSectionBox = 'classSection';
  static const String _timeSlotBox = 'timeSlot';
  static const String _breakConfigBox = 'breakConfig';
  static const String _timetableEntryBox = 'timetableEntry';
  static const String _dayTimetableBox = 'dayTimetable';
  static const String _timetableBox = 'timetable';

  late Box<String> _facultyBoxInstance;
  late Box<String> _subjectBoxInstance;
  late Box<String> _classSectionBoxInstance;
  late Box<String> _timeSlotBoxInstance;
  late Box<String> _breakConfigBoxInstance;
  late Box<String> _timetableEntryBoxInstance;
  late Box<String> _dayTimetableBoxInstance;
  late Box<String> _timetableBoxInstance;

  /// Initializes Hive and opens all boxes.
  Future<void> init() async {
    await Hive.initFlutter();

    _facultyBoxInstance = await Hive.openBox<String>(_facultyBox);
    _subjectBoxInstance = await Hive.openBox<String>(_subjectBox);
    _classSectionBoxInstance = await Hive.openBox<String>(_classSectionBox);
    _timeSlotBoxInstance = await Hive.openBox<String>(_timeSlotBox);
    _breakConfigBoxInstance = await Hive.openBox<String>(_breakConfigBox);
    _timetableEntryBoxInstance = await Hive.openBox<String>(_timetableEntryBox);
    _dayTimetableBoxInstance = await Hive.openBox<String>(_dayTimetableBox);
    _timetableBoxInstance = await Hive.openBox<String>(_timetableBox);
  }

  // ==================== Faculty ====================

  /// Saves a faculty to storage.
  Future<void> saveFaculty(Faculty faculty) async {
    await _facultyBoxInstance.put(faculty.id, jsonEncode(faculty.toJson()));
  }

  /// Gets a faculty by ID.
  Faculty? getFaculty(String id) {
    final json = _facultyBoxInstance.get(id);
    if (json == null) return null;
    return Faculty.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Gets all faculties.
  List<Faculty> getAllFaculties() {
    return _facultyBoxInstance.values
        .map(
          (json) => Faculty.fromJson(jsonDecode(json) as Map<String, dynamic>),
        )
        .toList();
  }

  /// Deletes a faculty by ID.
  Future<void> deleteFaculty(String id) async {
    await _facultyBoxInstance.delete(id);
  }

  // ==================== Subject ====================

  /// Saves a subject to storage.
  Future<void> saveSubject(Subject subject) async {
    await _subjectBoxInstance.put(subject.code, jsonEncode(subject.toJson()));
  }

  /// Gets a subject by code.
  Subject? getSubject(String code) {
    final json = _subjectBoxInstance.get(code);
    if (json == null) return null;
    return Subject.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Gets all subjects.
  List<Subject> getAllSubjects() {
    return _subjectBoxInstance.values
        .map(
          (json) => Subject.fromJson(jsonDecode(json) as Map<String, dynamic>),
        )
        .toList();
  }

  /// Deletes a subject by code.
  Future<void> deleteSubject(String code) async {
    await _subjectBoxInstance.delete(code);
  }

  // ==================== ClassSection ====================

  /// Saves a class section to storage.
  Future<void> saveClassSection(ClassSection classSection) async {
    await _classSectionBoxInstance.put(
      classSection.id,
      jsonEncode(classSection.toJson()),
    );
  }

  /// Gets a class section by ID.
  ClassSection? getClassSection(String id) {
    final json = _classSectionBoxInstance.get(id);
    if (json == null) return null;
    return ClassSection.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Gets all class sections.
  List<ClassSection> getAllClassSections() {
    return _classSectionBoxInstance.values
        .map(
          (json) =>
              ClassSection.fromJson(jsonDecode(json) as Map<String, dynamic>),
        )
        .toList();
  }

  /// Deletes a class section by ID.
  Future<void> deleteClassSection(String id) async {
    await _classSectionBoxInstance.delete(id);
  }

  // ==================== TimeSlot ====================

  /// Saves a time slot to storage.
  Future<void> saveTimeSlot(TimeSlot timeSlot) async {
    await _timeSlotBoxInstance.put(timeSlot.id, jsonEncode(timeSlot.toJson()));
  }

  /// Gets a time slot by ID.
  TimeSlot? getTimeSlot(String id) {
    final json = _timeSlotBoxInstance.get(id);
    if (json == null) return null;
    return TimeSlot.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Gets all time slots.
  List<TimeSlot> getAllTimeSlots() {
    return _timeSlotBoxInstance.values
        .map(
          (json) => TimeSlot.fromJson(jsonDecode(json) as Map<String, dynamic>),
        )
        .toList();
  }

  /// Deletes a time slot by ID.
  Future<void> deleteTimeSlot(String id) async {
    await _timeSlotBoxInstance.delete(id);
  }

  // ==================== BreakConfig ====================

  /// Saves a break config to storage.
  Future<void> saveBreakConfig(BreakConfig breakConfig) async {
    await _breakConfigBoxInstance.put(
      breakConfig.id,
      jsonEncode(breakConfig.toJson()),
    );
  }

  /// Gets a break config by ID.
  BreakConfig? getBreakConfig(String id) {
    final json = _breakConfigBoxInstance.get(id);
    if (json == null) return null;
    return BreakConfig.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Gets all break configs.
  List<BreakConfig> getAllBreakConfigs() {
    return _breakConfigBoxInstance.values
        .map(
          (json) =>
              BreakConfig.fromJson(jsonDecode(json) as Map<String, dynamic>),
        )
        .toList();
  }

  /// Deletes a break config by ID.
  Future<void> deleteBreakConfig(String id) async {
    await _breakConfigBoxInstance.delete(id);
  }

  // ==================== TimetableEntry ====================

  /// Saves a timetable entry to storage.
  Future<void> saveTimetableEntry(TimetableEntry entry) async {
    await _timetableEntryBoxInstance.put(entry.id, jsonEncode(entry.toJson()));
  }

  /// Saves multiple timetable entries at once.
  Future<void> saveTimetableEntries(List<TimetableEntry> entries) async {
    final Map<String, String> entriesMap = {
      for (var entry in entries) entry.id: jsonEncode(entry.toJson())
    };
    await _timetableEntryBoxInstance.putAll(entriesMap);
  }

  /// Gets a timetable entry by ID.
  TimetableEntry? getTimetableEntry(String id) {
    final json = _timetableEntryBoxInstance.get(id);
    if (json == null) return null;
    return TimetableEntry.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Gets all timetable entries.
  List<TimetableEntry> getAllTimetableEntries() {
    return _timetableEntryBoxInstance.values
        .map(
          (json) =>
              TimetableEntry.fromJson(jsonDecode(json) as Map<String, dynamic>),
        )
        .toList();
  }

  /// Gets all timetable entries for a specific class section.
  List<TimetableEntry> getEntriesByClassSection(String classSectionId) {
    return getAllTimetableEntries()
        .where((entry) => entry.classSectionId == classSectionId)
        .toList();
  }

  /// Gets all timetable entries for a specific faculty.
  List<TimetableEntry> getEntriesByFaculty(String facultyId) {
    return getAllTimetableEntries()
        .where((entry) => entry.facultyId == facultyId)
        .toList();
  }

  /// Gets all timetable entries for a specific subject.
  List<TimetableEntry> getEntriesBySubject(String subjectCode) {
    return getAllTimetableEntries()
        .where((entry) => entry.subjectCode == subjectCode)
        .toList();
  }

  /// Deletes a timetable entry by ID.
  Future<void> deleteTimetableEntry(String id) async {
    await _timetableEntryBoxInstance.delete(id);
  }

  /// Deletes all entries for a specific class section.
  Future<void> deleteEntriesByClassSection(String classSectionId) async {
    final keysToDelete = _timetableEntryBoxInstance.values
        .map(
          (json) =>
              TimetableEntry.fromJson(jsonDecode(json) as Map<String, dynamic>),
        )
        .where((entry) => entry.classSectionId == classSectionId)
        .map((entry) => entry.id)
        .toList();

    await _timetableEntryBoxInstance.deleteAll(keysToDelete);
  }

  // ==================== DayTimetable ====================

  /// Saves a day timetable to storage.
  Future<void> saveDayTimetable(String id, DayTimetable dayTimetable) async {
    await _dayTimetableBoxInstance.put(id, jsonEncode(dayTimetable.toJson()));
  }

  /// Gets a day timetable by ID.
  DayTimetable? getDayTimetable(String id) {
    final json = _dayTimetableBoxInstance.get(id);
    if (json == null) return null;
    return DayTimetable.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Gets all day timetables.
  List<DayTimetable> getAllDayTimetables() {
    return _dayTimetableBoxInstance.values
        .map(
          (json) =>
              DayTimetable.fromJson(jsonDecode(json) as Map<String, dynamic>),
        )
        .toList();
  }

  /// Deletes a day timetable by ID.
  Future<void> deleteDayTimetable(String id) async {
    await _dayTimetableBoxInstance.delete(id);
  }

  // ==================== Timetable ====================

  /// Saves a timetable to storage.
  Future<void> saveTimetable(Timetable timetable) async {
    await _timetableBoxInstance.put(
      timetable.id,
      jsonEncode(timetable.toJson()),
    );
  }

  /// Gets a timetable by ID.
  Timetable? getTimetable(String id) {
    final json = _timetableBoxInstance.get(id);
    if (json == null) return null;
    return Timetable.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Gets all timetables.
  List<Timetable> getAllTimetables() {
    return _timetableBoxInstance.values
        .map(
          (json) =>
              Timetable.fromJson(jsonDecode(json) as Map<String, dynamic>),
        )
        .toList();
  }

  /// Deletes a timetable by ID.
  Future<void> deleteTimetable(String id) async {
    await _timetableBoxInstance.delete(id);
  }

  /// Gets a timetable by class section ID.
  Timetable? getTimetableByClassSection(String classSectionId) {
    final allTimetables = getAllTimetables();
    try {
      return allTimetables.firstWhere((t) => t.classSectionId == classSectionId);
    } catch (_) {
      return null;
    }
  }

  // ==================== Utility Methods ====================

  /// Clears all data from all boxes.
  Future<void> clearAll() async {
    await _facultyBoxInstance.clear();
    await _subjectBoxInstance.clear();
    await _classSectionBoxInstance.clear();
    await _timeSlotBoxInstance.clear();
    await _breakConfigBoxInstance.clear();
    await _timetableEntryBoxInstance.clear();
    await _dayTimetableBoxInstance.clear();
    await _timetableBoxInstance.clear();
  }

  /// Closes all boxes.
  Future<void> close() async {
    await _facultyBoxInstance.close();
    await _subjectBoxInstance.close();
    await _classSectionBoxInstance.close();
    await _timeSlotBoxInstance.close();
    await _breakConfigBoxInstance.close();
    await _timetableEntryBoxInstance.close();
    await _dayTimetableBoxInstance.close();
    await _timetableBoxInstance.close();
  }
}
