import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:edu_admin/widgets/nav_widgets.dart';
import 'package:edu_admin/widgets/calendar_page.dart';
import 'package:edu_admin/widgets/student_count_card.dart';
import 'package:edu_admin/utils/constants.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String selectedSemester = '1st Sem';
  final List<String> semesters = ['1st Sem', '2nd Sem', '3rd Sem', '4th Sem'];
  int studentCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentCount();
  }

  Future<void> fetchStudentCount() async {
    try {
      final response = await http.get(Uri.parse('${Constants.uri}/student-count'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          studentCount = data['count'] ?? 0;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load student count');
      }
    } catch (e) {
      setState(() {
        studentCount = 0;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              const SideNavBar(selectedItem: 'Home'),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 300,
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search...',
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Color(0xFFF0F0F0),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              DropdownButton<String>(
                                value: selectedSemester,
                                items: semesters
                                    .map((sem) => DropdownMenuItem(value: sem, child: Text(sem)))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedSemester = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
                              IconButton(icon: const Icon(Icons.message_outlined), onPressed: () {}),
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
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                isLoading
                                    ? const Expanded(
                                        child: Center(child: CircularProgressIndicator()),
                                      )
                                    : const StudentCountCard(),
                                _buildStatCard("Teachers", "124", Colors.amber),
                                _buildStatCard("Staffs", "30", Colors.amber),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(child: _buildPlaceholderBox("Gender Ratio (Chart)", height: 220)),
                                          const SizedBox(width: 16),
                                          Expanded(child: _buildPlaceholderBox("Attendance Bar Chart", height: 220)),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      _buildPlaceholderBox("Finance Line Chart", height: 260),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      const CalendarCard(),
                                      const SizedBox(height: 16),
                                      _buildPlaceholderBox("Events List", height: 150),
                                      const SizedBox(height: 16),
                                      _buildPlaceholderBox("Announcements", height: 120),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text("2024/25", style: TextStyle(fontSize: 10)),
            ),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderBox(String label, {double height = 200}) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
