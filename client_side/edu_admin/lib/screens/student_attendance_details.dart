import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class StudentAttendanceDetailsPage extends StatefulWidget {
  final String roll;
  final String name;

  const StudentAttendanceDetailsPage({
    Key? key,
    required this.roll,
    required this.name,
  }) : super(key: key);

  @override
  State<StudentAttendanceDetailsPage> createState() =>
      _StudentAttendanceDetailsPageState();
}

class _StudentAttendanceDetailsPageState extends State<StudentAttendanceDetailsPage> {
  List<dynamic> attendanceData = [];
  bool isLoading = true;
  int present = 0;
  int absent = 0;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    try {
      final res = await http.get(Uri.parse('${Constants.uri}/attendance/${widget.roll}'));

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          attendanceData = data;
          present = data.where((e) => e['status'] == 'Present').length;
          absent = data.where((e) => e['status'] == 'Absent').length;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error fetching student attendance: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = present + absent;
    final percentage = total > 0 ? (present / total * 100).toStringAsFixed(1) : '0';

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.name} (${widget.roll}) Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryBox('Total', total.toString(), Colors.grey[700]!),
                          _buildSummaryBox('Present', present.toString(), Colors.green),
                          _buildSummaryBox('Absent', absent.toString(), Colors.red),
                          _buildSummaryBox('Attendance %', '$percentage%', Colors.blueAccent),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Attendance History',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: attendanceData.length,
                      itemBuilder: (context, index) {
                        final item = attendanceData[index];
                        final date = DateFormat('dd MMM yyyy')
                            .format(DateTime.parse(item['date']));
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(item['subject'] ?? ''),
                            subtitle: Text('Date: $date'),
                            trailing: Chip(
                              label: Text(item['status']),
                              backgroundColor: item['status'] == 'Present'
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              labelStyle: TextStyle(
                                color: item['status'] == 'Present'
                                    ? Colors.green[800]
                                    : Colors.red[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryBox(String title, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(title, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}
