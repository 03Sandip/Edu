import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../widgets/nav_widgets.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<dynamic> students = [];
  List<dynamic> filteredStudents = [];
  Map<String, String> attendance = {};
  bool isLoading = true;
  String searchText = '';
  String selectedSemester = 'Sem 1';
  String selectedSection = 'CSE1';

  final List<String> semesters = [
    'Sem 1', 'Sem 2', 'Sem 3', 'Sem 4',
    'Sem 5', 'Sem 6', 'Sem 7', 'Sem 8'
  ];
  final List<String> sections = ['CSE1', 'CSE2'];

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      final res = await http.get(Uri.parse('${Constants.uri}/students'));
      if (res.statusCode == 200) {
        setState(() {
          students = json.decode(res.body);
          filteredStudents = students;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      print("Error fetching students: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterStudents(String query) {
    setState(() {
      searchText = query;
      filteredStudents = students.where((student) {
        final roll = student['roll']?.toLowerCase() ?? '';
        return roll.contains(query.toLowerCase());
      }).toList();
    });
  }

  void markAttendance(String roll, String status) {
    setState(() {
      attendance[roll] = status;
    });
  }

  void submitAttendance() {
    print('Attendance Submitted: $attendance');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance submitted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Row(
        children: [
          const SideNavBar(selectedItem: 'Attendance'),

          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Attendance',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

                // Filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      // Search Box
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search by Roll Number...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          ),
                          onChanged: filterStudents,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Semester Dropdown
                      DropdownButton<String>(
                        value: selectedSemester,
                        onChanged: (value) {
                          setState(() {
                            selectedSemester = value!;
                          });
                        },
                        items: semesters.map((sem) {
                          return DropdownMenuItem(value: sem, child: Text(sem));
                        }).toList(),
                      ),
                      const SizedBox(width: 16),
                      // Section Dropdown
                      DropdownButton<String>(
                        value: selectedSection,
                        onChanged: (value) {
                          setState(() {
                            selectedSection = value!;
                          });
                        },
                        items: sections.map((sec) {
                          return DropdownMenuItem(value: sec, child: Text(sec));
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredStudents.isEmpty
                          ? const Center(child: Text('No students found.'))
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: filteredStudents.length,
                                      itemBuilder: (context, index) {
                                        final student = filteredStudents[index];
                                        final roll = student['roll'] ?? '';
                                        final name = student['name'] ?? 'Unknown';

                                        return Card(
                                          elevation: 2,
                                          margin: const EdgeInsets.symmetric(vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 16),
                                            child: Row(
                                              children: [
                                                const CircleAvatar(
                                                  backgroundColor: Colors.blueAccent,
                                                  child: Icon(Icons.person, color: Colors.white),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(name,
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold)),
                                                      Text('Roll: $roll',
                                                          style: const TextStyle(
                                                              color: Colors.black54,
                                                              fontSize: 14)),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    ChoiceChip(
                                                      label: const Text("Present"),
                                                      selected: attendance[roll] == "Present",
                                                      selectedColor: Colors.green[300],
                                                      onSelected: (_) =>
                                                          markAttendance(roll, "Present"),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    ChoiceChip(
                                                      label: const Text("Absent"),
                                                      selected: attendance[roll] == "Absent",
                                                      selectedColor: Colors.red[300],
                                                      onSelected: (_) =>
                                                          markAttendance(roll, "Absent"),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.check),
                                    onPressed: submitAttendance,
                                    label: const Text("Submit Attendance"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 14),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
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
