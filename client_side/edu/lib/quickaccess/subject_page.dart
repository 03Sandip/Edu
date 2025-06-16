import 'dart:convert';
import 'package:edu/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SubjectPage extends StatefulWidget {
  const SubjectPage({Key? key}) : super(key: key);

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  String? semester;
  List<String> subjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserAndSubjects();
  }

  Future<void> fetchUserAndSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-auth-token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not logged in")),
      );
      return;
    }

    try {
      // 1. Get logged-in user's semester
      final userRes = await http.get(
        Uri.parse('${Constants.uri}/api'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token, // ✅ Corrected header
        },
      );

      if (userRes.statusCode != 200) {
        throw Exception("Failed to get user");
      }

      final userData = jsonDecode(userRes.body);
      semester = userData['semester'];

      // 2. Fetch subjects for that semester
      final subRes = await http.get(
        Uri.parse('${Constants.uri}/api/assign-subjects?semester=$semester'),
      );

      if (subRes.statusCode != 200) {
        throw Exception("No subjects found for $semester");
      }

      final subData = jsonDecode(subRes.body);
      setState(() {
        subjects = List<String>.from(subData['subjects']);
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : subjects.isEmpty
              ? const Center(child: Text("No subjects assigned yet"))
              : ListView.builder(
                  itemCount: subjects.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: const Icon(Icons.book),
                    title: Text(subjects[index]),
                  ),
                ),
    );
  }
}
