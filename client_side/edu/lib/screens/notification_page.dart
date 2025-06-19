import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../widget/notification_card.dart';

class StudentNotificationsPage extends StatefulWidget {
  const StudentNotificationsPage({super.key});

  @override
  State<StudentNotificationsPage> createState() => _StudentNotificationsPageState();
}

class _StudentNotificationsPageState extends State<StudentNotificationsPage> {
  List<dynamic> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final semester = prefs.getString('semester') ?? '';
      final section = prefs.getString('section') ?? '';
      final roll = prefs.getString('roll') ?? '';

      final res = await http.get(Uri.parse('${Constants.uri}/api/notifications?semester=$semester&section=$section&userId=$roll'));
      if (res.statusCode == 200) {
        setState(() => notifications = jsonDecode(res.body));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading notifications")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: notifications.isEmpty
          ? const Center(child: Text("No notifications available"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NotificationCard(
                    title: item['title'] ?? '',
                    subtitle: item['message'] ?? '',
                    bgColor: Colors.indigoAccent,
                  ),
                );
              },
            ),
    );
  }
}