import 'dart:convert';
import 'package:edu/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants.dart';

class StudentAssignmentsPage extends StatefulWidget {
  const StudentAssignmentsPage({super.key});

  @override
  State<StudentAssignmentsPage> createState() => _StudentAssignmentsPageState();
}

class _StudentAssignmentsPageState extends State<StudentAssignmentsPage> {
  String? semester;
  String? section;
  String? selectedSubject;
  List<String> subjects = [];
  List<dynamic> assignments = [];
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    semester ??= user.semester;
    section ??= user.section;
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    if (semester == null) return;

    try {
      final res = await http.get(
        Uri.parse('${Constants.uri}/api/assign-subjects?semester=$semester'),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data is Map && data.containsKey('subjects')) {
          setState(() {
            subjects = List<String>.from(data['subjects']);
          });
        } else if (data is List) {
          setState(() {
            subjects = List<String>.from(data);
          });
        } else {
          _showMessage("Invalid subject data format");
        }
      } else {
        _showMessage("Failed to load subjects (Status code: ${res.statusCode})");
      }
    } catch (e) {
      _showMessage("Error fetching subjects: $e");
    }
  }

  Future<void> fetchAssignments() async {
    if (semester == null || section == null || selectedSubject == null) return;

    setState(() => isLoading = true);
    try {
      final uri = Uri.parse(
        '${Constants.uri}/api/assignments?semester=$semester&section=$section&subject=$selectedSubject',
      );
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() => assignments = data);
      } else {
        _showMessage("Failed to fetch assignments (Status ${res.statusCode})");
      }
    } catch (e) {
      _showMessage("Error fetching assignments: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openAssignment(String url) async {
    final fullUrl = '${Constants.uri}$url';
    final uri = Uri.parse(fullUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showMessage("Could not open assignment URL");
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return "Uploaded on: ${dateTime.day}/${dateTime.month}/${dateTime.year}";
    } catch (_) {
      return "Uploaded on: Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Assignments")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: semester == null || section == null
            ? const Center(child: Text("User semester/section not available"))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Semester: $semester", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("Section: $section", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedSubject,
                    hint: const Text("Select Subject"),
                    items: subjects.map((subj) {
                      return DropdownMenuItem(value: subj, child: Text(subj));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSubject = value;
                        assignments.clear();
                      });
                      fetchAssignments();
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : assignments.isEmpty
                            ? const Center(child: Text("No assignments found"))
                            : ListView.builder(
                                itemCount: assignments.length,
                                itemBuilder: (context, index) {
                                  final assignment = assignments[index];
                                  final uploadDate = assignment['uploadDate'];

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (uploadDate != null)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 4.0),
                                          child: Text(
                                            _formatDate(uploadDate),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      Card(
                                        elevation: 2,
                                        child: ListTile(
                                          leading: const Icon(Icons.description, color: Colors.deepPurple),
                                          title: Text('Assignment ${index + 1}'),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.open_in_new),
                                            onPressed: () => _openAssignment(assignment['fileUrl']),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  );
                                },
                              ),
                  ),
                ],
              ),
      ),
    );
  }
}
