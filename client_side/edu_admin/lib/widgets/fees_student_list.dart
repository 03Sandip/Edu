import 'package:flutter/material.dart';
import '../screens/fee_details_page.dart';

class FeesStudentList extends StatelessWidget {
  final List<Map<String, dynamic>> studentsWithFees;
  final String searchRoll;
  final String statusFilter;
  final Function(String) onMarkAsPaid;
  final Function(String) onMarkAsUnpaid;
  final Function(String) onSendNotification;

  const FeesStudentList({
    super.key,
    required this.studentsWithFees,
    required this.searchRoll,
    required this.statusFilter,
    required this.onMarkAsPaid,
    required this.onMarkAsUnpaid,
    required this.onSendNotification,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: studentsWithFees.length,
      itemBuilder: (context, index) {
        final student = studentsWithFees[index];
        final studentStatus = student['status'].toString().toLowerCase();
        final roll = student['roll'].toString().toLowerCase();

        if (statusFilter.toLowerCase() != 'all' &&
            studentStatus != statusFilter.toLowerCase()) {
          return const SizedBox.shrink();
        }

        if (!roll.contains(searchRoll.toLowerCase())) {
          return const SizedBox.shrink();
        }

        Color statusColor = studentStatus == 'paid' ? Colors.green : Colors.red;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text('${student['name']} (${student['roll']})'),
            subtitle: Text(
              'Amount: ₹${student['amount']} | Status: ${student['status']} | Date: ${student['date']}',
              style: TextStyle(color: statusColor),
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (studentStatus == 'paid') {
                      onMarkAsUnpaid(student['roll']);
                    } else {
                      onMarkAsPaid(student['roll']);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: studentStatus == 'paid' ? Colors.green : Colors.red,
                  ),
                  child: Text(
                    studentStatus == 'paid' ? 'Paid' : 'Unpaid',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                if (studentStatus != 'paid')
                  ElevatedButton(
                    onPressed: () => onSendNotification(student['roll']),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text('Notify', style: TextStyle(color: Colors.white)),
                  ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FeeDetailsPage(rollNumber: student['roll']),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Details', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
