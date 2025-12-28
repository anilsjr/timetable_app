import 'package:flutter/material.dart';

import '../../model/class_section.dart';
import '../../model/enums.dart';
import '../../model/faculty.dart';
import '../../model/subject.dart';
import '../../model/time_slot.dart';
import '../../model/timetable_entry.dart';
import '../../service/storage_service.dart';
import 'timetable_view_model.dart';

/// Page for managing timetables.
class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key, required this.storageService});

  final StorageService storageService;

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  late final TimetableViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TimetableViewModel(storageService: widget.storageService);
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

  String _formatWeekDay(WeekDay day) {
    return day.name[0].toUpperCase() + day.name.substring(1);
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _formatSlotType(SlotType type) {
    switch (type) {
      case SlotType.lecture:
        return 'Lecture';
      case SlotType.lab:
        return 'Lab';
      case SlotType.shortBreak:
        return 'Short Break';
      case SlotType.lunchBreak:
        return 'Lunch Break';
      case SlotType.free:
        return 'Free Period';
      case SlotType.expertLecture:
        return 'Expert Lecture';
      // default: 'Expert Lecture';
    }
  }

  Future<void> _showAddEntryDialog(
    WeekDay day, {
    TimeSlot? slot,
    TimetableEntry? entry,
  }) async {
    if (_viewModel.selectedClassSection == null) {
      _showToast('Please select a class first', isError: true);
      return;
    }

    final isEditing = entry != null;
    final targetSlot = slot ?? entry?.timeSlot;

    if (targetSlot == null) return;

    var selectedSlotType = entry?.slotType ?? targetSlot.type;
    var selectedSubjectCode = entry?.subjectCode;
    var selectedFacultyId = entry?.facultyId;

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final classSubjects = _viewModel.selectedClassSection!.subjectCodes
                .map((id) => _viewModel.getSubject(id))
                .whereType<Subject>()
                .toList();

            final availableFaculties = selectedSubjectCode != null
                ? _viewModel.getFacultiesForSubject(selectedSubjectCode!)
                : <Faculty>[];

            return AlertDialog(
              title: Text(isEditing ? 'Edit Entry' : 'Add Entry'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day: ${_formatWeekDay(day)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Time: ${_formatTime(targetSlot.startTime)} - ${_formatTime(targetSlot.endTime)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        // Slot Type Dropdown
                        DropdownButtonFormField<SlotType>(
                          value: selectedSlotType,
                          decoration: const InputDecoration(
                            labelText: 'Slot Type',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            SlotType.lecture,
                            SlotType.lab,
                            SlotType.expertLecture,
                            SlotType.free,
                          ].map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(_formatSlotType(type)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedSlotType = value!;
                              if (value == SlotType.free) {
                                selectedSubjectCode = null;
                                selectedFacultyId = null;
                              }
                            });
                          },
                        ),
                        if (selectedSlotType != SlotType.free) ...[
                          const SizedBox(height: 16),
                          // Subject Dropdown
                          DropdownButtonFormField<String>(
                            value: selectedSubjectCode,
                            decoration: const InputDecoration(
                              labelText: 'Subject *',
                              border: OutlineInputBorder(),
                            ),
                            items: classSubjects.map((subject) {
                              return DropdownMenuItem(
                                value: subject.code,
                                child: Text(
                                  '${subject.name} (${subject.code})',
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedSubjectCode = value;
                                selectedFacultyId = null;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Please select a subject' : null,
                          ),
                          const SizedBox(height: 16),
                          // Faculty Dropdown
                          DropdownButtonFormField<String>(
                            value: selectedFacultyId,
                            decoration: InputDecoration(
                              labelText: 'Faculty *',
                              border: const OutlineInputBorder(),
                              helperText: availableFaculties.isEmpty
                                  ? 'No faculty available for this subject'
                                  : null,
                            ),
                            items: availableFaculties.map((faculty) {
                              return DropdownMenuItem(
                                value: faculty.id,
                                child: Text(faculty.name),
                              );
                            }).toList(),
                            onChanged: availableFaculties.isEmpty
                                ? null
                                : (value) {
                                    setDialogState(
                                      () => selectedFacultyId = value,
                                    );
                                  },
                            validator: (value) =>
                                value == null ? 'Please select a faculty' : null,
                          ),
                        ],
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

    final newEntry = TimetableEntry(
      id: entry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      day: day,
      timeSlot: targetSlot,
      slotType: selectedSlotType,
      subjectCode: selectedSubjectCode,
      facultyId: selectedFacultyId,
      classSectionId: _viewModel.selectedClassSection!.id,
    );

    final success = await _viewModel.saveEntry(newEntry);
    if (success) {
      _showToast(isEditing ? 'Entry updated' : 'Entry added');
    } else {
      _showToast(_viewModel.errorMessage ?? 'Failed', isError: true);
    }
  }

  Future<void> _confirmDeleteEntry(TimetableEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: const Text('Are you sure you want to delete this entry?'),
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

    final success = await _viewModel.deleteEntry(entry.day, entry.timeSlot.id);
    if (success) {
      _showToast('Entry deleted');
    } else {
      _showToast(_viewModel.errorMessage ?? 'Failed to delete', isError: true);
    }
  }

  Future<void> _confirmDeleteTimetable() async {
    if (_viewModel.currentTimetable == null) {
      _showToast('No timetable to delete', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Timetable'),
          content: const Text(
            'Are you sure you want to delete the entire timetable for this class?',
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

    final success = await _viewModel.deleteTimetable();
    if (success) {
      _showToast('Timetable deleted');
    } else {
      _showToast(_viewModel.errorMessage ?? 'Failed to delete', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30,
        title: const Text('Timetable Grid', style: TextStyle(color: Colors.red, fontSize: 16),),
        centerTitle: true,
        actions: [
          if (_viewModel.currentTimetable != null)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Delete Timetable',
              onPressed: _confirmDeleteTimetable,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildClassSelector(),
        Expanded(
          child: _viewModel.selectedClassSection == null
              ? _buildNoClassSelected()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTimetableGrid(),
                      const SizedBox(height: 32),
                      _buildFacultyAssignmentTable(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildClassSelector() {
    final sortedClasses = List<ClassSection>.from(_viewModel.classSections)
      ..sort((a, b) => a.fullId.compareTo(b.fullId));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.school_outlined,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ClassSection>(
                value: _viewModel.selectedClassSection,
                isExpanded: true,
                hint: const Text(
                  'Select Class Section',
                  style: TextStyle(fontSize: 14),
                ),
                icon: const Icon(Icons.arrow_drop_down, size: 20),
                items: sortedClasses.map((classSection) {
                  return DropdownMenuItem(
                    value: classSection,
                    child: Text(
                      classSection.fullId,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) => _viewModel.selectClassSection(value),
              ),
            ),
          ),
          if (_viewModel.selectedClassSection != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Refresh Data',
              onPressed: () {
                _viewModel.loadData();
                _viewModel.selectClassSection(_viewModel.selectedClassSection);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoClassSelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_view_month_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _viewModel.classSections.isEmpty
                ? 'No Classes Found'
                : 'Select a Class to Begin',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _viewModel.classSections.isEmpty
                ? 'Please add class sections in the settings first.'
                : 'Choose a section from the dropdown above to manage its schedule.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableGrid() {
    final slots = TimetableViewModel.standardTimeSlots;
    final days = WeekDay.values.where((d) => d != WeekDay.sunday).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Table(
          defaultColumnWidth: const FixedColumnWidth(120),
          border: TableBorder.all(color: Colors.grey.shade300),
          children: [
            // Header Row
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade100),
              children: [
                const TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Day',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                ...slots.map(
                  (slot) => TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            _formatTime(slot.startTime),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatTime(slot.endTime),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Day Rows
            ...days.map(
              (day) => TableRow(
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _formatWeekDay(day),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  ...slots.map((slot) {
                    final entry = _viewModel.getEntry(day, slot.id);
                    return TableCell(child: _buildGridCell(day, slot, entry));
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyAssignmentTable() {
    final classSection = _viewModel.selectedClassSection!;
    final subjectFacultyMap = _viewModel.getSubjectFacultyMap();
    final subjects = classSection.subjectCodes
        .map((code) => _viewModel.getSubject(code))
        .whereType<Subject>()
        .toList();

    if (subjects.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_ind_outlined,
                  size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Faculty Assignments',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Table(
            columnWidths: const {
              0: FixedColumnWidth(80),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
            },
            children: [
              // Header
              TableRow(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                children: [
                  _buildTableCell('Code', isHeader: true),
                  _buildTableCell('Subject', isHeader: true),
                  _buildTableCell('Faculty', isHeader: true),
                  _buildTableCell('Coordinators', isHeader: true),
                ],
              ),
              // Data Rows
              ...subjects.asMap().entries.map((entry) {
                final index = entry.key;
                final subject = entry.value;
                final facultyName =
                    subjectFacultyMap[subject.code] ?? '---';
                final coordinators =
                    index == 0 ? classSection.coordinators.join(', ') : '';

                return TableRow(
                  children: [
                    _buildTableCell(subject.code),
                    _buildTableCell(subject.name),
                    _buildTableCell(facultyName),
                    _buildTableCell(coordinators),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return TableCell(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: text.isNotEmpty
            ? BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
              )
            : null,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            fontSize: isHeader ? 12 : 11,
          ),
        ),
      ),
    );
  }

  Widget _buildGridCell(WeekDay day, TimeSlot slot, TimetableEntry? entry) {
    if (slot.type == SlotType.shortBreak || slot.type == SlotType.lunchBreak) {
      return Container(
        height: 80,
        color: slot.type == SlotType.lunchBreak
            ? Colors.green.shade50
            : Colors.orange.shade50,
        child: Center(
          child: RotatedBox(
            quarterTurns: 1,
            child: Text(
              slot.type == SlotType.lunchBreak ? 'LUNCH' : 'BREAK',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: slot.type == SlotType.lunchBreak
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _showAddEntryDialog(day, slot: slot, entry: entry),
      onLongPress: entry != null ? () => _confirmDeleteEntry(entry) : null,
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(4),
        color: entry != null ? _getEntryColor(entry) : null,
        child: entry == null
            ? const Icon(Icons.add, size: 16, color: Colors.grey)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _viewModel.getSubject(entry.subjectCode)?.code ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _viewModel.getFaculty(entry.facultyId)?.name.split(' ').last ??
                        '',
                    style: const TextStyle(fontSize: 9),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (entry.slotType == SlotType.lab)
                    const Text(
                      '(LAB)',
                      style: TextStyle(fontSize: 8, color: Colors.blue),
                    ),
                ],
              ),
      ),
    );
  }

  Color _getEntryColor(TimetableEntry entry) {
    if (entry.slotType == SlotType.lab) return Colors.blue.shade50;
    if (entry.slotType == SlotType.expertLecture) return Colors.purple.shade50;
    return Colors.blue.shade100;
  }
}
