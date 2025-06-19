import 'package:flutter/material.dart';
import 'package:edu_admin/screens/admin_home_page.dart';
import 'package:edu_admin/screens/student_page.dart';
import 'package:edu_admin/screens/subject_page.dart';
import 'package:edu_admin/screens/notes_page.dart';
import 'package:edu_admin/screens/attendance_page.dart';
// import 'package:edu_admin/screens/exams_page.dart';
import 'package:edu_admin/screens/assignments_page.dart';
// import 'package:edu_admin/screens/results_page.dart';
// import 'package:edu_admin/screens/events_page.dart';
// import 'package:edu_admin/screens/messages_page.dart';
// import 'package:edu_admin/screens/announcements_page.dart';
// import 'package:edu_admin/screens/settings_page.dart';

class SideNavBar extends StatelessWidget {
  final String selectedItem;
  const SideNavBar({super.key, required this.selectedItem});

  void _navigate(BuildContext context, String item, Widget page) {
    if (item == selectedItem) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.school, color: Colors.white, size: 18),
                  ),
                  SizedBox(width: 10),
                  Text("Edu", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMenuItem(context, Icons.home, "Home", const AdminDashboardPage()),
                  _buildMenuItem(context, Icons.group, "Students", const StudentPage()),
                  _buildMenuItem(context, Icons.calendar_today, "Attendance", const AttendancePage()),
                  _buildMenuItem(context, Icons.book, "Subjects", const SubjectPage()),
                  _buildMenuItem(context, Icons.menu_book, "Notes", const UploadNotesPage()),
                  // _buildMenuItem(context, Icons.edit, "Exams", const ExamsPage()),
                  _buildMenuItem(context, Icons.assignment, "Assignments", const UploadAssignmentsPage()),
                  // _buildMenuItem(context, Icons.emoji_events, "Results", const ResultsPage()),
                   
                  // _buildMenuItem(context, Icons.event, "Events", const EventsPage()),
                  // _buildMenuItem(context, Icons.message, "Messages", const MessagesPage()),
                  // _buildMenuItem(context, Icons.announcement, "Announcements", const AnnouncementsPage()),
                  const Divider(),
                  //_buildMenuItem(context, Icons.settings, "Settings", const SettingsPage()),
                  _buildMenuItem(context, Icons.logout, "Logout", const AdminDashboardPage()), // Replace with logout logic
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, Widget page) {
    final isSelected = title == selectedItem;
    return Container(
      color: isSelected ? Colors.blue.shade100 : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, size: 20, color: isSelected ? Colors.blue : Colors.black87),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.blue : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => _navigate(context, title, page),
      ),
    );
  }
}
