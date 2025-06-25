import 'package:flutter/material.dart';
import 'attendance_controller.dart';

class AttendanceForm extends StatelessWidget {
  final AttendanceController controller;
  final void Function(VoidCallback) refresh;

  const AttendanceForm({
    super.key,
    required this.controller,
    required this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 24,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          // Semester Dropdown
          DropdownButton<String>(
            value: controller.selectedSemester,
            onChanged: (value) {
              refresh(() {
                controller.selectedSemester = value!;
                controller.fetchData();
              });
            },
            items: controller.semesters
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            hint: const Text("Select Semester"),
          ),

          // Section Dropdown
          DropdownButton<String>(
            value: controller.selectedSection,
            onChanged: (value) {
              refresh(() {
                controller.selectedSection = value!;
                controller.fetchStudents();
              });
            },
            items: controller.sections
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            hint: const Text("Select Section"),
          ),

          // Subject Dropdown
          DropdownButton<String>(
            value: controller.selectedSubject,
            hint: const Text("Select Subject"),
            onChanged: (value) {
              refresh(() {
                controller.selectedSubject = value!;
              });
            },
            items: controller.subjects
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
          ),
        ],
      ),
    );
  }
}
