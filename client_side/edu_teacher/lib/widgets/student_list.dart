import 'package:edu_teacher/screens/student_detail_page.dart';
import 'package:edu_teacher/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class StudentList extends StatefulWidget {
  final String? selectedSemester;
  final String? selectedSection;

  const StudentList({
    super.key,
    this.selectedSemester,
    this.selectedSection,
  });

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  List<dynamic> students = [];
  List<dynamic> filteredStudents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      final response = await http.get(Uri.parse('${Constants.uri}/students'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          students = data;
          applyFilter();
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

  void applyFilter() {
    setState(() {
      filteredStudents = students.where((student) {
        final matchesSemester = widget.selectedSemester == null ||
            student['semester'] == widget.selectedSemester;
        final matchesSection = widget.selectedSection == null ||
            student['section'] == widget.selectedSection;
        return matchesSemester && matchesSection;
      }).toList();
    });
  }

  Future<void> refreshList() async {
    setState(() {
      isLoading = true;
    });
    await fetchStudents();
  }

  @override
  void didUpdateWidget(covariant StudentList oldWidget) {
    super.didUpdateWidget(oldWidget);
    applyFilter(); // Re-filter if parent updates filters
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredStudents.isEmpty) {
      return const Center(child: Text('No students found.'));
    }

    return RefreshIndicator(
      onRefresh: refreshList,
      child: ListView.builder(
        itemCount: filteredStudents.length,
        itemBuilder: (context, index) {
          final student = filteredStudents[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(student['name'] ?? 'Unknown'),
              subtitle: Text(
                'Roll: ${student['roll'] ?? 'N/A'} | Section: ${student['section'] ?? 'N/A'}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentDetailPage(student: student),
                  ),
                );
                refreshList(); // Refresh after returning
              },
            ),
          );
        },
      ),
    );
  }
}
