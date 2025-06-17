import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';
import '../../widgets/nav_widgets.dart';

class UploadNotesPage extends StatefulWidget {
  const UploadNotesPage({super.key});

  @override
  State<UploadNotesPage> createState() => _UploadNotesPageState();
}

class _UploadNotesPageState extends State<UploadNotesPage> {
  String? selectedSemester;
  String? selectedSubject;
  Uint8List? fileBytes;
  String? fileName;
  bool isUploading = false;
  List<dynamic> uploadedNotes = [];

  final List<String> semesters = [
    '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th',
  ];
  List<String> subjects = [];

  Future<void> fetchSubjects(String semester) async {
    try {
      final res = await http.get(Uri.parse('${Constants.uri}/assign-subjects?semester=$semester'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          subjects = List<String>.from(data['subjects']);
          selectedSubject = null;
        });
      } else {
        _showMessage("No subjects found for $semester");
        setState(() {
          subjects = [];
          selectedSubject = null;
        });
      }
    } catch (e) {
      _showMessage("Error loading subjects");
      setState(() {
        subjects = [];
        selectedSubject = null;
      });
    }
  }

  Future<void> fetchUploadedNotes() async {
    if (selectedSemester == null) return;
    try {
      final res = await http.get(Uri.parse('${Constants.uri}/notes?semester=$selectedSemester'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          uploadedNotes = data['notes'] ?? [];
        });
      } else {
        _showMessage("Failed to load uploaded notes");
      }
    } catch (e) {
      _showMessage("Failed to load uploaded notes");
    }
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        setState(() {
          fileBytes = result.files.first.bytes!;
          fileName = result.files.first.name;
        });
      } else {
        _showMessage("No file selected");
      }
    } catch (e) {
      _showMessage("Error picking file: $e");
    }
  }

  Future<void> uploadNote() async {
    if (selectedSemester == null || selectedSubject == null || fileBytes == null || fileName == null) {
      _showMessage("All fields are required");
      return;
    }

    setState(() => isUploading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.uri}/notes'),
      );

      request.fields['semester'] = selectedSemester!;
      request.fields['subject'] = selectedSubject!;

      request.files.add(http.MultipartFile.fromBytes(
        'noteFile',
        fileBytes!,
        filename: fileName!,
      ));

      final response = await request.send();

      if (response.statusCode == 201) {
        _showMessage("Note uploaded successfully");
        setState(() {
          fileBytes = null;
          fileName = null;
        });
        fetchUploadedNotes();
      } else {
        _showMessage("Failed to upload note");
      }
    } catch (e) {
      _showMessage("Upload error: $e");
    } finally {
      setState(() => isUploading = false);
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      final res = await http.delete(Uri.parse('${Constants.uri}/notes/$noteId'));
      if (res.statusCode == 200) {
        _showMessage("Note deleted successfully");
        fetchUploadedNotes();
      } else {
        _showMessage("Failed to delete note");
      }
    } catch (e) {
      _showMessage("Delete error: $e");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SideNavBar(selectedItem: 'Notes'),
          Expanded(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Notes",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      // Upload Form (Left Section)
                      Flexible(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DropdownButtonFormField<String>(
                                value: selectedSemester,
                                hint: const Text("Select Semester"),
                                items: semesters.map((sem) {
                                  return DropdownMenuItem(value: sem, child: Text(sem));
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => selectedSemester = value);
                                  if (value != null) {
                                    fetchSubjects(value);
                                    fetchUploadedNotes();
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: selectedSubject,
                                hint: const Text("Select Subject"),
                                items: subjects.map((subj) {
                                  return DropdownMenuItem(value: subj, child: Text(subj));
                                }).toList(),
                                onChanged: subjects.isEmpty
                                    ? null
                                    : (value) {
                                        setState(() => selectedSubject = value);
                                      },
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: pickFile,
                                icon: const Icon(Icons.attach_file),
                                label: const Text("Pick File"),
                              ),
                              if (fileName != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    fileName!,
                                    style: const TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: isUploading ? null : uploadNote,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.deepPurple,
                                ),
                                child: isUploading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        "Upload",
                                        style: TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Uploaded Notes List (Right Section)
                      Flexible(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: uploadedNotes.isEmpty
                              ? const Center(child: Text("No uploaded files"))
                              : ListView.builder(
                                  itemCount: uploadedNotes.length,
                                  itemBuilder: (context, index) {
                                    final note = uploadedNotes[index];
                                    return Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      child: ListTile(
                                        leading: const Icon(Icons.description, color: Colors.deepPurple),
                                        title: Text(note['subject'] ?? 'Unknown Subject'),
                                        subtitle: Text(note['filePath']?.split('/')?.last ?? ''),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text("Delete Note"),
                                                content: const Text("Are you sure you want to delete this note?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(ctx, false),
                                                    child: const Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(ctx, true),
                                                    child: const Text("Delete"),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              await deleteNote(note['_id']);
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
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
