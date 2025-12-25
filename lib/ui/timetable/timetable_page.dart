import 'package:flutter/material.dart';

import '../../model/class_room.dart';
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

class _TimetablePageState extends State<TimetablePage>
    with SingleTickerProviderStateMixin {
  late final TimetableViewModel _viewModel;
  late final TabController _tabController;

  final List<WeekDay> _weekDays = WeekDay.values;

  @override
  void initState() {
    super.initState();
    _viewModel = TimetableViewModel(storageService: widget.storageService);
    _viewModel.addListener(_onViewModelChange);
    _tabController = TabController(length: _weekDays.length, vsync: this);
  }

  void _onViewModelChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    _tabController.dispose();
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

  Future<void> _showAddEntryDialog(WeekDay day, {TimetableEntry? entry}) async {
    if (_viewModel.selectedClassRoom == null) {
      _showToast('Please select a class first', isError: true);
      return;
    }

    final isEditing = entry != null;
    var selectedSlotType = entry?.slotType ?? SlotType.lecture;
    var selectedSubjectId = entry?.subjectId;
    var selectedFacultyId = entry?.facultyId;

    final startHourController = TextEditingController(
      text: entry?.timeSlot.startTime.hour.toString() ?? '9',
    );
    final startMinuteController = TextEditingController(
      text: entry?.timeSlot.startTime.minute.toString().padLeft(2, '0') ?? '00',
    );
    final durationController = TextEditingController(
      text: entry?.timeSlot.durationMinutes.toString() ?? '45',
    );

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final classSubjects = _viewModel.selectedClassRoom!.subjectIds
                .map((id) => _viewModel.getSubject(id))
                .whereType<Subject>()
                .toList();

            final availableFaculties = selectedSubjectId != null
                ? _viewModel.getFacultiesForSubject(selectedSubjectId!)
                : <Faculty>[];

            // Ensure selectedFacultyId is valid for the current subject
            if (selectedFacultyId != null &&
                !availableFaculties.any((f) => f.id == selectedFacultyId)) {
              selectedFacultyId = null;
            }

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
                        const SizedBox(height: 16),
                        // Slot Type Dropdown
                        DropdownButtonFormField<SlotType>(
                          value: selectedSlotType,
                          decoration: const InputDecoration(
                            labelText: 'Slot Type',
                            border: OutlineInputBorder(),
                          ),
                          items: SlotType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(_formatSlotType(type)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedSlotType = value!;
                              if (value == SlotType.shortBreak ||
                                  value == SlotType.lunchBreak ||
                                  value == SlotType.free) {
                                selectedSubjectId = null;
                                selectedFacultyId = null;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // Time inputs
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: startHourController,
                                decoration: const InputDecoration(
                                  labelText: 'Hour (0-23)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  final hour = int.tryParse(value ?? '');
                                  if (hour == null || hour < 0 || hour > 23) {
                                    return 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: startMinuteController,
                                decoration: const InputDecoration(
                                  labelText: 'Minute',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  final minute = int.tryParse(value ?? '');
                                  if (minute == null ||
                                      minute < 0 ||
                                      minute > 59) {
                                    return 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: durationController,
                                decoration: const InputDecoration(
                                  labelText: 'Duration (min)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  final duration = int.tryParse(value ?? '');
                                  if (duration == null || duration <= 0) {
                                    return 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        // Show subject/faculty only for lecture/lab
                        if (selectedSlotType == SlotType.lecture ||
                            selectedSlotType == SlotType.lab) ...[
                          const SizedBox(height: 16),
                          // Subject Dropdown
                          DropdownButtonFormField<String>(
                            value: selectedSubjectId,
                            decoration: const InputDecoration(
                              labelText: 'Subject *',
                              border: OutlineInputBorder(),
                            ),
                            items: classSubjects.map((subject) {
                              return DropdownMenuItem(
                                value: subject.id,
                                child: Text(
                                  '${subject.name} (${subject.code})',
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedSubjectId = value;
                                selectedFacultyId = null;
                              });
                            },
                            validator: (value) {
                              if ((selectedSlotType == SlotType.lecture ||
                                      selectedSlotType == SlotType.lab) &&
                                  value == null) {
                                return 'Please select a subject';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Faculty Dropdown
                          DropdownButtonFormField<String>(
                            value: selectedFacultyId,
                            decoration: InputDecoration(
                              labelText: 'Faculty',
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

    final hour = int.parse(startHourController.text);
    final minute = int.parse(startMinuteController.text);
    final duration = int.parse(durationController.text);

    final timeSlot = _viewModel.createTimeSlot(
      hour: hour,
      minute: minute,
      durationMinutes: duration,
      type: selectedSlotType,
    );

    final newEntry = TimetableEntry(
      id: entry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      day: day,
      timeSlot: timeSlot,
      slotType: selectedSlotType,
      subjectId: selectedSubjectId,
      facultyId: selectedFacultyId,
      classRoomId: _viewModel.selectedClassRoom!.id,
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
        title: const Text('Timetable'),
        centerTitle: true,
        actions: [
          if (_viewModel.currentTimetable != null)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Delete Timetable',
              onPressed: _confirmDeleteTimetable,
            ),
        ],
        bottom: _viewModel.selectedClassRoom != null
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _weekDays.map((day) {
                  return Tab(text: _formatWeekDay(day));
                }).toList(),
              )
            : null,
      ),
      floatingActionButton: _viewModel.selectedClassRoom != null
          ? FloatingActionButton.extended(
              onPressed: () =>
                  _showAddEntryDialog(_weekDays[_tabController.index]),
              icon: const Icon(Icons.add),
              label: const Text('Add Entry'),
            )
          : null,
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
          child: _viewModel.selectedClassRoom == null
              ? _buildNoClassSelected()
              : TabBarView(
                  controller: _tabController,
                  children: _weekDays.map((day) {
                    return _buildDayTimetable(day);
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildClassSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<ClassRoom>(
              value: _viewModel.selectedClassRoom,
              decoration: const InputDecoration(
                labelText: 'Select Class',
                border: OutlineInputBorder(),
                filled: true,
              ),
              hint: const Text('Choose a class to manage timetable'),
              items: _viewModel.classRooms.map((classRoom) {
                return DropdownMenuItem(
                  value: classRoom,
                  child: Text('${classRoom.className} - ${classRoom.section}'),
                );
              }).toList(),
              onChanged: (value) => _viewModel.selectClassRoom(value),
            ),
          ),
          if (_viewModel.selectedClassRoom != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () {
                _viewModel.loadData();
                _viewModel.selectClassRoom(_viewModel.selectedClassRoom);
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
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            _viewModel.classRooms.isEmpty
                ? 'No classes available'
                : 'Select a class to view/edit timetable',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          if (_viewModel.classRooms.isEmpty) ...[
            const SizedBox(height: 8),
            const Text('Please add classes first'),
          ],
        ],
      ),
    );
  }

  Widget _buildDayTimetable(WeekDay day) {
    final entries = _viewModel.getEntriesForDay(day);

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No entries for ${_formatWeekDay(day)}',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _showAddEntryDialog(day),
              icon: const Icon(Icons.add),
              label: const Text('Add Entry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _EntryCard(
          entry: entry,
          subject: _viewModel.getSubject(entry.subjectId),
          faculty: _viewModel.getFaculty(entry.facultyId),
          formatTime: _formatTime,
          formatSlotType: _formatSlotType,
          onEdit: () => _showAddEntryDialog(day, entry: entry),
          onDelete: () => _confirmDeleteEntry(entry),
        );
      },
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.entry,
    required this.subject,
    required this.faculty,
    required this.formatTime,
    required this.formatSlotType,
    required this.onEdit,
    required this.onDelete,
  });

  final TimetableEntry entry;
  final Subject? subject;
  final Faculty? faculty;
  final String Function(DateTime) formatTime;
  final String Function(SlotType) formatSlotType;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color _getSlotColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (entry.slotType) {
      case SlotType.lecture:
        return colorScheme.primaryContainer;
      case SlotType.lab:
        return colorScheme.tertiaryContainer;
      case SlotType.shortBreak:
        return Colors.orange.shade100;
      case SlotType.lunchBreak:
        return Colors.green.shade100;
      case SlotType.free:
        return colorScheme.surfaceContainerHighest;
      case SlotType.expertLecture:
        return Colors.purple.shade100;
    }
  }

  IconData _getSlotIcon() {
    switch (entry.slotType) {
      case SlotType.lecture:
        return Icons.school;
      case SlotType.lab:
        return Icons.science;
      case SlotType.shortBreak:
        return Icons.coffee;
      case SlotType.lunchBreak:
        return Icons.restaurant;
      case SlotType.free:
        return Icons.event_available;
      case SlotType.expertLecture:
        return Icons.record_voice_over;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeRange =
        '${formatTime(entry.timeSlot.startTime)} - ${formatTime(entry.timeSlot.endTime)}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: _getSlotColor(context),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getSlotIcon(), color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        timeRange,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${entry.timeSlot.durationMinutes} min',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (subject != null) ...[
                    Text(
                      subject!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    if (faculty != null)
                      Text(
                        faculty!.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ] else
                    Text(
                      formatSlotType(entry.slotType),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
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
