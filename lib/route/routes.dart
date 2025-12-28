import 'package:flutter/material.dart';

import '../service/storage_service.dart';
import '../ui/class_room/class_room_page.dart';
import '../ui/faculty/faculty_page.dart';
import '../ui/home_page.dart';
import '../ui/subject/subject_page.dart';
import '../ui/timetable/timetable_page.dart';
import 'route_name.dart';

class Routes {
  const Routes._();

  static StorageService? _storageService;

  /// Sets the storage service for route builders.
  static void setStorageService(StorageService storageService) {
    _storageService = storageService;
  }

  /// Gets the storage service.
  static StorageService getStorageService() {
    if (_storageService == null) {
      throw Exception('StorageService not initialized');
    }
    return _storageService!;
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );

      case RouteName.subject:
        return MaterialPageRoute<void>(
          builder: (_) => SubjectPage(storageService: _storageService!),
          settings: settings,
        );

      case RouteName.faculty:
        return MaterialPageRoute<void>(
          builder: (_) => FacultyPage(storageService: _storageService!),
          settings: settings,
        );

      case RouteName.ClassSection:
        return MaterialPageRoute<void>(
          builder: (_) => ClassSectionPage(storageService: _storageService!),
          settings: settings,
        );

      case RouteName.timeTable:
        return MaterialPageRoute<void>(
          builder: (_) => TimetablePage(storageService: _storageService!),
          settings: settings,
        );

      default:
        return MaterialPageRoute<void>(
          builder: (_) => const _UnknownRoutePage(),
          settings: settings,
        );
    }
  }
}

class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage();

  @override
  Widget build(BuildContext context) {
    final name = ModalRoute.of(context)?.settings.name ?? 'unknown';
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(child: Text('No route defined for "$name"')),
    );
  }
}
