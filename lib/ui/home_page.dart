import 'package:flutter/material.dart';

import '../route/route_name.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing(16);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Time Table Manager'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _SectionHeader(title: 'Faculty'),
              const SizedBox(height: 8),
              _ActionRow(
                actions: [
                  _ActionButton(
                    label: 'Manage Faculty',
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteName.faculty),
                  ),
                ],
              ),
              spacing,
              _SectionHeader(title: 'Subject'),
              const SizedBox(height: 8),
              _ActionRow(
                actions: [
                  _ActionButton(
                    label: 'Manage Subjects',
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteName.subject),
                  ),
                ],
              ),
              spacing,
              _SectionHeader(title: 'Class'),
              const SizedBox(height: 8),
              _ActionRow(
                actions: [
                  _ActionButton(
                    label: 'Manage Classes',
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteName.classRoom),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: actions,
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed ?? () {}, child: Text(label));
  }
}

extension on ThemeData {
  SizedBox spacing(double height) => SizedBox(height: height);
}
