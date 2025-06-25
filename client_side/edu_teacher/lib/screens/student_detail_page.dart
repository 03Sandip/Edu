import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../widgets/delete_confirmation.dart';

class StudentDetailPage extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentDetailPage({super.key, required this.student, String? selectedSubject});

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  late TextEditingController nameController;
  late TextEditingController rollController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController sectionController;
  late TextEditingController semesterController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.student['name']);
    rollController = TextEditingController(text: widget.student['roll']);
    phoneController = TextEditingController(text: widget.student['phone']);
    emailController = TextEditingController(text: widget.student['email']);
    sectionController = TextEditingController(text: widget.student['section']);
    semesterController = TextEditingController(text: widget.student['semester']);
  }

  Future<void> updateStudent() async {
    final id = widget.student['_id'];
    final url = Uri.parse('${Constants.uri}/students/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': nameController.text,
        'roll': rollController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        'section': sectionController.text,
        'semester': semesterController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() => isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update student')),
      );
    }
  }

  Future<void> deleteStudent() async {
    final id = widget.student['_id'];
    final url = Uri.parse('${Constants.uri}/students/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student deleted')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete student')));
    }
  }

  Widget buildTextField(String label, IconData icon, TextEditingController controller, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: enabled ? Colors.grey[100] : Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.student['image'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // Student Image (Larger)
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : const AssetImage('assets/default_avatar.png') as ImageProvider,
                      ),
                      const SizedBox(height: 20),

                      buildTextField('Name', Icons.person, nameController, isEditing),
                      buildTextField('Roll', Icons.confirmation_number, rollController, isEditing),
                      buildTextField('Phone', Icons.phone, phoneController, isEditing),
                      buildTextField('Email', Icons.email, emailController, isEditing),
                      buildTextField('Section', Icons.class_, sectionController, isEditing),
                      buildTextField('Semester', Icons.calendar_today, semesterController, isEditing),

                      const SizedBox(height: 20),

                      if (isEditing)
                        ElevatedButton.icon(
                          onPressed: updateStudent,
                          icon: const Icon(Icons.save),
                          label: const Text('Update'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),

                      const SizedBox(height: 12),

                      ElevatedButton.icon(
                        onPressed: () async {
                          final confirmed = await showDeleteConfirmationDialogs(context);
                          if (confirmed) {
                            deleteStudent();
                          }
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Pencil Icon inside top-right of card
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(isEditing ? Icons.cancel : Icons.edit, color: Colors.grey[700]),
                  onPressed: () {
                    setState(() => isEditing = !isEditing);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
