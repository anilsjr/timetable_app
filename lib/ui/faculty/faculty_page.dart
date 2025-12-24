import 'package:flutter/material.dart';

import '../../model/faculty.dart';
import '../../model/subject.dart';
import '../../service/storage_service.dart';
import 'faculty_view_model.dart';

/// Page for managing faculties (add, edit, delete).
class FacultyPage extends StatefulWidget {
  const FacultyPage({super.key, required this.storageService});

  final StorageService storageService;

  @override
  State<FacultyPage> createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyPage> {
  late final FacultyViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = FacultyViewModel(storageService: widget.storageService);
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

  Future<void> _showAddEditDialog({Faculty? faculty}) async {
    final isEditing = faculty != null;
    final nameController = TextEditingController(text: faculty?.name ?? '');
    final emailController = TextEditingController(text: faculty?.email ?? '');
    final phoneController = TextEditingController(text: faculty?.phone ?? '');
    var selectedSubjectIds = List<String>.from(faculty?.subjectIds ?? []);
    var isActive = faculty?.isActive ?? true;

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Faculty' : 'Add Faculty'),
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
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name *',
                            hintText: 'e.g., John Doe',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email *',
                            hintText: 'e.g., john@example.com',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone *',
                            hintText: 'e.g., 9876543210',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Phone is required';
                            }
                            if (value.trim().length < 10) {
                              return 'Enter a valid phone number';
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
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Active'),
                          subtitle: Text(
                            isActive
                                ? 'Faculty is active'
                                : 'Faculty is inactive',
                          ),
                          value: isActive,
                          onChanged: (value) {
                            setDialogState(() => isActive = value);
                          },
                          contentPadding: EdgeInsets.zero,
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

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    bool success;
    if (isEditing) {
      success = await _viewModel.updateFaculty(
        id: faculty.id,
        name: name,
        email: email,
        phone: phone,
        subjectIds: selectedSubjectIds,
        isActive: isActive,
      );
      if (success) {
        _showToast('Faculty updated successfully');
      } else {
        _showToast(
          _viewModel.errorMessage ?? 'Failed to update',
          isError: true,
        );
      }
    } else {
      success = await _viewModel.addFaculty(
        name: name,
        email: email,
        phone: phone,
        subjectIds: selectedSubjectIds,
        isActive: isActive,
      );
      if (success) {
        _showToast('Faculty added successfully');
      } else {
        _showToast(_viewModel.errorMessage ?? 'Failed to add', isError: true);
      }
    }
  }

  Future<void> _confirmDelete(Faculty faculty) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Faculty'),
          content: Text('Are you sure you want to delete "${faculty.name}"?'),
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

    final success = await _viewModel.deleteFaculty(faculty.id);
    if (success) {
      _showToast('Faculty deleted successfully');
    } else {
      _showToast(_viewModel.errorMessage ?? 'Failed to delete', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Faculty'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Faculty'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.faculties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No faculty added yet',
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
      itemCount: _viewModel.faculties.length,
      itemBuilder: (context, index) {
        final faculty = _viewModel.faculties[index];
        return _FacultyCard(
          faculty: faculty,
          subjectNames: _viewModel.getSubjectNames(faculty.subjectIds),
          onEdit: () => _showAddEditDialog(faculty: faculty),
          onDelete: () => _confirmDelete(faculty),
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
          'Subjects Taught',
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
                subtitle: Text(subject.code),
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

class _FacultyCard extends StatelessWidget {
  const _FacultyCard({
    required this.faculty,
    required this.subjectNames,
    required this.onEdit,
    required this.onDelete,
  });

  final Faculty faculty;
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
                  backgroundColor: faculty.isActive
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.person,
                    color: faculty.isActive
                        ? colorScheme.primary
                        : colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              faculty.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: faculty.isActive
                                  ? Colors.green.shade100
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              faculty.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: faculty.isActive
                                    ? Colors.green.shade800
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        faculty.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        faculty.phone,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
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
