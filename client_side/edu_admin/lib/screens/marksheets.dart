import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/constants.dart';
import '../../utils/dropdown_constants.dart';
import '../widgets/nav_widgets.dart';

class AdminMarksheetUploadPage extends StatefulWidget {
  const AdminMarksheetUploadPage({super.key});

  @override
  State<AdminMarksheetUploadPage> createState() => _AdminMarksheetUploadPageState();
}

class _AdminMarksheetUploadPageState extends State<AdminMarksheetUploadPage> {
  String? selectedSemester;
  String? selectedSection;
  String? roll;
  String studentName = '';
  PlatformFile? pickedFile;
  Uint8List? fileBytes;
  bool isUploading = false;
  String? uploadStatus;
  List<Map<String, dynamic>> uploadedMarksheets = [];
  List<Map<String, String>> validRollsWithNames = [];

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        pickedFile = result.files.single;
        fileBytes = result.files.single.bytes;
        uploadStatus = null;
      });
    }
  }

  Future<void> fetchValidRolls() async {
    if (selectedSemester == null || selectedSection == null) return;

    try {
      final res = await http.get(Uri.parse('${Constants.uri}/students'));
      if (res.statusCode == 200) {
        final allStudents = jsonDecode(res.body) as List;
        final filtered = allStudents.where((s) =>
            s['semester'] == selectedSemester &&
            s['section'] == selectedSection).toList();

        setState(() {
          validRollsWithNames = filtered.map<Map<String, String>>((s) => {
            'roll': s['roll'].toString(),
            'name': s['name'].toString()
          }).toList();
        });
      } else {
        setState(() => validRollsWithNames = []);
      }
    } catch (e) {
      debugPrint("❌ Error fetching rolls: $e");
      setState(() => validRollsWithNames = []);
    }
  }

  Future<void> uploadMarksheet() async {
    if (selectedSemester == null || selectedSection == null || roll == null || pickedFile == null || fileBytes == null || roll!.trim().isEmpty) {
      setState(() => uploadStatus = 'Please fill all fields and select a file.');
      return;
    }

    setState(() {
      isUploading = true;
      uploadStatus = null;
    });

    final checkRes = await http.get(Uri.parse(
        '${Constants.uri}/marksheet/check?roll=$roll&semester=$selectedSemester&section=${Uri.encodeComponent(selectedSection!)}'));

    final exists = checkRes.statusCode == 200 && jsonDecode(checkRes.body)['exists'] == true;

    if (exists) {
      setState(() {
        uploadStatus = '❌ Marksheet already uploaded. Please delete it before uploading again.';
        isUploading = false;
      });
      return;
    }

    final url = '${Constants.uri}/marksheet/upload';
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['semester'] = selectedSemester!;
    request.fields['section'] = selectedSection!;
    request.fields['roll'] = roll!;
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      fileBytes!,
      filename: pickedFile!.name,
    ));

    final response = await request.send();

    if (response.statusCode == 201) {
      setState(() {
        uploadStatus = '✅ Marksheet uploaded successfully!';
        pickedFile = null;
        fileBytes = null;
        roll = null;
        studentName = '';
      });
      fetchMarksheets();
    } else {
      setState(() => uploadStatus = '❌ Upload failed. Try again.');
    }

    setState(() => isUploading = false);
  }

  Future<void> fetchMarksheets() async {
    if (selectedSemester == null || selectedSection == null) return;
    final res = await http.get(Uri.parse('${Constants.uri}/marksheet/list?semester=$selectedSemester&section=${Uri.encodeComponent(selectedSection!)}'));
    if (res.statusCode == 200) {
      setState(() => uploadedMarksheets = List<Map<String, dynamic>>.from(jsonDecode(res.body)));
    }
  }

  Future<void> deleteMarksheet(String roll) async {
    final res = await http.delete(Uri.parse('${Constants.uri}/marksheet/delete?roll=$roll&semester=$selectedSemester&section=${Uri.encodeComponent(selectedSection!)}'));
    if (res.statusCode == 200) {
      fetchMarksheets();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SideNavBar(selectedItem: 'Results'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Marksheet Upload', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Semester'),
                          value: selectedSemester,
                          items: DropdownConstants.semesters.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedSemester = val;
                              roll = null;
                              studentName = '';
                              validRollsWithNames.clear();
                            });
                            fetchMarksheets();
                            fetchValidRolls();
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Section'),
                          value: selectedSection,
                          items: DropdownConstants.sections.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedSection = val;
                              roll = null;
                              studentName = '';
                              validRollsWithNames.clear();
                            });
                            fetchMarksheets();
                            fetchValidRolls();
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Roll No'),
                          value: roll,
                          items: validRollsWithNames.map((s) => DropdownMenuItem(value: s['roll'], child: Text('${s['roll']} - ${s['name']}'))).toList(),
                          onChanged: (val) {
                            setState(() {
                              roll = val;
                              studentName = validRollsWithNames.firstWhere((s) => s['roll'] == val)['name'] ?? '';
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        if (studentName.isNotEmpty) Text('Name: $studentName'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: pickFile,
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Pick File'),
                        ),
                        if (pickedFile != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('📄 Selected file: ${pickedFile!.name}'),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: isUploading ? null : uploadMarksheet,
                          child: isUploading ? const CircularProgressIndicator() : const Text('Upload'),
                        ),
                        if (uploadStatus != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              uploadStatus!,
                              style: TextStyle(color: uploadStatus!.contains('successfully') ? Colors.green : Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Uploaded Marksheets', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: uploadedMarksheets.length,
                            itemBuilder: (context, index) {
                              final m = uploadedMarksheets[index];
                              final matchedStudent = validRollsWithNames.firstWhere(
                                (s) => s['roll'] == m['roll'].toString(),
                                orElse: () => {'name': 'Unknown'}
                              );
                              final studentName = matchedStudent['name'] ?? 'Unknown';
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                child: ListTile(
                                  title: Text('Roll: ${m['roll']} - $studentName'),
                                  subtitle: Text(m['fileUrl'] ?? ''),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => deleteMarksheet(m['roll']),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
