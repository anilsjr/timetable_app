import 'package:flutter/material.dart';

import '../../model/class_section.dart';
import '../../model/subject.dart';
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
    _viewModel = ClassSectionViewModel(
      classSectionRepository: widget.classSectionRepository,
    );
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
      ),
    );
  }

  Future<void> _showAddEditDialog({ClassSection? classSection}) async {
    final isEditing = classSection != null;

    final idController =
        TextEditingController(text: classSection?.fullId ?? '');
    final studentCountController = TextEditingController(
        text: classSection?.studentCount.toString() ?? '');

    List<String> selectedSubjectCodes =
        List.from(classSection?.subjectCodes ?? []);

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Class' : 'Add Class'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: idController,
                      enabled: !isEditing,
                      decoration: const InputDecoration(
                        labelText: 'Class ID',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: studentCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Student Count',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _SubjectMultiSelect(
                      subjects: _viewModel.subjects,
                      selectedIds: selectedSubjectCodes,
                      onChanged: (ids) =>
                          setState(() => selectedSubjectCodes = ids),
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
        ),
      ),
    );

    if (result != true) return;

    final studentCount = int.parse(studentCountController.text);

    bool success;
    if (isEditing) {
      success = await _viewModel.updateClassSection(
        id: classSection!.id,
        studentCount: studentCount,
        subjectCodes: selectedSubjectCodes,
      );
    } else {
      success = await _viewModel.addClassSection(
        id: idController.text.trim(),
        studentCount: studentCount,
        subjectCodes: selectedSubjectCodes,
      );
    }

    _showToast(
      success ? 'Saved successfully' : _viewModel.errorMessage ?? 'Error',
      isError: !success,
    );
  }

  Future<void> _confirmDelete(ClassSection section) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Delete "${section.displayName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await _viewModel.deleteClassSection(section.id);

    _showToast(
      success ? 'Deleted successfully' : _viewModel.errorMessage ?? 'Error',
      isError: !success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
      ),
      body: _viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _viewModel.classSections.isEmpty
              ? const Center(child: Text('No classes found'))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _viewModel.classSections.length,
                  itemBuilder: (_, i) {
                    final cs = _viewModel.classSections[i];
                    return _ClassSectionCard(
                      classSection: cs,
                      subjectNames:
                          _viewModel.getSubjectNames(cs.subjectCodes),
                      onEdit: () => _showAddEditDialog(classSection: cs),
                      onDelete: () => _confirmDelete(cs),
                    );
                  },
                ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                SUB SELECT                                  */
/* -------------------------------------------------------------------------- */

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
      return const Text('No subjects available');
    }

    final sortedSubjects = List<Subject>.from(subjects)
      ..sort((a, b) => a.name.compareTo(b.name));
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sortedSubjects.map((s) {
        final selected = selectedIds.contains(s.code);
        return ChoiceChip(
          selected: selected,
          label: Text('${s.name} (${s.code})'),
          onSelected: (_) {
            final copy = List<String>.from(selectedIds);
            selected ? copy.remove(s.code) : copy.add(s.code);
            onChanged(copy);
          },
        );
      }).toList(),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                               CLASS CARD                                   */
/* -------------------------------------------------------------------------- */

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
    final scheme = Theme.of(context).colorScheme;

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
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(Icons.class_, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classSection.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${classSection.studentCount} students • ${subjectNames.length} subjects',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (subjectNames.isNotEmpty) ...[
              const Divider(),
              Wrap(
                spacing: 6,
                children: subjectNames
                    .map((e) => Chip(label: Text(e)))
                    .toList(),
              ),
            ],
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete, color: scheme.error),
                  label: Text('Delete',
                      style: TextStyle(color: scheme.error)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
