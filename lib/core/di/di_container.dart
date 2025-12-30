import 'package:get_it/get_it.dart';

import '../../data/repo/subject_repository_impl.dart';
import '../../domain/repo/subject_repository.dart';
import '../../service/storage_service.dart';

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
}
