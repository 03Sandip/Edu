import 'dart:convert';
import 'package:edu_teacher/utils/constants.dart';
import 'package:http/http.dart' as http;


class StudentService {
  static Future<List<Map<String, dynamic>>> fetchStudents() async {
    final response = await http.get(Uri.parse('${Constants.uri}/students'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load students');
    }
  }
}
