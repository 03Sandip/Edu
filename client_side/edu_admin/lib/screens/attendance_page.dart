import 'package:flutter/material.dart';
import '../../widgets/nav_widgets.dart';
import '../../widgets/attendance_form.dart';
import 'package:edu_admin/widgets/attendence_student_list.dart';
import 'package:edu_admin/widgets/attendance_controller.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final controller = AttendanceController();

  @override
  void initState() {
    super.initState();
    controller.init(context, setState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SideNavBar(selectedItem: "Attendance"),
          Expanded(
            child: Scaffold(
              appBar: AppBar(title: const Text('Mark Attendance')),
              body: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        const SizedBox(height: 20),
                        AttendanceForm(controller: controller, refresh: setState),
                        const SizedBox(height: 16),
                        Expanded(child: StudentList(controller: controller)),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ElevatedButton.icon(
                            onPressed: controller.submitAttendance,
                            icon: const Icon(Icons.save),
                            label: const Text("Submit Attendance"),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
