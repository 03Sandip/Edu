import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:edu/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  static Future<bool> markAsPaid({required int amount}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final roll = prefs.getString('roll');         // ✅ from login
      final semester = prefs.getString('semester'); // ✅ from login

      if (roll == null || semester == null || roll.isEmpty || semester.isEmpty) {
        print("❌ Error: Roll number or semester not found in SharedPreferences.");
        return false;
      }

      final url = Uri.parse("${Constants.uri}/api/fees/updatestatus"); // ✅ FIXED URL

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "rollNumber": roll,      // ✅ matches your backend MongoDB schema
          "semester": semester,
          "amount": amount,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Payment recorded: Roll $roll | Semester $semester | Amount ₹$amount");
        return true;
      } else {
        print("❌ Failed to record payment. Status: ${response.statusCode}, Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ PaymentService Exception: $e");
      return false;
    }
  }
}