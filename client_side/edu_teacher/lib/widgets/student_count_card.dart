import 'package:edu_teacher/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class StudentCountCard extends StatefulWidget {
  const StudentCountCard({super.key});

  @override
  State<StudentCountCard> createState() => _StudentCountCardState();
}

class _StudentCountCardState extends State<StudentCountCard> {
  int? count;
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
          count = data['count'];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load count");
      }
    } catch (e) {
      print("Error fetching student count: $e");
      setState(() {
        count = 0;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      DateFormat('d MMM yyyy').format(DateTime.now()),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    count.toString(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text("Students", style: TextStyle(fontSize: 14)),
                ],
              ),
      ),
    );
  }
}
