import 'package:flutter/material.dart';
import 'package:edu/widget/notification_card.dart';
import 'package:edu/widget/student_info_card.dart';
import 'package:edu/widget/quick_access_grid.dart';
import 'package:edu/screens/eduai_page.dart'; 
import 'package:edu/screens/profile_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            StudentInfoCard(
              name: widget.name,
              roll: widget.roll,
            ),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  NotificationCard(
                    title: "Exam Alert",
                    subtitle: "Midterm from 20 June",
                    bgColor: Colors.pinkAccent,
                  ),
                  NotificationCard(
                    title: "Assignment Due",
                    subtitle: "Submit by 15 June",
                    bgColor: Colors.deepPurpleAccent,
                  ),
                  NotificationCard(
                    title: "Library Notice",
                    subtitle: "Closed on 17 June",
                    bgColor: Colors.orangeAccent,
                  ),
                ],
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
              child: QuickAccessGrid(), // No more onItemTap
            ),
          ],
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
