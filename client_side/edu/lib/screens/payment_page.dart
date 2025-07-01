import 'package:flutter/material.dart';
import 'package:edu/payment_screens/upi_payment_page.dart';
import 'package:edu/payment_screens/card_payment_page.dart';
import 'package:edu/payment_screens/netbanking_payment_page.dart';

class PaymentPage extends StatefulWidget {
  final String semester;
  final int amount;
  final String rollNumber;

  const PaymentPage({
    super.key,
    required this.semester,
    required this.amount,
    required this.rollNumber,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedMethod = "UPI";

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'title': 'Pay by any UPI App',
      'subtitle': 'Google Pay, PhonePe, Paytm and more',
      'method': 'UPI',
      'icon': Icons.account_balance_wallet_outlined,
    },
    {
      'title': 'Credit or Debit Card',
      'subtitle': 'Add a new card',
      'method': 'CARD',
      'icon': Icons.credit_card,
    },
    {
      'title': 'Net Banking',
      'subtitle': 'Pay via your bank',
      'method': 'NET_BANKING',
      'icon': Icons.account_balance,
    },
  ];

  void _handleContinue() {
    final semester = widget.semester;
    final amount = widget.amount;
    final rollNumber = widget.rollNumber;

    Widget nextPage;

    if (selectedMethod == 'UPI') {
      nextPage = UPIPaymentPage(
        semester: semester,
        amount: amount,
        rollNumber: rollNumber,
      );
    } else if (selectedMethod == 'CARD') {
      nextPage = CardsPaymentPage(
        semester: semester,
        amount: amount,
        rollNumber: rollNumber,
      );
    } else {
      nextPage = NetBankingPage(
        semester: semester,
        amount: amount,
        rollNumber: rollNumber,
      );
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => nextPage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Payment Method")),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _handleContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 21, 228, 28),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Continue",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ✅ Fee Summary Card with Roll Number
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Fee Summary",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("Semester: ${widget.semester}"),
                  Text("Roll Number: ${widget.rollNumber}"),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Amount to Pay:",
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        "₹${widget.amount}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            "Select a Payment Method",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ...paymentMethods.map((method) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: RadioListTile<String>(
                value: method['method'],
                groupValue: selectedMethod,
                onChanged: (val) {
                  setState(() => selectedMethod = val!);
                },
                title: Text(method['title']),
                subtitle: Text(method['subtitle'] ?? ""),
                secondary: Icon(method['icon'], color: Colors.blue),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
