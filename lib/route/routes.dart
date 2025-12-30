import 'package:flutter/material.dart';
import 'package:time_table_manager/domain/repo/class_section_repository.dart';
import 'package:time_table_manager/domain/repo/faculty_repository.dart';
import 'package:time_table_manager/domain/repo/timetable_repository.dart';
import '../core/di/di_container.dart' show getIt;
// import '../core/di/di_container.dart';
import '../domain/repo/subject_repository.dart';
import '../service/storage_service.dart';
import '../ui/class_room/class_room_page.dart';
import '../ui/faculty/faculty_page.dart';
import '../ui/home_page.dart';
import '../ui/subject/subject_page.dart';
import '../ui/timetable/timetable_page.dart';
import 'route_name.dart';

class Routes {
  const Routes._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );

      case RouteName.subject:
        return MaterialPageRoute<void>(
          builder: (_) => SubjectPage(
            subjectRepository: getIt<SubjectRepository>(),
          ),
          settings: settings,
        );

      case RouteName.faculty:
        return MaterialPageRoute<void>(
          builder: (_) => FacultyPage(facultyRepository: getIt<FacultyRepository>()),
          settings: settings,
        );

      case RouteName.ClassSection:
        return MaterialPageRoute<void>(
          builder: (_) => ClassSectionPage(classSectionRepository: getIt<ClassSectionRepository>()),
          settings: settings,
        );

      case RouteName.timeTable:
        return MaterialPageRoute<void>(
          builder: (_) => TimetablePage(timetableRepository: getIt<TimetableRepository>()),
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
