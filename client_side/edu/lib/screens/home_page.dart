import 'package:edu/screens/notification_page.dart';
import 'package:flutter/material.dart';
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

  const HomePage({
    Key? key,
    required this.name,
    required this.roll,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<dynamic> notifications = [];

  void _onBottomNavTap(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EduAIPage()),
      );
    } else if (index == 1) {
      setState(() {
        _selectedIndex = index;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final semester = prefs.getString('semester') ?? '';
      final section = prefs.getString('section') ?? '';
      final userId = prefs.getString('roll') ?? '';

      final uri = Uri.parse('${Constants.uri}/api/notifications?semester=$semester&section=$section&userId=$userId');
      debugPrint('🔍 Request URI: $uri');

      final res = await http.get(uri);
      debugPrint('📦 Status Code: ${res.statusCode}');
      debugPrint('📨 Response Body: ${res.body}');

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          setState(() {
            notifications = decoded;
          });
        } else {
          debugPrint('❌ Response is not a list');
        }
      } else {
        debugPrint("❌ Failed to load notifications. Server responded with status: ${res.statusCode}");
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
                MaterialPageRoute(builder: (_) => const StudentNotificationsPage()),
              );
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SafeArea(
          child: Column(
            children: [
              StudentInfoCard(
                name: widget.name,
                roll: widget.roll,
              ),
              SizedBox(
                height: 160,
                child: notifications.isEmpty
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
                              backgroundColor: getRandomColor(index), // ✅ Rotating color
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
              const Expanded(
                child: QuickAccessGrid(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'Edu AI'),
        ],
      ),
    );
  }
}
