import 'package:edu/widget/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:edu/screens/notification_page.dart';
import 'package:edu/widget/notification_card.dart';
import 'package:edu/widget/student_info_card.dart';
import 'package:edu/widget/quick_access_grid.dart';
import 'package:edu/screens/eduai_page.dart';
import 'package:edu/screens/profile_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edu/utils/constants.dart';

class HomePage extends StatefulWidget {
  final String name;
  final String roll;

  const HomePage({Key? key, required this.name, required this.roll})
    : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  List<dynamic> notifications = [];

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EduAIPage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    }
  }

  Future<void> fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final semester = prefs.getString('semester') ?? '';
      final section = prefs.getString('section') ?? '';
      final userId = prefs.getString('roll') ?? '';

      final uri = Uri.parse(
        '${Constants.uri}/api/notifications?semester=$semester&section=$section&userId=$userId',
      );
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          setState(() => notifications = decoded);
        }
      }
    } catch (e) {
      debugPrint("🚨 Error fetching notifications: $e");
    }
  }

  Color getRandomColor(int index) {
    final colors = [
      Colors.deepPurpleAccent,
      Colors.orangeAccent,
      Colors.pinkAccent,
      Colors.green,
      Colors.blueAccent,
    ];
    return colors[index % colors.length];
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> _refresh() async {
    await fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentNotificationsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SafeArea(
          child: Column(
            children: [
              StudentInfoCard(name: widget.name, roll: widget.roll),
              SizedBox(
                height: 160,
                child:
                    notifications.isEmpty
                        ? const Center(child: Text("No notifications found"))
                        : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notif = notifications[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: NotificationCard(
                                title: notif['title'] ?? 'No Title',
                                subtitle: notif['message'] ?? 'No Message',
                                imageUrl: 'assets/images/notification.png',
                                backgroundColor: getRandomColor(index),
                                link: notif['link'],
                              ),
                            );
                          },
                        ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Quick Access",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Expanded(child: QuickAccessGrid()),
            ],
          ),
        ),
      ),

      // 🌟 Floating Animated Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
