import 'package:flutter/material.dart';
import 'package:edu/services/payment_service.dart';
import 'package:edu/utils/payment_utils.dart'; // ✅ Import success popup

class NetBankingPage extends StatelessWidget {
  final String semester;
  final int amount;
  final String rollNumber;

  const NetBankingPage({
    super.key,
    required this.semester,
    required this.amount,
    required this.rollNumber,
  });

  @override
  Widget build(BuildContext context) {
    final bankController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Net Banking")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Semester: $semester", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 5),
            Text("Roll Number: $rollNumber", style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),

            TextField(
              controller: bankController,
              decoration: const InputDecoration(
                labelText: "Enter Bank Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),
            Text("Amount: ₹$amount", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (bankController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter your bank name")),
                    );
                    return;
                  }

                  final success = await PaymentService.markAsPaid(amount: amount);
                  if (success) {
                    handlePaymentSuccess(context); // ✅ Show success popup + redirect
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("❌ Payment failed. Try again."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
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
