import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class AttendanceController {
  List<dynamic> students = [];
  Map<String, String> attendance = {};
  List<String> semesters = ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th'];
  List<String> sections = ['CSE 1', 'CSE 2', 'CSE 3'];
  List<String> subjects = [];
  String selectedSemester = '1st';
  String selectedSection = 'CSE 1';
  String? selectedSubject;
  bool isLoading = false;

  late BuildContext _context;
  late void Function(VoidCallback) _setState;

  void init(BuildContext context, void Function(VoidCallback) setState) {
    _context = context;
    _setState = setState;
    fetchData();
  }

  Future<void> fetchData() async {
    _setState(() => isLoading = true);
    await fetchStudents();
    await fetchSubjects(selectedSemester);
    _setState(() => isLoading = false);
  }

  Future<void> fetchStudents() async {
    try {
      final res = await http.get(Uri.parse('${Constants.uri}/students'));
      if (res.statusCode == 200) {
        final all = json.decode(res.body);
        _setState(() {
          students = all.where((s) =>
              s['semester'] == selectedSemester &&
              s['section'] == selectedSection).toList();
          attendance.clear(); // reset
        });
      } else {
        debugPrint("⚠️ Failed to load students: ${res.body}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching students: $e");
    }
  }

  Future<void> fetchSubjects(String semester) async {
    try {
      final res = await http.get(Uri.parse('${Constants.uri}/assign-subjects?semester=$semester'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        _setState(() {
          subjects = List<String>.from(data['subjects']);
          selectedSubject = subjects.isNotEmpty ? subjects.first : null;
        });
      } else {
        _setState(() {
          subjects = [];
          selectedSubject = null;
        });
        debugPrint("⚠️ Failed to load subjects: ${res.body}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching subjects: $e");
    }
  }

  void markAttendance(String roll, String status) {
    _setState(() {
      attendance[roll] = status;
    });
  }

  void submitAttendance() async {
    if (selectedSubject == null) {
      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(content: Text('Please select a subject')),
      );
      return;
    }

    final today = DateTime.now().toIso8601String().split('T').first;

    final attendanceList = attendance.entries.map((entry) => {
      'roll': entry.key,
      'subject': selectedSubject!,
      'semester': selectedSemester,
      'section': selectedSection,
      'status': entry.value,
      'date': today,
    }).toList();

    debugPrint('📤 Sending attendance data: $attendanceList');

    try {
      final res = await http.post(
        Uri.parse('${Constants.uri}/attendance'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(attendanceList),
      );

      debugPrint('🔁 Server response: ${res.statusCode} - ${res.body}');

      if (res.statusCode == 201) {
        ScaffoldMessenger.of(_context).showSnackBar(
          const SnackBar(content: Text('✅ Attendance submitted')),
        );
        _setState(() => attendance.clear());
      } else {
        debugPrint('❌ Full error response: ${res.body}');
        String errorMessage = 'Unknown error';
        try {
          final responseMessage = json.decode(res.body);
          errorMessage = responseMessage['error'] ??
                         responseMessage['message'] ??
                         errorMessage;
        } catch (e) {
          debugPrint('❌ Could not parse error: $e');
        }

        // Customize known error
        if (errorMessage.toLowerCase().contains('already')) {
          errorMessage = "❌ Today's attendance already submitted. Come back tomorrow.";
        }

       showDialog(
  context: _context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: const Text('Attendance Error'),
      content: Text(errorMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  },
);
      }
    } catch (e) {
      debugPrint("❌ Submit error: $e");
      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(content: Text('❌ Network error')),
      );
    }
  }
}
