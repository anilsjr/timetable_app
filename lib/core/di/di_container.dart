import 'package:get_it/get_it.dart';

import '../../data/repo/subject_repository_impl.dart';
import '../../domain/repo/subject_repository.dart';
import '../../service/storage_service.dart';

// New imports
import '../../domain/repo/faculty_repository.dart';
import '../../data/repo/faculty_repository_impl.dart';
import '../../domain/repo/class_section_repository.dart';
import '../../data/repo/class_section_repository_impl.dart';
import '../../domain/repo/timetable_repository.dart';
import '../../data/repo/timetable_repository_impl.dart';


final getIt = GetIt.instance;

/// Initializes the dependency injection container.
Future<void> setupDependencies() async {
  // Services
  final storageService = StorageService();
  await storageService.init();
  getIt.registerSingleton<StorageService>(storageService);

  // Repositories
  getIt.registerSingleton<SubjectRepository>(
    SubjectRepositoryImpl(storageService: storageService),
  );

  // Register new repository implementations
  getIt.registerSingleton<FacultyRepository>(
    FacultyRepositoryImpl(storageService: storageService),
  );

  getIt.registerSingleton<ClassSectionRepository>(
    ClassSectionRepositoryImpl(storageService: storageService),
  );

  getIt.registerSingleton<TimetableRepository>(
    TimetableRepositoryImpl(storageService: storageService),
  );
}