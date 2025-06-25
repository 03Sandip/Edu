import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:edu_admin/data/semester_subjects.dart';
import 'package:edu_admin/widgets/nav_widgets.dart';
import 'package:edu_admin/utils/constants.dart';

class SubjectPage extends StatefulWidget {
  const SubjectPage({Key? key}) : super(key: key);

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  String? selectedSemester = '1st';
  List<String> selectedSubjects = [];
  bool isLoading = false;

  void handleSemesterChange(String? semester) {
    setState(() {
      selectedSemester = semester;
      selectedSubjects = [];
    });
  }

  Future<void> handleSubmit() async {
    if (selectedSemester == null || selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a semester and at least one subject')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${Constants.uri}/assign-subjects'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'semester': selectedSemester,
          'subjects': selectedSubjects,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subjects assigned successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableSubjects = semesterSubjects[selectedSemester] ?? [];

    return Scaffold(
      body: Row(
        children: [
          const SideNavBar(selectedItem: "Subjects"),

          Expanded(
            child: Center(
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Subject Selection for ${selectedSemester ?? ''} Semester",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),

                      Text("Choose Semester",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800])),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: selectedSemester,
                          isExpanded: true,
                          underline: const SizedBox(),
                          onChanged: handleSemesterChange,
                          items: semesterSubjects.keys.map((sem) {
                            return DropdownMenuItem(
                              value: sem,
                              child: Text('$sem Semester'),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Text("Select Subjects",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800])),
                      const SizedBox(height: 8),

                      availableSubjects.isEmpty
                          ? const Text("No subjects available for this semester.")
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: availableSubjects.map((subject) {
                                final isSelected = selectedSubjects.contains(subject);
                                return FilterChip(
                                  label: Text(subject),
                                  selected: isSelected,
                                  selectedColor: Colors.purple.shade100,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      if (selected) {
                                        selectedSubjects.add(subject);
                                      } else {
                                        selectedSubjects.remove(subject);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),

                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: isLoading ? null : handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2,
                              )
                            : const Text(
                                'Assign Subjects',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
