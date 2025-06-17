import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class StudentNotesPage extends StatefulWidget {
  final String semester;
  const StudentNotesPage({super.key, required this.semester});

  @override
  State<StudentNotesPage> createState() => _StudentNotesPageState();
}

class _StudentNotesPageState extends State<StudentNotesPage> {
  List<dynamic> notes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    try {
      final url = Uri.parse('${Constants.uri}/api/notes?semester=${widget.semester}');
      final response = await http.get(url);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map && decoded['notes'] is List) {
          setState(() {
            notes = decoded['notes'];
            isLoading = false;
          });
        } else {
          _showMessage('Invalid response format from server');
          setState(() => isLoading = false);
        }
      } else {
        _showMessage('Failed to load notes');
        setState(() => isLoading = false);
      }
    } catch (e) {
      _showMessage('Error fetching notes: $e');
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Notes"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? const Center(child: Text("No notes available"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.description, color: Colors.deepPurple),
                        title: Text(note['subject'] ?? 'Unknown Subject'),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () {
                            _showMessage("File open feature coming soon");
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
