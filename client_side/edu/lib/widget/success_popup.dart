import 'package:flutter/material.dart';

class SuccessPopup extends StatelessWidget {
  final String message;
  final VoidCallback onDone;

  const SuccessPopup({
    Key? key,
    required this.message,
    required this.onDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 60),
          SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: StadiumBorder(),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              "Done",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
