import 'package:flutter/material.dart';
import 'package:edu/services/payment_service.dart';
import 'package:edu/utils/payment_utils.dart'; // <-- Import utility

class CardsPaymentPage extends StatelessWidget {
  final String semester;
  final int amount;
  final String rollNumber;

  const CardsPaymentPage({
    super.key,
    required this.semester,
    required this.amount,
    required this.rollNumber,
  });

  Future<void> _handleCardPayment(BuildContext context) async {
    bool success = await PaymentService.markAsPaid(amount: amount);

    if (success) {
      handlePaymentSuccess(context); // ✅ Use shared dialog+redirect
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Payment failed. Try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Pay via Card")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Semester: $semester", style: const TextStyle(fontSize: 16)),
            Text("Roll Number: $rollNumber",
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),

            const Text("Enter Card Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            TextField(
              controller: cardController,
              keyboardType: TextInputType.number,
              maxLength: 16,
              decoration: const InputDecoration(
                labelText: "Card Number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: expiryController,
                    decoration: const InputDecoration(
                      labelText: "MM/YY",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: cvvController,
                    decoration: const InputDecoration(
                      labelText: "CVV",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 3,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Center(
              child: Text(
                "Amount to Pay: ₹$amount",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleCardPayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Pay Now",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
