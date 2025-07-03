import 'package:adu_admin/utils/constants.dart';
import 'package:adu_admin/utils/dropdown_constants.dart';
import 'package:adu_admin/widgets/nav_widgets.dart';
import 'package:adu_admin/widgets/fees_student_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeesPage extends StatefulWidget {
  const FeesPage({super.key});

  @override
  State<FeesPage> createState() => _FeesPageState();
}

class _FeesPageState extends State<FeesPage> {
  String selectedSemester = DropdownConstants.semesters[0];
  String selectedSection = DropdownConstants.sections[0];
  String statusFilter = 'All';
  String searchRoll = '';
  List<Map<String, dynamic>> studentsWithFees = [];
  bool isLoading = false;
  int feeAmount = 20000;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse('${Constants.uri}/students'));
      final data = jsonDecode(res.body);

      String semNum = selectedSemester;
      String secNum = selectedSection;

      final feeStructureRes = await http.get(Uri.parse('${Constants.uri}/feestructure?semester=$semNum'));
      if (feeStructureRes.statusCode == 200) {
        final feeData = jsonDecode(feeStructureRes.body);
        if (feeData is List && feeData.isNotEmpty) {
          feeAmount = feeData[0]['amount'];
        }
      }

      List<Map<String, dynamic>> filtered = [];

      for (var student in data) {
        final sem = student['semester'].toString();
        final sec = student['section'].toString();

        if (sem == semNum && sec == secNum) {
          final roll = (student['rollNumber'] ?? student['roll'] ?? '').toString();
          final name = student['name'].toString();
          if (roll.isEmpty) continue;

          final statusRes = await http.get(Uri.parse('${Constants.uri}/fees/paidstatus?rollNumber=$roll&semester=$sem'));

          if (statusRes.statusCode == 200) {
            final paidData = jsonDecode(statusRes.body);
            final paidAmount = paidData['amount'] ?? 0;
            final isPaid = paidAmount >= feeAmount;
            filtered.add({
              'name': name,
              'roll': roll,
              'semester': sem,
              'section': sec,
              'amount': feeAmount,
              'status': isPaid ? 'Paid' : 'Unpaid',
              'date': paidData['paidDate'] ?? '-',
            });
          } else {
            filtered.add({
              'name': name,
              'roll': roll,
              'semester': sem,
              'section': sec,
              'amount': feeAmount,
              'status': 'Unpaid',
              'date': '-',
            });
          }
        }
      }

      setState(() => studentsWithFees = filtered);
    } catch (e) {
      print("❌ Fetch error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> markAsPaid(String roll) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.uri}/fees/updatestatus'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rollNumber': roll,
          'amount': feeAmount,
          'semester': selectedSemester,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        fetchStudents();
      }
    } catch (e) {
      print("Mark paid error: $e");
    }
  }

  Future<void> markAsUnpaid(String roll) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.uri}/fees/updatestatus'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rollNumber': roll,
          'amount': 0,
          'semester': selectedSemester,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        fetchStudents();
      }
    } catch (e) {
      print("Mark unpaid error: $e");
    }
  }

  Future<void> sendNotification(String roll) async {
    try {
      await http.post(
        Uri.parse('${Constants.uri}/notifications'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': 'Pending Fees Alert',
          'message': 'Your fees are unpaid. Please pay as soon as possible.',
          'rollNumber': roll, // ✅ Send directly
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification sent to $roll')),
      );
    } catch (e) {
      print("❌ Notification error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideNavBar(selectedItem: "Fees"),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: selectedSemester,
                        onChanged: (value) {
                          setState(() => selectedSemester = value!);
                          fetchStudents();
                        },
                        items: DropdownConstants.semesters
                            .map((sem) => DropdownMenuItem(value: sem, child: Text(sem)))
                            .toList(),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: selectedSection,
                        onChanged: (value) {
                          setState(() => selectedSection = value!);
                          fetchStudents();
                        },
                        items: DropdownConstants.sections
                            .map((sec) => DropdownMenuItem(value: sec, child: Text(sec)))
                            .toList(),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: statusFilter,
                        onChanged: (value) => setState(() => statusFilter = value!),
                        items: ['All', 'Paid', 'Unpaid']
                            .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                            .toList(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search by Roll No.',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => setState(() => searchRoll = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : FeesStudentList(
                            studentsWithFees: studentsWithFees,
                            searchRoll: searchRoll,
                            statusFilter: statusFilter,
                            onMarkAsPaid: markAsPaid,
                            onMarkAsUnpaid: markAsUnpaid,
                            onSendNotification: sendNotification,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
