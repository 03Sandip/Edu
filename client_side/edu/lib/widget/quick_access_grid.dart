import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu/quickaccess/subject_page.dart';
import 'package:edu/quickaccess/notes_page.dart';
import 'package:edu/provider/user_provider.dart';

const List<Map<String, dynamic>> quickAccessItems = [
  {"title": "Syllabus", "icon": Icons.menu_book, "color": Colors.teal},
  {"title": "Notes", "icon": Icons.note, "color": Colors.pinkAccent},
  {"title": "Assigment", "icon": Icons.book, "color": Colors.purple},
  {"title": "Routine", "icon": Icons.schedule, "color": Colors.orange},
  {"title": "Attendance", "icon": Icons.check_circle, "color": Colors.blue},
  {"title": "Lab", "icon": Icons.computer, "color": Colors.grey},
  {"title": "Marks", "icon": Icons.score, "color": Colors.green},
  {"title": "Library", "icon": Icons.library_books, "color": Colors.amber},
  {"title": "Fees", "icon": Icons.attach_money_rounded, "color": Colors.deepOrange},
  {"title": "Subjects", "icon": Icons.book, "color": Color.fromARGB(255, 68, 0, 255)},
];

class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final semester = user.semester;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quickAccessItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final item = quickAccessItems[index];

        return GestureDetector(
          onTap: () {
            if (item['title'] == 'Subjects') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubjectPage()),
              );
            } else if (item['title'] == 'Notes') {
              if (semester != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudentNotesPage(semester: semester),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Semester not found")),
                );
              }
            }
            // Add more conditions here for other pages if needed
          },
          child: Container(
            decoration: BoxDecoration(
              color: item['color'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'], size: 40, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  item['title'],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
