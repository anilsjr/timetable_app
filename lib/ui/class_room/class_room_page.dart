import 'package:flutter/material.dart';

import '../../model/class_room.dart';
import '../../model/subject.dart';
import '../../service/storage_service.dart';
import 'class_room_view_model.dart';

/// Page for managing class rooms (add, edit, delete).
class ClassRoomPage extends StatefulWidget {
  const ClassRoomPage({super.key, required this.storageService});

  final StorageService storageService;

  @override
  State<ClassRoomPage> createState() => _ClassRoomPageState();
}

class _ClassRoomPageState extends State<ClassRoomPage> {
  late final ClassRoomViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ClassRoomViewModel(storageService: widget.storageService);
    _viewModel.addListener(_onViewModelChange);
  }

  void _onViewModelChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
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

  Future<void> _showAddEditDialog({ClassRoom? classRoom}) async {
    final isEditing = classRoom != null;
    final classNameController = TextEditingController(
      text: classRoom?.className ?? '',
    );
    final sectionController = TextEditingController(
      text: classRoom?.section ?? '',
    );
    final studentCountController = TextEditingController(
      text: classRoom?.studentCount.toString() ?? '',
    );
    var selectedSubjectIds = List<String>.from(classRoom?.subjectIds ?? []);

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
                          controller: classNameController,
                          decoration: const InputDecoration(
                            labelText: 'Class Name *',
                            hintText: 'e.g., 10th Grade',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Class name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: sectionController,
                          decoration: const InputDecoration(
                            labelText: 'Section *',
                            hintText: 'e.g., A, B, C',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Section is required';
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
                          selectedIds: selectedSubjectIds,
                          onChanged: (ids) {
                            setDialogState(() => selectedSubjectIds = ids);
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

    final className = classNameController.text.trim();
    final section = sectionController.text.trim();
    final studentCount = int.tryParse(studentCountController.text) ?? 0;

    bool success;
    if (isEditing) {
      success = await _viewModel.updateClassRoom(
        id: classRoom.id,
        className: className,
        section: section,
        studentCount: studentCount,
        subjectIds: selectedSubjectIds,
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
      success = await _viewModel.addClassRoom(
        className: className,
        section: section,
        studentCount: studentCount,
        subjectIds: selectedSubjectIds,
      );
      if (success) {
        _showToast('Class added successfully');
      } else {
        _showToast(_viewModel.errorMessage ?? 'Failed to add', isError: true);
      }
    }
  }

  Future<void> _confirmDelete(ClassRoom classRoom) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Class'),
          content: Text(
            'Are you sure you want to delete "${classRoom.className} - ${classRoom.section}"?',
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

    final success = await _viewModel.deleteClassRoom(classRoom.id);
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

    if (_viewModel.classRooms.isEmpty) {
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
      itemCount: _viewModel.classRooms.length,
      itemBuilder: (context, index) {
        final classRoom = _viewModel.classRooms[index];
        return _ClassRoomCard(
          classRoom: classRoom,
          subjectNames: _viewModel.getSubjectNames(classRoom.subjectIds),
          onEdit: () => _showAddEditDialog(classRoom: classRoom),
          onDelete: () => _confirmDelete(classRoom),
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
              final isSelected = selectedIds.contains(subject.id);
              return CheckboxListTile(
                title: Text(subject.name),
                subtitle: Text(
                  '${subject.code} • ${subject.weeklyLectures} hrs/week',
                ),
                value: isSelected,
                onChanged: (checked) {
                  final newIds = List<String>.from(selectedIds);
                  if (checked == true) {
                    newIds.add(subject.id);
                  } else {
                    newIds.remove(subject.id);
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

class _ClassRoomCard extends StatelessWidget {
  const _ClassRoomCard({
    required this.classRoom,
    required this.subjectNames,
    required this.onEdit,
    required this.onDelete,
  });

  final ClassRoom classRoom;
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
                        '${classRoom.className} - ${classRoom.section}',
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
                            '${classRoom.studentCount} students',
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
