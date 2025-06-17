import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AttendanceStatsPage extends StatefulWidget {
  final String roll;

  const AttendanceStatsPage({super.key, required this.roll});

  @override
  State<AttendanceStatsPage> createState() => _AttendanceStatsPageState();
}

class _AttendanceStatsPageState extends State<AttendanceStatsPage> {
  Map<String, dynamic> summary = {};
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    setState(() {
      isLoading = true;
      error = null;
      summary = {};
    });

    try {
      final res = await http.get(Uri.parse('${Constants.uri}/api/attendance?roll=${widget.roll}'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() => summary = data['summary'] ?? {});
      } else {
        setState(() => error = 'Failed to fetch data');
      }
    } catch (e) {
      setState(() => error = 'Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildSubjectCard(String subject, int present, int total) {
    final percent = total > 0 ? ((present / total) * 100).toStringAsFixed(1) : '0.0';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: ListTile(
        title: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Present: $present / $total'),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: total > 0 ? present / total : 0,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 6,
            ),
          ],
        ),
        trailing: Text(
          '$percent%',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance Stats - Roll ${widget.roll}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
                : summary.isEmpty
                    ? const Center(child: Text('No data available for this student'))
                    : ListView(
                        children: summary.entries.map((entry) {
                          final subject = entry.key;
                          final present = entry.value['present'] ?? 0;
                          final total = entry.value['total'] ?? 0;
                          return buildSubjectCard(subject, present, total);
                        }).toList(),
                      ),
      ),
    );
  }
}
