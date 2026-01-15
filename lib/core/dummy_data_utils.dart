import '../model/class_section.dart';
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

      // Create subjects
      final subjects = _createSubjects();
      for (final subject in subjects) {
        await storageService.saveSubject(subject);
      }

      // Create faculties
      final faculties = _createFaculties(subjects);
      for (final faculty in faculties) {
        await storageService.saveFaculty(faculty);
      }

      // Create class sections
      final ClassSections = _createClassSections(subjects);
      for (final ClassSection in ClassSections) {
        await storageService.saveClassSection(ClassSection);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Creates dummy subjects based on IPS Academy curriculum.
  static List<Subject> _createSubjects() {
    return [
      // 1st Year (Common)
      const Subject(name: 'Engineering Physics', code: 'BT101', weeklyLectures: 4, isLab: true),
      const Subject(name: 'Engineering Chemistry', code: 'BT102', weeklyLectures: 4, isLab: true),
      const Subject(name: 'Mathematics-I', code: 'BT103', weeklyLectures: 4, isLab: false),
      const Subject(name: 'Basic Electrical & Electronics', code: 'BT104', weeklyLectures: 4, isLab: true),
      const Subject(name: 'Engineering Graphics', code: 'BT105', weeklyLectures: 3, isLab: true),
      const Subject(name: 'Basic Computer Engineering', code: 'BT106', weeklyLectures: 3, isLab: true),
      const Subject(name: 'Professional Communication', code: 'BT107', weeklyLectures: 2, isLab: false),
      const Subject(name: 'Workshop Practice', code: 'BT108', weeklyLectures: 2, isLab: true),

      // 2nd Year (CSE/AIML)
      const Subject(name: 'Mathematics-III', code: 'CS201', weeklyLectures: 4, isLab: false),
      const Subject(name: 'Data Structures & Algorithms', code: 'CS202', weeklyLectures: 4, isLab: true),
      const Subject(name: 'Object Oriented Programming', code: 'CS203', weeklyLectures: 4, isLab: true),
      const Subject(name: 'Digital Logic Design', code: 'CS204', weeklyLectures: 3, isLab: true),
      const Subject(name: 'Computer Organization & Architecture', code: 'CS205', weeklyLectures: 3, isLab: false),
      const Subject(name: 'Analysis & Design of Algorithms', code: 'CS206', weeklyLectures: 4, isLab: false),
      const Subject(name: 'Operating Systems', code: 'CS207', weeklyLectures: 3, isLab: true),
      const Subject(name: 'Software Engineering', code: 'CS208', weeklyLectures: 3, isLab: false),
      const Subject(name: 'Database Management Systems', code: 'CS209', weeklyLectures: 3, isLab: true),
      const Subject(name: 'Python Programming', code: 'CS210', weeklyLectures: 3, isLab: true),

      // 3rd Year (CSE/AIML)
      const Subject(name: 'Theory of Computation', code: 'CS301', weeklyLectures: 4, isLab: false),
      const Subject(name: 'Computer Networks', code: 'CS302', weeklyLectures: 3, isLab: true),
      const Subject(name: 'Machine Learning', code: 'CS303', weeklyLectures: 4, isLab: true),
      const Subject(name: 'Artificial Intelligence', code: 'CS304', weeklyLectures: 4, isLab: false),
      const Subject(name: 'Web Technology', code: 'CS305', weeklyLectures: 3, isLab: true),
      const Subject(name: 'Compiler Design', code: 'CS306', weeklyLectures: 4, isLab: false),
      const Subject(name: 'Data Science', code: 'CS307', weeklyLectures: 3, isLab: true),
      const Subject(name: 'Cloud Computing', code: 'CS308', weeklyLectures: 3, isLab: false),

      // 4th Year (CSE/AIML)
      const Subject(name: 'Deep Learning', code: 'CS401', weeklyLectures: 4, isLab: true),
      const Subject(name: 'Big Data Analytics', code: 'CS402', weeklyLectures: 3, isLab: true),
      const Subject(name: 'Information Security', code: 'CS403', weeklyLectures: 3, isLab: false),

      // Fire Technology
      const Subject(name: 'Fire Physics & Chemistry', code: 'FT201', weeklyLectures: 4, isLab: true),
      const Subject(name: 'Rescue Equipment & Techniques', code: 'FT202', weeklyLectures: 3, isLab: true),
      const Subject(name: 'Hydraulics in Fire Service', code: 'FT203', weeklyLectures: 3, isLab: true),
      const Subject(name: 'Town Planning & Building Safety', code: 'FT301', weeklyLectures: 3, isLab: false),
      const Subject(name: 'Industrial Safety Management', code: 'FT302', weeklyLectures: 3, isLab: false),
      const Subject(name: 'Fire Fighting Practices', code: 'FT303', weeklyLectures: 4, isLab: true),
      const Subject(name: 'First Aid & Emergency Care', code: 'FT401', weeklyLectures: 2, isLab: true),
      const Subject(name: 'Disaster Management', code: 'FT402', weeklyLectures: 3, isLab: false),
      const Subject(name: 'Spoken Tutorial', code: 'SS001', weeklyLectures: 3, isLab: false),
      const Subject(name: 'Innternship-I', code: 'IP001', weeklyLectures: 3, isLab: false),
      const Subject(name: 'Innternship-II', code: 'IP002', weeklyLectures: 3, isLab: false),
      const Subject(name: 'Expert Lecture', code: 'EP001', weeklyLectures: 3, isLab: false),

      // Added from IPS Academy (Dec 2025 timetable) - B.Tech III / V / VII semesters
      const Subject(name: 'Major Project Phase-I', code: 'CS451', weeklyLectures: 2, isLab: false),
      const Subject(name: 'Robotics', code: 'CS452', weeklyLectures: 3, isLab: true),
      const Subject(name: 'Internet of Things', code: 'CS453', weeklyLectures: 3, isLab: true),
      const Subject(name: 'Blockchain Technology', code: 'CS454', weeklyLectures: 3, isLab: false),
      const Subject(name: 'Soft Computing', code: 'CS455', weeklyLectures: 3, isLab: false),
      const Subject(name: 'Mini Project', code: 'CS456', weeklyLectures: 2, isLab: true),
      const Subject(name: 'Environmental Science', code: 'CS457', weeklyLectures: 2, isLab: false),
      const Subject(name: 'Discrete Mathematics', code: 'CS458', weeklyLectures: 4, isLab: false),
    ];
  }

  /// Creates dummy faculty members.
  static List<Faculty> _createFaculties(List<Subject> subjects) {
    return [
      Faculty(
        id: 'fac_001',
        name: 'Dr. Raj Kumar',
        shortName: 'RK',
        computerCode: 'FAC001',
        email: 'raj.kumar@college.edu',
        phone: '9876543210',
        subjectCodes: ['CS202', 'CS206', 'CS456'], // DSA, ADA, Mini Project
        isActive: true,
      ),
      Faculty(
        id: 'fac_002',
        name: 'Prof. Priya Sharma',
        shortName: 'PS',
        computerCode: 'FAC002',
        email: 'priya.sharma@college.edu',
        phone: '9876543211',
        subjectCodes: ['CS202', 'CS210', 'CS307'], // DSA, Python, Data Science
        isActive: true,
      ),
      Faculty(
        id: 'fac_003',
        name: 'Dr. Vikram Singh',
        shortName: 'VS',
        computerCode: 'FAC003',
        email: 'vikram.singh@college.edu',
        phone: '9876543212',
        subjectCodes: ['CS303', 'CS304', 'CS401', 'CS452'], // ML, AI, DL, Robotics
        isActive: true,
      ),
      Faculty(
        id: 'fac_004',
        name: 'Prof. Neha Patel',
        shortName: 'NP',
        computerCode: 'FAC004',
        email: 'neha.patel@college.edu',
        phone: '9876543213',
        subjectCodes: ['BT103', 'CS201', 'CS458'], // Math-I, Math-III, Discrete Math
        isActive: true,
      ),
      Faculty(
        id: 'fac_005',
        name: 'Dr. Arjun Reddy',
        shortName: 'AR',
        computerCode: 'FAC005',
        email: 'arjun.reddy@college.edu',
        phone: '9876543214',
        subjectCodes: ['CS207', 'CS209', 'CS302'], // OS, DBMS, CN
        isActive: true,
      ),
      Faculty(
        id: 'fac_006',
        name: 'Prof. Anjali Verma',
        shortName: 'AV',
        computerCode: 'FAC006',
        email: 'anjali.verma@college.edu',
        phone: '9876543215',
        subjectCodes: ['CS302', 'CS403', 'CS453', 'CS454'], // CN, Info Security, IoT, Blockchain
        isActive: true,
      ),
      Faculty(
        id: 'fac_007',
        name: 'Dr. Ravi Nair',
        shortName: 'RN',
        computerCode: 'FAC007',
        email: 'ravi.nair@college.edu',
        phone: '9876543216',
        subjectCodes: ['FT201', 'FT303', 'FT302'], // Fire Physics, Fire Fighting, Industrial Safety
        isActive: true,
      ),
      Faculty(
        id: 'fac_008',
        name: 'Prof. Divya Kumar',
        shortName: 'DK',
        computerCode: 'FAC008',
        email: 'divya.kumar@college.edu',
        phone: '9876543217',
        subjectCodes: ['FT302', 'FT402', 'FT301'], // Industrial Safety, Disaster Mgmt, Town Planning
        isActive: true,
      ),
      Faculty(
        id: 'fac_009',
        name: 'Dr. Sanjay Rao',
        shortName: 'SR',
        computerCode: 'FAC009',
        email: 'sanjay.rao@college.edu',
        phone: '9876543218',
        subjectCodes: ['BT101', 'BT102', 'BT103'], // Physics, Chemistry, Math-I
        isActive: true,
      ),
      Faculty(
        id: 'fac_010',
        name: 'Prof. Akshara Singh',
        shortName: 'AS',
        computerCode: 'FAC010',
        email: 'akshara.singh@college.edu',
        phone: '9876543219',
        subjectCodes: ['CS305', 'CS307', 'CS210'], // Web Tech, Data Science, Python
        isActive: true,
      ),
      Faculty(
        id: 'fac_011',
        name: 'Dr. Rohit Sharma',
        shortName: 'RS',
        computerCode: 'FAC011',
        email: 'rohit.sharma@college.edu',
        phone: '9876543220',
        subjectCodes: ['CS204', 'CS205', 'CS301', 'CS452'], // DLD, COA, TOC, Robotics
        isActive: true,
      ),
      Faculty(
        id: 'fac_012',
        name: 'Prof. Meera Desai',
        shortName: 'MD',
        computerCode: 'FAC012',
        email: null,
        phone: null,
        subjectCodes: ['BT107', 'BT108', 'BT101'], // Communication, Workshop, Physics
        isActive: false,
      ),
    ];
  }

  /// Returns a comprehensive list of all class sections.
  static List<ClassSection> getAllClassSections() {
    return [
      // ==========================================
      // 1. CSE CORE (Computer Science & Engineering)
      // ==========================================
      // 1st Year
      ClassSection.fromId("CSE-1"),
      ClassSection.fromId("CSE-2"),
      // 2nd Year
      ClassSection.fromId("CSE-S1"),
      ClassSection.fromId("CSE-S2"),
      // 3rd Year
      ClassSection.fromId("CSE-T1"),
      ClassSection.fromId("CSE-T2"),
      // 4th Year (Final)
      ClassSection.fromId("CSE-F1"),
      ClassSection.fromId("CSE-F2"),

      // ==========================================
      // 2. CSE - AIML (AI & Machine Learning)
      // ==========================================
      // 1st Year
      ClassSection.fromId("CSE-AIML-1"),
      ClassSection.fromId("CSE-AIML-2"),
      // 2nd Year
      ClassSection.fromId("CSE-AIML-S1"),
      ClassSection.fromId("CSE-AIML-S2"),
      // 3rd Year
      ClassSection.fromId("CSE-AIML-T1"),
      ClassSection.fromId("CSE-AIML-T2"),
      // 4th Year
      ClassSection.fromId("CSE-AIML-F1"),

      // ==========================================
      // 3. CSE - DATA SCIENCE (DS)
      // ==========================================
      // 1st Year
      ClassSection.fromId("CSE-DS-1"),
      ClassSection.fromId("CSE-DS-2"),
      // 2nd Year
      ClassSection.fromId("CSE-DS-S1"),
      ClassSection.fromId("CSE-DS-S2"),
      // 3rd Year
      ClassSection.fromId("CSE-DS-T1"),
      // 4th Year
      ClassSection.fromId("CSE-DS-F1"),

      // ==========================================
      // 4. CSIT (Computer Science & IT)
      // ==========================================
      ClassSection.fromId("CSIT-1"),
      ClassSection.fromId("CSIT-S1"),
      ClassSection.fromId("CSIT-T1"),
      ClassSection.fromId("CSIT-F1"),

      // ==========================================
      // 5. IT (Information Technology)
      // ==========================================
      ClassSection.fromId("IT-1"),
      ClassSection.fromId("IT-S1"),
      ClassSection.fromId("IT-T1"),
      ClassSection.fromId("IT-F1"),

      // ==========================================
      // 6. FIRE TECH (FT - Flagship Course)
      // ==========================================
      ClassSection.fromId("FT-1"),
      ClassSection.fromId("FT-2"),
      ClassSection.fromId("FT-S1"),
      ClassSection.fromId("FT-T1"),
      ClassSection.fromId("FT-F1"),

      // ==========================================
      // 7. IoT & CYBER SECURITY (CSE-IoT)
      // ==========================================
      ClassSection.fromId("CSE-IOT-1"),
      ClassSection.fromId("CSE-IOT-S1"),
      ClassSection.fromId("CSE-IOT-T1"),
    ];
  }

  /// Creates dummy class sections.
  static List<ClassSection> _createClassSections(List<Subject> subjects) {
    return [
      // ==========================================
      // 1. CSE CORE (Computer Science & Engineering)
      // ==========================================
      // 1st Year
      ClassSection.fromId("CSE-1",
          studentCount: 60,
          subjectCodes: ['BT101', 'BT103', 'BT104', 'BT106'],
          coordinators: ['Dr. Raj Kumar']),
      ClassSection.fromId("CSE-2",
          studentCount: 58,
          subjectCodes: ['BT101', 'BT103', 'BT104', 'BT106'],
          coordinators: ['Dr. Raj Kumar']),
      // 2nd Year
      ClassSection.fromId("CSE-S1",
          studentCount: 62,
          subjectCodes: ['CS201', 'CS202', 'CS203', 'CS204', 'CS205'],
          coordinators: ['Dr. Amit Jain']),
      ClassSection.fromId("CSE-S2",
          studentCount: 55,
          subjectCodes: ['CS201', 'CS202', 'CS203', 'CS204', 'CS205'],
          coordinators: ['Dr. Amit Jain']),
      // 3rd Year
      ClassSection.fromId("CSE-T1",
          studentCount: 57,
          subjectCodes: ['CS301', 'CS302', 'CS304', 'CS305', 'CS306'],
          coordinators: ['Dr. Sneha Gupta']),
      ClassSection.fromId("CSE-T2",
          studentCount: 59,
          subjectCodes: ['CS301', 'CS302', 'CS304', 'CS305', 'CS306'],
          coordinators: ['Dr. Sneha Gupta']),
      // 4th Year (Final)
      ClassSection.fromId("CSE-F1",
          studentCount: 56,
          subjectCodes: ['CS402', 'CS403'],
          coordinators: ['Dr. Raj Kumar']),

      // ==========================================
      // 2. CSE - AIML (AI & Machine Learning)
      // ==========================================
      // 1st Year
      ClassSection.fromId("CSE-AIML-1",
          studentCount: 60,
          subjectCodes: ['BT101', 'BT103', 'BT104', 'BT106'],
          coordinators: ['Dr. Raj Kumar']),
      // 2nd Year
      ClassSection.fromId("CSE-AIML-S1",
          studentCount: 62,
          subjectCodes: ['CS201', 'CS202', 'CS203', 'CS207', 'CS209'],
          coordinators: ['Dr. Amit Jain']),
      // 3rd Year
      ClassSection.fromId("CSE-AIML-T1",
          studentCount: 57,
          subjectCodes: ['CS302', 'CS303', 'CS304', 'CS305', 'CS307'],
          coordinators: ['Dr. Sneha Gupta']),
      // 4th Year
      ClassSection.fromId("CSE-AIML-F1",
          studentCount: 56,
          subjectCodes: ['CS401', 'CS402'],
          coordinators: ['Dr. Raj Kumar']),

      // ==========================================
      // 6. FIRE TECH (FT - Flagship Course)
      // ==========================================
      ClassSection.fromId("FT-1",
          studentCount: 60,
          subjectCodes: ['BT101', 'BT102', 'BT103', 'BT105'],
          coordinators: ['Dr. Raj Kumar']),
      ClassSection.fromId("FT-S1",
          studentCount: 62,
          subjectCodes: ['FT201', 'FT202', 'FT203'],
          coordinators: ['Dr. Amit Jain']),
      ClassSection.fromId("FT-T1",
          studentCount: 57,
          subjectCodes: ['FT301', 'FT302', 'FT303'],
          coordinators: ['Dr. Sneha Gupta']),
      ClassSection.fromId("FT-F1",
          studentCount: 56,
          subjectCodes: ['FT401', 'FT402'],
          coordinators: ['Dr. Raj Kumar']),
    ];
  }
}