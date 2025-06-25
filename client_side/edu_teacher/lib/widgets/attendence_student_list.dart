import 'package:flutter/material.dart';
import 'attendance_controller.dart';

class StudentList extends StatelessWidget {
  final AttendanceController controller;

  const StudentList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.students.isEmpty) {
      return const Center(child: Text('No students found'));
    }

    return ListView.builder(
      itemCount: controller.students.length,
      itemBuilder: (context, index) {
        final student = controller.students[index];
        final roll = student['roll'];
        final name = student['name'];
        final selectedStatus = controller.attendance[roll];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text("Roll: $roll"),
            trailing: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Present'),
                  selected: selectedStatus == 'Present',
                  selectedColor: Colors.green.shade300,
                  onSelected: (_) => controller.markAttendance(roll, 'Present'),
                ),
                ChoiceChip(
                  label: const Text('Absent'),
                  selected: selectedStatus == 'Absent',
                  selectedColor: Colors.red.shade300,
                  onSelected: (_) => controller.markAttendance(roll, 'Absent'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
