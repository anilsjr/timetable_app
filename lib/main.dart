import 'package:flutter/material.dart';

import 'core/di/di_container.dart';
import 'route/route_name.dart';
import 'route/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // title: 'Time Table Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      initialRoute: RouteName.home,
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
