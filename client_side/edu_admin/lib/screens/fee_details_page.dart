import 'package:flutter/material.dart';

class FeeDetailsPage extends StatelessWidget {
  final String rollNumber;

  const FeeDetailsPage({super.key, required this.rollNumber});

  @override
  Widget build(BuildContext context) {
    // You can later fetch detailed data using the roll number here
    return Scaffold(
      appBar: AppBar(title: Text("Fee History - $rollNumber")),
      body: Center(
        child: Text("Detailed fee history will be shown here for Roll No: $rollNumber"),
      ),
    );
  }
}
