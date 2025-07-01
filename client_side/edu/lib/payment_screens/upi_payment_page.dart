import 'package:flutter/material.dart';
import 'package:edu/services/payment_service.dart';

class UPIPaymentPage extends StatelessWidget {
  final String semester;
  final int amount;
  final String rollNumber;

  const UPIPaymentPage({
    super.key,
    required this.semester,
    required this.amount,
    required this.rollNumber,
  });

  Future<void> _handlePayment(BuildContext context, String upiId) async {
    if (upiId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid UPI ID")),
      );
      return;
    }

    // ✅ Call PaymentService (only amount needed, roll/semester fetched internally)
    bool success = await PaymentService.markAsPaid(amount: amount);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Payment successful")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Payment failed. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController upiController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Pay via UPI")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Semester: $semester", style: const TextStyle(fontSize: 16)),
            Text("Roll Number: $rollNumber", style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),

            const Text("Scan QR or Enter UPI ID", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: upiController,
                    decoration: const InputDecoration(
                      labelText: "Enter UPI ID",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/upi_qr.jpeg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text("Amount: ₹$amount",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handlePayment(context, upiController.text.trim()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Pay Now", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
