import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

import '../../domain/repo/subject_repository.dart';
import '../../model/subject.dart';
import 'subject_view_model.dart';

/// Page for managing subjects (add, edit, delete).
class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key, required this.subjectRepository});

  final SubjectRepository subjectRepository;

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  late final SubjectViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SubjectViewModel(subjectRepository: widget.subjectRepository);
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

  Future<void> _showAddEditDialog({Subject? subject}) async {
    final isEditing = subject != null;
    final nameController = TextEditingController(text: subject?.name ?? '');
    final codeController = TextEditingController(text: subject?.code ?? '');
    final weeklyLecturesController = TextEditingController(
      text: subject?.weeklyLectures.toString() ?? '',
    );
    var isLab = subject?.isLab ?? false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Subject' : 'Add Subject'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Subject Name',
                        hintText: 'e.g., Data Structures',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: codeController,
                      decoration: const InputDecoration(
                        labelText: 'Subject Code',
                        hintText: 'e.g., CS201',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: weeklyLecturesController,
                      decoration: const InputDecoration(
                        labelText: 'Weekly Lectures',
                        hintText: 'e.g., 4',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Is Lab Subject'),
                      value: isLab,
                      onChanged: (value) {
                        setDialogState(() => isLab = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
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
    final code = codeController.text.trim();
    final weeklyLectures = int.tryParse(weeklyLecturesController.text) ?? 0;

    if (name.isEmpty || code.isEmpty || weeklyLectures <= 0) {
      _showToast('Please fill all fields correctly', isError: true);
      return;
    }

    bool success;
    if (isEditing) {
      success = await _viewModel.updateSubject(
        name: name,
        code: code,
        weeklyLectures: weeklyLectures,
        isLab: isLab,
      );
      if (success) {
        _showToast('Subject updated successfully');
      } else {
        _showToast(
          _viewModel.errorMessage ?? 'Failed to update',
          isError: true,
        );
      }
    } else {
      success = await _viewModel.addSubject(
        name: name,
        code: code,
        weeklyLectures: weeklyLectures,
        isLab: isLab,
      );
      if (success) {
        _showToast('Subject added successfully');
      } else {
        _showToast(_viewModel.errorMessage ?? 'Failed to add', isError: true);
      }
    }
  }

  Future<void> _confirmDelete(Subject subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Subject'),
          content: Text('Are you sure you want to delete "${subject.name}"?'),
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

    final success = await _viewModel.deleteSubject(subject.code);
    if (success) {
      _showToast('Subject deleted successfully');
    } else {
      _showToast(_viewModel.errorMessage ?? 'Failed to delete', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subjects'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.subjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No subjects added yet',
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
      itemCount: _viewModel.subjects.length,
      itemBuilder: (context, index) {
        final subject = _viewModel.subjects[index];
        return _SubjectCard(
          subject: subject,
          onEdit: () => _showAddEditDialog(subject: subject),
          onDelete: () => _confirmDelete(subject),
        );
      },
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.subject,
    required this.onEdit,
    required this.onDelete,
  });

  final Subject subject;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: subject.isLab
              ? colorScheme.tertiaryContainer
              : colorScheme.primaryContainer,
          child: Icon(
            subject.isLab ? Icons.science : Icons.book,
            color: subject.isLab ? colorScheme.tertiary : colorScheme.primary,
          ),
        ),
        title: Text(
          subject.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${subject.code} • ${subject.weeklyLectures} lectures/week',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (subject.isLab)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Lab',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.tertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
