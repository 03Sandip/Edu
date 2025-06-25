import 'package:flutter/material.dart';
import '../widgets/nav_widgets.dart';
import '../widgets/student_list.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  String? selectedSemesterUI;
  String? selectedSectionUI;

  final Map<String, String> semesterMap = {
    'Sem 1': '1st',
    'Sem 2': '2nd',
    'Sem 3': '3rd',
    'Sem 4': '4th',
    'Sem 5': '5th',
    'Sem 6': '6th',
    'Sem 7': '7th',
    'Sem 8': '8th',
  };

  final Map<String, String> sectionMap = {
    'CSE1': 'CSE 1',
    'CSE2': 'CSE 2',
  };

  final List<String> semesters = [
    'Sem 1', 'Sem 2', 'Sem 3', 'Sem 4',
    'Sem 5', 'Sem 6', 'Sem 7', 'Sem 8'
  ];

  final List<String> sections = ['CSE1', 'CSE2'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Row(
        children: [
          const SideNavBar(selectedItem: 'Students'),
          Expanded(
            child: Column(
              children: [
                // Top bar with "Students List" and search
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Students List',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 24),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF0F0F0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.message_outlined),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Sandip Paul", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("Admin", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          const SizedBox(width: 12),
                          const CircleAvatar(child: Text("A")),
                        ],
                      ),
                    ],
                  ),
                ),

                // Filter Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      DropdownButton<String>(
                        hint: const Text("Select Semester"),
                        value: selectedSemesterUI,
                        onChanged: (value) {
                          setState(() => selectedSemesterUI = value);
                        },
                        items: semesters.map((sem) {
                          return DropdownMenuItem(value: sem, child: Text(sem));
                        }).toList(),
                      ),
                      const SizedBox(width: 20),
                      DropdownButton<String>(
                        hint: const Text("Select Section"),
                        value: selectedSectionUI,
                        onChanged: (value) {
                          setState(() => selectedSectionUI = value);
                        },
                        items: sections.map((sec) {
                          return DropdownMenuItem(value: sec, child: Text(sec));
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Student list
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: StudentList(
                      selectedSemester: selectedSemesterUI != null ? semesterMap[selectedSemesterUI!] : null,
                      selectedSection: selectedSectionUI != null ? sectionMap[selectedSectionUI!] : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
