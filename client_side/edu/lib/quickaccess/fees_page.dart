import 'package:edu/screens/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class StudentFeesPage extends StatefulWidget {
  const StudentFeesPage({Key? key}) : super(key: key);

  @override
  State<StudentFeesPage> createState() => _StudentFeesPageState();
}

class _StudentFeesPageState extends State<StudentFeesPage> {
  String? semester;
  String? rollNumber;
  int? currentFeeAmount;
  bool isLoading = true;
  bool alreadyPaid = false;
  Map<String, dynamic>? paymentRecord;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    semester = prefs.getString('semester');
    rollNumber = prefs.getString('roll');

    if (semester != null && rollNumber != null) {
      await _fetchFeeAmount();
      await _checkPaymentStatus();
    }

    setState(() => isLoading = false);
  }

  Future<void> _fetchFeeAmount() async {
    try {
      final res = await http.get(Uri.parse('${Constants.uri}/api/feestructure'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final match = data.firstWhere(
          (e) => e['semester'].toString().toLowerCase() == semester!.toLowerCase(),
          orElse: () => null,
        );
        currentFeeAmount = match != null ? match['amount'] : null;
      }
    } catch (e) {
      print("❌ Fee fetch error: $e");
    }
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final url = Uri.parse(
        '${Constants.uri}/api/fees/paidstatus?rollNumber=$rollNumber&semester=$semester',
      );
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print("📥 Payment status response: $data");

        if (data != null &&
            data['status'] != null &&
            data['status'].toString().toLowerCase() == 'paid') {
          alreadyPaid = true;
          paymentRecord = data;
        }
      }
    } catch (e) {
      print("❌ Payment status check failed: $e");
    }
  }

  void _goToPaymentPage() {
    if (rollNumber == null || semester == null || currentFeeAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student details not available.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          semester: semester!,
          amount: currentFeeAmount!,
          rollNumber: rollNumber!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Fees"), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : semester == null
              ? const Center(child: Text("Semester info not found."))
              : currentFeeAmount == null
                  ? const Center(child: Text("No fee record found for your semester."))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Fee Information",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),

                          Card(
                            color: Colors.blue.shade50,
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.school, color: Colors.blue),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Semester: $semester",
                                              style: const TextStyle(
                                                  fontSize: 16, fontWeight: FontWeight.w500)),
                                          Text("Roll Number: $rollNumber",
                                              style: const TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: alreadyPaid
                                        ? [
                                            const Text("Status",
                                                style: TextStyle(
                                                    fontSize: 20, fontWeight: FontWeight.w500)),
                                            const Text("Paid",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green)),
                                          ]
                                        : [
                                            const Text("Fee to be paid",
                                                style: TextStyle(fontSize: 20)),
                                            Text("₹$currentFeeAmount",
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold)),
                                          ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Center(
                            child: alreadyPaid
                                ? ElevatedButton.icon(
                                    onPressed: null,
                                    icon: const Icon(Icons.verified, color: Colors.white),
                                    label: const Text("Already Paid",
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 12),
                                    ),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: _goToPaymentPage,
                                    icon: const Icon(Icons.payment, color: Colors.white),
                                    label: const Text("Pay Now",
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 12),
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 30),
                          const Divider(),
                          const Text("Submitted Fees (History)",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),

                          paymentRecord != null
                              ? Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ListTile(
                                    leading: const Icon(Icons.receipt_long, color: Colors.green),
                                    title: Text("Paid ₹${paymentRecord!['amount']}"),
                                    subtitle: Text(_formatDate(paymentRecord!['paidDate'])),
                                  ),
                                )
                              : const Text("No payment history found."),
                        ],
                      ),
                    ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final parsedDate = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd MMMM yyyy, hh:mm a').format(parsedDate);
    } catch (e) {
      return isoDate;
    }
  }
}
