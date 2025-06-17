import 'dart:convert';
import 'package:edu/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Add intl package for date formatting

class AttendanceViewPage extends StatefulWidget {
  final String rollNumber;

  const AttendanceViewPage({super.key, required this.rollNumber});

  @override
  State<AttendanceViewPage> createState() => _AttendanceViewPageState();
}

class _AttendanceViewPageState extends State<AttendanceViewPage> {
  List<dynamic> attendanceData = [];
  bool isLoading = true;

  int presentCount = 0;
  int absentCount = 0;

  @override
  void initState() {
    super.initState();
    fetchAttendance(widget.rollNumber);
  }

  Future<void> fetchAttendance(String roll) async {
    final url = Uri.parse('${Constants.uri}/api/attendance?roll=$roll');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List;

        int present = 0;
        int absent = 0;

        for (var record in data) {
          if (record['status'] == 'Present') {
            present++;
          } else if (record['status'] == 'Absent') {
            absent++;
          }
        }

        // Sort by date descending
        data.sort((a, b) {
          final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA);
        });

        setState(() {
          attendanceData = data;
          presentCount = present;
          absentCount = absent;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load attendance: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching attendance: $e');
      setState(() => isLoading = false);
    }
  }

  Widget buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text("Present", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(presentCount.toString(), style: const TextStyle(color: Colors.green)),
              ],
            ),
            Column(
              children: [
                const Text("Absent", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(absentCount.toString(), style: const TextStyle(color: Colors.red)),
              ],
            ),
            Column(
              children: [
                const Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
                Text((presentCount + absentCount).toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Attendance")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : attendanceData.isEmpty
              ? const Center(child: Text("No attendance records found"))
              : Column(
                  children: [
                    buildSummaryCard(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: attendanceData.length,
                        itemBuilder: (context, index) {
                          final item = attendanceData[index];
                          final formattedDate = item['date'] != null
                              ? DateFormat('dd MMM yyyy').format(DateTime.parse(item['date']))
                              : 'N/A';

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text("Subject: ${item['subject'] ?? 'N/A'}"),
                              subtitle: Text("Date: $formattedDate"),
                              trailing: Text(
                                item['status'] == 'Present' ? "✔ Present" : "✘ Absent",
                                style: TextStyle(
                                  color: item['status'] == 'Present' ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
