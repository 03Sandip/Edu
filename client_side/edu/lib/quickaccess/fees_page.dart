import 'package:flutter/material.dart';

class StudentFeesPage extends StatefulWidget {
  const StudentFeesPage({Key? key}) : super(key: key);

  @override
  State<StudentFeesPage> createState() => _StudentFeesPageState();
}

class _StudentFeesPageState extends State<StudentFeesPage> {
  List<Map<String, String>> submittedFees = [];
  Map<String, String> dueFees = {};
  Map<String, String> upcomingFees = {};

  @override
  void initState() {
    super.initState();
    _loadFees(); // Simulate or fetch data from backend
  }

  Future<void> _loadFees() async {
    // Simulated delay/fetch
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      submittedFees = [
        {
          "title": "1st Semester Fees",
          "amount": "₹25,000",
          "date": "2024-08-10",
          "time": "11:30 AM"
        },
        {
          "title": "2nd Semester Fees",
          "amount": "₹25,000",
          "date": "2024-08-10",
          "time": "11:30 AM"
        },
        {
          "title": "Exam Fees",
          "amount": "₹2,000",
          "date": "2025-01-15",
          "time": "03:15 PM"
        },
      ];

      dueFees = {
        "title": "7th Semester",
        "amount": "₹45,000",
        "dueDate": "2025-07-05",
      };

      upcomingFees = {
        "title": "8th Semester Fees",
        "amount": "₹50,000",
        "dueDate": "2025-08-01",
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Fees"),
        centerTitle: true,
      ),
      body: submittedFees.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFees,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    _buildSectionTitle("Due Fees"),
                    _buildFeeCard(
                      dueFees["title"]!,
                      dueFees["amount"]!,
                      dueFees["dueDate"]!,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle("Upcoming Fees"),
                    _buildFeeCard(
                      upcomingFees["title"]!,
                      upcomingFees["amount"]!,
                      upcomingFees["dueDate"]!,
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle("Submitted Fees"),
                    ...submittedFees.map(_buildSubmittedFeeTile).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildFeeCard(String title, String amount, String date,
      {required Color color}) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.warning_rounded, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("Due Date: $date"),
        trailing: Text(
          amount,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSubmittedFeeTile(Map<String, String> fee) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(fee['title']!, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("${fee['date']} at ${fee['time']}"),
        trailing: IconButton(
          icon: const Icon(Icons.download, color: Colors.blue),
          onPressed: () {
            // TODO: implement invoice download logic
          },
        ),
      ),
    );
  }
}
