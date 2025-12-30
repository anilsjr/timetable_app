import 'package:flutter/material.dart';

import '../../model/class_section.dart';
import '../../model/subject.dart';
// Use the repository interface instead of StorageService
import '../../domain/repo/class_section_repository.dart';
import 'class_room_view_model.dart';

/// Page for managing class rooms (add, edit, delete).
class ClassSectionPage extends StatefulWidget {
  const ClassSectionPage({super.key, required this.classSectionRepository});

  final ClassSectionRepository classSectionRepository;

  @override
  State<ClassSectionPage> createState() => _ClassSectionPageState();
}

class _ClassSectionPageState extends State<ClassSectionPage> {
  late final ClassSectionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Create viewmodel from repository (uses repo_impl under the hood via DI)
    _viewModel = ClassSectionViewModel(classSectionRepository: widget.classSectionRepository);
    // Listen for changes and update UI
    _viewModel.addListener(_onViewModelChange);
  }

  // Ensure the listener method exists
  void _onViewModelChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    // Remove the listener to avoid leaks
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

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

  Future<void> _showAddEditDialog({ClassSection? classSection}) async {
    final isEditing = classSection != null;
    final idController = TextEditingController(
      text: classSection?.fullId ?? '',
    );
    final studentCountController = TextEditingController(
      text: classSection?.studentCount.toString() ?? '',
    );
    var selectedSubjectCodes = List<String>.from(classSection?.subjectCodes ?? []);

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Class' : 'Add Class'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: idController,
                          decoration: const InputDecoration(
                            labelText: 'Class ID *',
                            hintText: 'e.g., CSE-AIML-T1',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          enabled: !isEditing,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Class ID is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: studentCountController,
                          decoration: const InputDecoration(
                            labelText: 'Student Count *',
                            hintText: 'e.g., 40',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Student count is required';
                            }
                            final count = int.tryParse(value);
                            if (count == null || count <= 0) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _SubjectMultiSelect(
                          subjects: _viewModel.subjects,
                          selectedIds: selectedSubjectCodes,
                          onChanged: (ids) {
                            setDialogState(() => selectedSubjectCodes = ids);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text(isEditing ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;

    final id = idController.text.trim();
    final studentCount = int.tryParse(studentCountController.text) ?? 0;

    bool success;
    if (isEditing) {
      success = await _viewModel.updateClassSection(
        id: classSection!.id,
        studentCount: studentCount,
        subjectCodes: selectedSubjectCodes,
      );
      if (success) {
        _showToast('Class updated successfully');
      } else {
        _showToast(
          _viewModel.errorMessage ?? 'Failed to update',
          isError: true,
        );
      }
    } else {
      success = await _viewModel.addClassSection(
        id: id,
        studentCount: studentCount,
        subjectCodes: selectedSubjectCodes,
      );
      if (success) {
        _showToast('Class added successfully');
      } else {
        _showToast(_viewModel.errorMessage ?? 'Failed to add', isError: true);
      }
    }
  }

  Future<void> _confirmDelete(ClassSection classSection) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Class'),
          content: Text(
            'Are you sure you want to delete "${classSection.displayName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success = await _viewModel.deleteClassSection(classSection.id);
    if (success) {
      _showToast('Class deleted successfully');
    } else {
      _showToast(_viewModel.errorMessage ?? 'Failed to delete', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classes'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.classSections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.class_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No classes added yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Tap the button below to add one'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _viewModel.classSections.length,
      itemBuilder: (context, index) {
        final classSection = _viewModel.classSections[index];
        return _ClassSectionCard(
          classSection: classSection,
          subjectNames: _viewModel.getSubjectNames(classSection.subjectCodes),
          onEdit: () => _showAddEditDialog(classSection: classSection),
          onDelete: () => _confirmDelete(classSection),
        );
      },
    );
  }
}

class _SubjectMultiSelect extends StatelessWidget {
  const _SubjectMultiSelect({
    required this.subjects,
    required this.selectedIds,
    required this.onChanged,
  });

  final List<Subject> subjects;
  final List<String> selectedIds;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'No subjects available. Please add subjects first.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subjects',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: subjects.map((subject) {
              final isSelected = selectedIds.contains(subject.code);
              return CheckboxListTile(
                title: Text(subject.name),
                subtitle: Text(
                  '${subject.code} • ${subject.weeklyLectures} hrs/week',
                ),
                value: isSelected,
                onChanged: (checked) {
                  final newIds = List<String>.from(selectedIds);
                  if (checked == true) {
                    newIds.add(subject.code);
                  } else {
                    newIds.remove(subject.code);
                  }
                  onChanged(newIds);
                },
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ClassSectionCard extends StatelessWidget {
  const _ClassSectionCard({
    required this.classSection,
    required this.subjectNames,
    required this.onEdit,
    required this.onDelete,
  });

  final ClassSection classSection;
  final List<String> subjectNames;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.class_, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classSection.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${classSection.studentCount} students',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.book,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${subjectNames.length} subjects',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (subjectNames.isNotEmpty) ...[
              const Divider(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: subjectNames
                    .map(
                      (name) => Chip(
                        label: Text(name, style: const TextStyle(fontSize: 12)),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: colorScheme.error,
                  ),
                  label: Text(
                    'Delete',
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}