import 'package:flutter/material.dart';
import 'package:time_table_manager/route/routes.dart';

import '../core/dummy_data_utils.dart';
import '../route/route_name.dart';
import '../service/storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _insertDummyData() async {
    setState(() => _isLoading = true);

    try {
      // Get storage service from the routes
      final storageService = Routes.getStorageService();

      final success = await DummyDataUtils.insertDummyData(storageService);

      if (mounted) {
        if (success) {
          _showToast(
            '✓ Dummy data inserted successfully!\n6 Subjects, 12 Faculty, 10 Classes',
          );
        } else {
          _showToast('Failed to insert dummy data', isError: true);
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        _showToast('Error: $e', isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmInsertDummyData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Insert Dummy Data'),
          content: const Text(
            'This will clear all existing data and add:\n'
            '• 6 Subjects\n'
            '• 12 Faculty Members\n'
            '• 10 Classes\n\n'
            'Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Insert'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _insertDummyData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing(16);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Time Table Manager'),
        actions: [
          Tooltip(
            message: 'Insert sample data for testing',
            child: IconButton(
              icon: const Icon(Icons.data_array),
              onPressed: _isLoading ? null : _confirmInsertDummyData,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
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
                  spacing,
                  _SectionHeader(title: 'Time-Table'),
                  const SizedBox(height: 8),
                  _ActionRow(
                    actions: [
                      _ActionButton(
                        label: 'Manage Time-Tables',
                        onPressed: () =>
                            Navigator.pushNamed(context, RouteName.timeTable),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
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
