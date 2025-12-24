import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../model/break_config.dart';
import '../model/class_room.dart';
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
  static const String _classRoomBox = 'classRoom';
  static const String _timeSlotBox = 'timeSlot';
  static const String _breakConfigBox = 'breakConfig';
  static const String _timetableEntryBox = 'timetableEntry';
  static const String _dayTimetableBox = 'dayTimetable';
  static const String _timetableBox = 'timetable';

  late Box<String> _facultyBoxInstance;
  late Box<String> _subjectBoxInstance;
  late Box<String> _classRoomBoxInstance;
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
    _classRoomBoxInstance = await Hive.openBox<String>(_classRoomBox);
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
    await _subjectBoxInstance.put(subject.id, jsonEncode(subject.toJson()));
  }

  /// Gets a subject by ID.
  Subject? getSubject(String id) {
    final json = _subjectBoxInstance.get(id);
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

  /// Deletes a subject by ID.
  Future<void> deleteSubject(String id) async {
    await _subjectBoxInstance.delete(id);
  }

  // ==================== ClassRoom ====================

  /// Saves a class room to storage.
  Future<void> saveClassRoom(ClassRoom classRoom) async {
    await _classRoomBoxInstance.put(
      classRoom.id,
      jsonEncode(classRoom.toJson()),
    );
  }

  /// Gets a class room by ID.
  ClassRoom? getClassRoom(String id) {
    final json = _classRoomBoxInstance.get(id);
    if (json == null) return null;
    return ClassRoom.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Gets all class rooms.
  List<ClassRoom> getAllClassRooms() {
    return _classRoomBoxInstance.values
        .map(
          (json) =>
              ClassRoom.fromJson(jsonDecode(json) as Map<String, dynamic>),
        )
        .toList();
  }

  /// Deletes a class room by ID.
  Future<void> deleteClassRoom(String id) async {
    await _classRoomBoxInstance.delete(id);
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

  /// Deletes a timetable entry by ID.
  Future<void> deleteTimetableEntry(String id) async {
    await _timetableEntryBoxInstance.delete(id);
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

  /// Gets a timetable by class room ID.
  Timetable? getTimetableByClassRoom(String classRoomId) {
    final allTimetables = getAllTimetables();
    try {
      return allTimetables.firstWhere((t) => t.classRoomId == classRoomId);
    } catch (_) {
      return null;
    }
  }

  // ==================== Utility Methods ====================

  /// Clears all data from all boxes.
  Future<void> clearAll() async {
    await _facultyBoxInstance.clear();
    await _subjectBoxInstance.clear();
    await _classRoomBoxInstance.clear();
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
    await _classRoomBoxInstance.close();
    await _timeSlotBoxInstance.close();
    await _breakConfigBoxInstance.close();
    await _timetableEntryBoxInstance.close();
    await _dayTimetableBoxInstance.close();
    await _timetableBoxInstance.close();
  }
}
