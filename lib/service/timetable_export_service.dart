import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

import '../model/class_section.dart';
import '../model/enums.dart';
import '../model/faculty.dart';
import '../model/subject.dart';
import '../model/time_slot.dart';
import '../model/timetable.dart';
import '../model/timetable_entry.dart';

/// Service for exporting timetable data to Excel and PDF formats.
class TimetableExportService {
  /// Generates a filename with timestamp.
  String _generateFileName(String prefix, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_Timetable_$timestamp.$extension';
  }

  /// Generates and saves an Excel file for the given timetable.
  Future<String?> exportToExcel({
    required Timetable timetable,
    required ClassSection classSection,
    required List<Subject> subjects,
    required List<Faculty> faculties,
    required List<TimeSlot> timeSlots,
  }) async {
    try {
      // Create Excel workbook
      final excel = Excel.createExcel();
      final sheet = excel['Timetable'];

      // Remove default sheet if it exists
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      // Add title
      sheet.merge(
        CellIndex.indexByString('A1'),
        CellIndex.indexByString('H1'),
      );
      var titleCell = sheet.cell(CellIndex.indexByString('A1'));
      titleCell.value = TextCellValue('${classSection.displayName} - Timetable');
      titleCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: HorizontalAlign.Center,
      );

      // Add timestamp
      sheet.merge(
        CellIndex.indexByString('A2'),
        CellIndex.indexByString('H2'),
      );
      var dateCell = sheet.cell(CellIndex.indexByString('A2'));
      dateCell.value = TextCellValue('Generated on: ${DateTime.now().toString().split('.')[0]}');
      dateCell.cellStyle = CellStyle(
        fontSize: 10,
        horizontalAlign: HorizontalAlign.Center,
      );

      // Prepare header row
      final days = WeekDay.values.where((d) => d != WeekDay.sunday).toList();
      final headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#4285F4'),
        fontColorHex: ExcelColor.white,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      // Add headers (row 4)
      var headerRow = 4;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: headerRow - 1))
        ..value = const TextCellValue('Time / Day')
        ..cellStyle = headerStyle;

      for (var i = 0; i < days.length; i++) {
        var cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i + 1, rowIndex: headerRow - 1),
        );
        cell.value = TextCellValue(_formatWeekDay(days[i]));
        cell.cellStyle = headerStyle;
      }

      // Add time slots and entries
      final lectureSlots = timeSlots.where(
        (slot) => slot.type != SlotType.shortBreak && slot.type != SlotType.lunchBreak,
      ).toList();

      var currentRow = headerRow;
      for (var slot in lectureSlots) {
        // Time column
        var timeCell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        );
        timeCell.value = TextCellValue('${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}');
        timeCell.cellStyle = CellStyle(bold: true);

        // Add entries for each day
        for (var i = 0; i < days.length; i++) {
          final day = days[i];
          final entry = _getEntry(timetable, day, slot.id);
          var cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: i + 1, rowIndex: currentRow),
          );

          if (entry != null && entry.subjectCode != null) {
            final subject = _getSubject(subjects, entry.subjectCode!);
            final faculty = entry.facultyId != null ? _getFaculty(faculties, entry.facultyId!) : null;
            final cellText = [
              subject?.code ?? '',
              faculty?.name.split(' ').last ?? '',
              if (entry.slotType == SlotType.lab) '(LAB)',
            ].where((s) => s.isNotEmpty).join('\n');
            cell.value = TextCellValue(cellText);
          } else {
            cell.value = const TextCellValue('-');
          }
        }
        currentRow++;
      }

      // Add faculty assignment table
      currentRow += 2;
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow),
      );
      var facultyTitleCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      );
      facultyTitleCell.value = const TextCellValue('Faculty Assignments');
      facultyTitleCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 14,
      );

      currentRow++;
      // Faculty table headers
      final facultyHeaderCells = ['Code', 'Subject', 'Faculty'];
      for (var i = 0; i < facultyHeaderCells.length; i++) {
        var cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow),
        );
        cell.value = TextCellValue(facultyHeaderCells[i]);
        cell.cellStyle = headerStyle;
      }

      currentRow++;
      // Faculty table data
      final classSubjects = classSection.subjectCodes
          .map((code) => _getSubject(subjects, code))
          .whereType<Subject>()
          .toList();

      for (var subject in classSubjects) {
        final faculty = faculties.firstWhere(
          (f) => f.subjectCodes.contains(subject.code),
          orElse: () => Faculty(
            id: '',
            name: '---',
            shortName: '',
            computerCode: '',
            subjectCodes: const [],
          ),
        );

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow)).value =
            TextCellValue(subject.code);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow)).value =
            TextCellValue(subject.name);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow)).value =
            TextCellValue(faculty.name);
        currentRow++;
      }

      // Set column widths
      for (var i = 0; i <= days.length; i++) {
        sheet.setColumnWidth(i, 20);
      }

      // Save file
      final fileName = _generateFileName(classSection.fullId, 'xlsx');
      final filePath = await _saveFile(excel.encode()!, fileName);
      return filePath;
    } catch (e) {
      debugPrint('Error exporting to Excel: $e');
      return null;
    }
  }

  /// Generates and saves a PDF file for the given timetable.
  Future<String?> exportToPdf({
    required Timetable timetable,
    required ClassSection classSection,
    required List<Subject> subjects,
    required List<Faculty> faculties,
    required List<TimeSlot> timeSlots,
  }) async {
    try {
      final pdf = pw.Document();

      final days = WeekDay.values.where((d) => d != WeekDay.sunday).toList();
      final lectureSlots = timeSlots.where(
        (slot) => slot.type != SlotType.shortBreak && slot.type != SlotType.lunchBreak,
      ).toList();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Title
                pw.Center(
                  child: pw.Text(
                    '${classSection.displayName} - Timetable',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Text(
                    'Generated on: ${DateTime.now().toString().split('.')[0]}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.SizedBox(height: 16),

                // Timetable table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(80),
                    for (var i = 1; i <= days.length; i++)
                      i: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.blue200,
                      ),
                      children: [
                        _buildPdfCell('Time / Day', isHeader: true),
                        ...days.map((day) => _buildPdfCell(_formatWeekDay(day), isHeader: true)),
                      ],
                    ),
                    // Time slot rows
                    ...lectureSlots.map((slot) {
                      return pw.TableRow(
                        children: [
                          _buildPdfCell(
                            '${_formatTime(slot.startTime)}\n${_formatTime(slot.endTime)}',
                            isHeader: true,
                          ),
                          ...days.map((day) {
                            final entry = _getEntry(timetable, day, slot.id);
                            if (entry != null && entry.subjectCode != null) {
                              final subject = _getSubject(subjects, entry.subjectCode!);
                              final faculty = entry.facultyId != null
                                  ? _getFaculty(faculties, entry.facultyId!)
                                  : null;
                              final cellText = [
                                subject?.code ?? '',
                                faculty?.name.split(' ').last ?? '',
                                if (entry.slotType == SlotType.lab) '(LAB)',
                              ].where((s) => s.isNotEmpty).join('\n');
                              return _buildPdfCell(cellText);
                            }
                            return _buildPdfCell('-');
                          }),
                        ],
                      );
                    }),
                  ],
                ),

                pw.SizedBox(height: 24),

                // Faculty assignments
                pw.Text(
                  'Faculty Assignments',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  columnWidths: const {
                    0: pw.FixedColumnWidth(80),
                    1: pw.FlexColumnWidth(2),
                    2: pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.blue200,
                      ),
                      children: [
                        _buildPdfCell('Code', isHeader: true),
                        _buildPdfCell('Subject', isHeader: true),
                        _buildPdfCell('Faculty', isHeader: true),
                      ],
                    ),
                    ...classSection.subjectCodes.map((code) {
                      final subject = _getSubject(subjects, code);
                      final faculty = faculties.firstWhere(
                        (f) => f.subjectCodes.contains(code),
                        orElse: () => Faculty(
                          id: '',
                          name: '---',
                          shortName: '',
                          computerCode: '',
                          subjectCodes: const [],
                        ),
                      );
                      return pw.TableRow(
                        children: [
                          _buildPdfCell(subject?.code ?? code),
                          _buildPdfCell(subject?.name ?? ''),
                          _buildPdfCell(faculty.name),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Save file
      final fileName = _generateFileName(classSection.fullId, 'pdf');
      final bytes = await pdf.save();
      final filePath = await _saveFile(bytes, fileName);
      return filePath;
    } catch (e) {
      debugPrint('Error exporting to PDF: $e');
      return null;
    }
  }

  /// Helper to build a PDF table cell.
  pw.Widget _buildPdfCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// Saves file to device storage.
  /// 
  /// Returns the file path on success, null on failure.
  /// - Android: Saves to app-specific external storage (Android/data/package_name/files/)
  /// - iOS: Saves to app documents directory
  /// - Other platforms: Saves to downloads directory
  Future<String?> _saveFile(List<int> bytes, String fileName) async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        // For Android, use app-specific directory which doesn't require permissions
        // Files will be accessible in Android/data/package_name/files/
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }

      if (directory == null) {
        debugPrint('Could not get directory');
        return null;
      }

      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return null;
    }
  }

  /// Helper to get an entry from timetable.
  TimetableEntry? _getEntry(Timetable timetable, WeekDay day, String slotId) {
    final dayTimetable = timetable.weekTimetable
        .where((d) => d.day == day)
        .firstOrNull;
    if (dayTimetable == null) return null;
    
    return dayTimetable.entries
        .where((e) => e.timeSlot.id == slotId)
        .firstOrNull;
  }

  /// Helper to get subject by code.
  Subject? _getSubject(List<Subject> subjects, String code) {
    return subjects.where((s) => s.code == code).firstOrNull;
  }

  /// Helper to get faculty by id.
  Faculty? _getFaculty(List<Faculty> faculties, String id) {
    return faculties.where((f) => f.id == id).firstOrNull;
  }

  /// Helper to format week day.
  String _formatWeekDay(WeekDay day) {
    return day.name[0].toUpperCase() + day.name.substring(1);
  }

  /// Helper to format time.
  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
