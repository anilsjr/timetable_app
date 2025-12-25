import '../model/class_room.dart';
import '../model/faculty.dart';
import '../model/subject.dart';
import '../service/storage_service.dart';

/// Utility class for managing dummy data.
class DummyDataUtils {
  /// Inserts dummy data into hive storage.
  /// Returns true if successful, false otherwise.
  static Future<bool> insertDummyData(StorageService storageService) async {
    try {
      // Clear existing data
      await storageService.clearAll();

      // Create 6 subjects
      final subjects = _createSubjects();
      for (final subject in subjects) {
        await storageService.saveSubject(subject);
      }

      // Create 12 faculty members
      final faculties = _createFaculties(subjects);
      for (final faculty in faculties) {
        await storageService.saveFaculty(faculty);
      }

      // Create 10 classes
      final classRooms = _createClassRooms(subjects);
      for (final classRoom in classRooms) {
        await storageService.saveClassRoom(classRoom);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Creates 6 dummy subjects.
  static List<Subject> _createSubjects() {
    return [
      const Subject(
        id: 'sub_001',
        name: 'Mathematics',
        code: 'MATH101',
        weeklyLectures: 4,
        isLab: false,
      ),
      const Subject(
        id: 'sub_002',
        name: 'Physics',
        code: 'PHY102',
        weeklyLectures: 4,
        isLab: true,
      ),
      const Subject(
        id: 'sub_003',
        name: 'Chemistry',
        code: 'CHEM103',
        weeklyLectures: 3,
        isLab: true,
      ),
      const Subject(
        id: 'sub_004',
        name: 'English',
        code: 'ENG104',
        weeklyLectures: 3,
        isLab: false,
      ),
      const Subject(
        id: 'sub_005',
        name: 'History',
        code: 'HIST105',
        weeklyLectures: 2,
        isLab: false,
      ),
      const Subject(
        id: 'sub_006',
        name: 'Computer Science',
        code: 'CS106',
        weeklyLectures: 5,
        isLab: true,
      ),
    ];
  }

  /// Creates 12 dummy faculty members.
  static List<Faculty> _createFaculties(List<Subject> subjects) {
    return [
      Faculty(
        id: 'fac_001',
        name: 'Dr. Raj Kumar',
        email: 'raj.kumar@school.com',
        phone: '9876543210',
        subjectIds: [subjects[0].id], // Mathematics
        isActive: true,
      ),
      Faculty(
        id: 'fac_002',
        name: 'Prof. Priya Sharma',
        email: 'priya.sharma@school.com',
        phone: '9876543211',
        subjectIds: [subjects[0].id], // Mathematics
        isActive: true,
      ),
      Faculty(
        id: 'fac_003',
        name: 'Dr. Vikram Singh',
        email: 'vikram.singh@school.com',
        phone: '9876543212',
        subjectIds: [subjects[1].id], // Physics
        isActive: true,
      ),
      Faculty(
        id: 'fac_004',
        name: 'Prof. Neha Patel',
        email: 'neha.patel@school.com',
        phone: '9876543213',
        subjectIds: [subjects[1].id], // Physics
        isActive: true,
      ),
      Faculty(
        id: 'fac_005',
        name: 'Dr. Arjun Reddy',
        email: 'arjun.reddy@school.com',
        phone: '9876543214',
        subjectIds: [subjects[2].id], // Chemistry
        isActive: true,
      ),
      Faculty(
        id: 'fac_006',
        name: 'Prof. Anjali Verma',
        email: 'anjali.verma@school.com',
        phone: '9876543215',
        subjectIds: [subjects[2].id], // Chemistry
        isActive: true,
      ),
      Faculty(
        id: 'fac_007',
        name: 'Dr. Ravi Nair',
        email: 'ravi.nair@school.com',
        phone: '9876543216',
        subjectIds: [subjects[3].id], // English
        isActive: true,
      ),
      Faculty(
        id: 'fac_008',
        name: 'Prof. Divya Kumar',
        email: 'divya.kumar@school.com',
        phone: '9876543217',
        subjectIds: [subjects[3].id, subjects[4].id], // English, History
        isActive: true,
      ),
      Faculty(
        id: 'fac_009',
        name: 'Dr. Sanjay Rao',
        email: 'sanjay.rao@school.com',
        phone: '9876543218',
        subjectIds: [subjects[4].id], // History
        isActive: true,
      ),
      Faculty(
        id: 'fac_010',
        name: 'Prof. Akshara Singh',
        email: 'akshara.singh@school.com',
        phone: '9876543219',
        subjectIds: [subjects[5].id], // Computer Science
        isActive: true,
      ),
      Faculty(
        id: 'fac_011',
        name: 'Dr. Rohit Sharma',
        email: 'rohit.sharma@school.com',
        phone: '9876543220',
        subjectIds: [subjects[5].id], // Computer Science
        isActive: true,
      ),
      Faculty(
        id: 'fac_012',
        name: 'Prof. Meera Desai',
        email: 'meera.desai@school.com',
        phone: '9876543221',
        subjectIds: [subjects[5].id], // Computer Science
        isActive: false,
      ),
    ];
  }

  /// Creates 10 dummy class rooms.
  static List<ClassRoom> _createClassRooms(List<Subject> subjects) {
    return [
      ClassRoom(
        id: 'class_001',
        className: '10th Grade',
        section: 'A',
        studentCount: 40,
        subjectIds: [
          subjects[0].id,
          subjects[1].id,
          subjects[2].id,
          subjects[3].id,
        ], // Math, Physics, Chemistry, English
      ),
      ClassRoom(
        id: 'class_002',
        className: '10th Grade',
        section: 'B',
        studentCount: 38,
        subjectIds: [
          subjects[0].id,
          subjects[1].id,
          subjects[2].id,
          subjects[3].id,
        ],
      ),
      ClassRoom(
        id: 'class_003',
        className: '10th Grade',
        section: 'C',
        studentCount: 42,
        subjectIds: [
          subjects[0].id,
          subjects[1].id,
          subjects[2].id,
          subjects[4].id,
        ], // Math, Physics, Chemistry, History
      ),
      ClassRoom(
        id: 'class_004',
        className: '11th Grade',
        section: 'A',
        studentCount: 35,
        subjectIds: [
          subjects[0].id,
          subjects[1].id,
          subjects[2].id,
          subjects[5].id,
        ], // Math, Physics, Chemistry, CS
      ),
      ClassRoom(
        id: 'class_005',
        className: '11th Grade',
        section: 'B',
        studentCount: 37,
        subjectIds: [
          subjects[0].id,
          subjects[1].id,
          subjects[5].id,
        ], // Math, Physics, CS
      ),
      ClassRoom(
        id: 'class_006',
        className: '12th Grade',
        section: 'A',
        studentCount: 39,
        subjectIds: [
          subjects[0].id,
          subjects[1].id,
          subjects[2].id,
          subjects[5].id,
        ], // Math, Physics, Chemistry, CS
      ),
      ClassRoom(
        id: 'class_007',
        className: '12th Grade',
        section: 'B',
        studentCount: 36,
        subjectIds: [
          subjects[0].id,
          subjects[3].id,
          subjects[4].id,
          subjects[5].id,
        ], // Math, English, History, CS
      ),
      ClassRoom(
        id: 'class_008',
        className: '9th Grade',
        section: 'A',
        studentCount: 45,
        subjectIds: [
          subjects[0].id,
          subjects[1].id,
          subjects[3].id,
          subjects[4].id,
        ], // Math, Physics, English, History
      ),
      ClassRoom(
        id: 'class_009',
        className: '9th Grade',
        section: 'B',
        studentCount: 43,
        subjectIds: [
          subjects[0].id,
          subjects[1].id,
          subjects[2].id,
          subjects[3].id,
        ],
      ),
      ClassRoom(
        id: 'class_010',
        className: '8th Grade',
        section: 'A',
        studentCount: 44,
        subjectIds: [
          subjects[0].id,
          subjects[1].id,
          subjects[2].id,
          subjects[3].id,
          subjects[4].id,
        ], // All except CS
      ),
    ];
  }
}
