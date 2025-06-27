import 'package:edu/quickaccess/fees_page.dart';
import 'package:edu/quickaccess/library.dart';
import 'package:flutter/material.dart';
import 'package:edu/quickaccess/assigment.dart';
import 'package:edu/quickaccess/attendance_page.dart';
import 'package:edu/quickaccess/marksheet_page.dart';
import 'package:edu/quickaccess/subject_page.dart';
import 'package:edu/quickaccess/notes_page.dart';
import 'package:edu/provider/user_provider.dart';
import 'package:provider/provider.dart';

const List<Map<String, dynamic>> quickAccessItems = [
  {"title": "Syllabus", "icon": Icons.menu_book, "colors": [Colors.teal, Colors.tealAccent]},
  {"title": "Notes", "icon": Icons.note, "colors": [Colors.pink, Colors.pinkAccent]},
  {"title": "Assignment", "icon": Icons.book, "colors": [Colors.deepPurple, Colors.purpleAccent]},
  //{"title": "Routine", "icon": Icons.schedule, "colors": [Colors.orange, Colors.deepOrangeAccent]},
  {"title": "Attendance", "icon": Icons.check_circle, "colors": [Colors.blue, Colors.lightBlueAccent]},
  {"title": "Lab", "icon": Icons.computer, "colors": [Colors.grey, Colors.blueGrey]},
  {"title": "Marks", "icon": Icons.score, "colors": [Colors.green, Colors.lightGreen]},
  {"title": "Library", "icon": Icons.library_books, "colors": [Colors.amber, Colors.yellowAccent]},
  {"title": "Fees", "icon": Icons.attach_money_rounded, "colors": [Colors.deepOrange, Colors.orangeAccent]},
  {"title": "Subjects", "icon": Icons.book, "colors": [Color(0xFF4400FF), Color(0xFF826CFF)]},
];

class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({Key? key}) : super(key: key);

  void _handleNavigation(BuildContext context, String title, String semester, String roll) {
    switch (title) {
      case 'Subjects':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SubjectPage()));
        break;
      case 'Notes':
        Navigator.push(context, MaterialPageRoute(builder: (_) => StudentNotesPage(semester: semester)));
        break;
      case 'Assignment':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentAssignmentsPage()));
        break;
      case 'Attendance':
        Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceViewPage(rollNumber: roll)));
        break;
      case 'Marks':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MarksheetPage()));
        break;
      case 'Library':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentLibraryPage()));
        break;
        case 'Fees':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentFeesPage()));
        break;
      // TODO: Add more pages (e.g., Library, Fees) here
    }
  }
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final semester = user.semester;
    final roll = user.roll;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quickAccessItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final item = quickAccessItems[index];

        return GestureDetector(
          onTap: () => _handleNavigation(context, item['title'], semester, roll),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: List<Color>.from(item['colors']),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'], size: 36, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  item['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
